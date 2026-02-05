package com.github.rhu1.gt.codegen

import org.scribble.ext.gt.core.model.efsm.event.*
import org.scribble.ext.gt.core.model.efsm.{GTEFSM, GTVState}

import java.io.{File, FileOutputStream, InputStream}
import java.nio.charset.StandardCharsets
import scala.collection.mutable
import scala.jdk.CollectionConverters.*

object CallbackModuleGenerator {

  private def erlAtom(op: String): String = {
    if (op.matches("^[a-z][a-zA-Z0-9_@]*$") ) op else s"'${op}'"
  }

  private def loadResource(path: String): String = {
    val is: InputStream = Option(getClass.getResourceAsStream(path))
      .getOrElse(throw new RuntimeException(s"Template not found on classpath: $path"))
    val bytes = is.readAllBytes()
    is.close()
    new String(bytes, StandardCharsets.UTF_8)
  }

  private def writeFile(outFile: File, content: String): Unit = {
    outFile.getParentFile.mkdirs()
    val fos = new FileOutputStream(outFile)
    fos.write(content.getBytes(StandardCharsets.UTF_8))
    fos.close()
  }

  private def renderStatesSection(template: String, sectionName: String, perStateContent: List[String]): String = {
    val startTag = s"{{#$sectionName}}"
    val endTag   = s"{{/$sectionName}}"
    val startIdx = template.indexOf(startTag)
    val endIdx   = template.indexOf(endTag)
    if (startIdx >= 0 && endIdx > startIdx) {
      val before = template.substring(0, startIdx)
      val after  = template.substring(endIdx + endTag.length)
      before + perStateContent.mkString("\n\n") + after
    } else template
  }

  private def replaceAll(template: String, pairs: (String, String)*): String =
    pairs.foldLeft(template) { case (acc, (k, v)) => acc.replace(s"{{$k}}", v) }

  private def statesFrom(efsm: GTEFSM): List[GTVState] =
    efsm.S.asScala.toList.sortBy(_.id)

  private case class SigPieces(eventTypeUnion: String, msgArgUnion: String, retUnion: String)

  private def buildSigPieces(efsm: GTEFSM, state: GTVState, localName: String): SigPieces = {
    val edges = org.scribble.ext.gt.codegen.erlang.GTGenUtil.filterEdgesByState(efsm, state)
    val tauOps: List[String] = edges.keySet().asScala
      .map(_.right)
      .collect { case t: GTVTau => t.op.toString }
      .toSet.toList.sorted

    case class RecvSig(role: String, op: String, arity: Int)
    val recvSigs: List[RecvSig] = edges.keySet().asScala
      .map(_.right)
      .collect { case r: GTVRecv => RecvSig(r.role.toString, r.op.toString, r.pay.elems.size()) }
      .toSet.toList.sortBy(rs => (rs.role, rs.op, rs.arity))

    val eventTypeUnion: String =
      if (tauOps.nonEmpty && recvSigs.nonEmpty) "internal | cast"
      else if (tauOps.nonEmpty) "internal"
      else if (recvSigs.nonEmpty) "cast"
      else "gen_statem:event_type()"

    val internalArgTypes: List[String] = tauOps.map(op => s"{${erlAtom(op)}}")
    val castArgTypes: List[String] = recvSigs.map { rs => s"{pid(), ${payloadType(rs.op, rs.arity)}}" }

    val msgArgUnion = (internalArgTypes ++ castArgTypes) match {
      case Nil => "term()"
      case single :: Nil => single
      case many => many.mkString(" | ")
    }

    // Filter out end states from next_state entries
    val succStates: List[GTVState] = edges.values().asScala.flatMap(_.asScala.map(_.right)).toSet.toList
    val nextStates: List[String] = succStates.filterNot(s => isEndState(efsm, s)).map(s => s"s${s.id}").sorted

    val baseNexts = nextStates.map(ns => s"{next_state, ${ns}, state_data()}")
    val withActions = for { ns <- nextStates; l <- tauOps } yield s"{next_state, ${ns}, state_data(), [{next_event, internal, {${erlAtom(l)}}}] }"
    val extras = List("{keep_state, state_data()}", "{stop, normal, state_data()}")
    val retUnion = (baseNexts ++ withActions ++ extras).distinct match {
      case Nil => "{keep_state, state_data()}"
      case xs  => xs.mkString(" | ")
    }

    SigPieces(eventTypeUnion, msgArgUnion, retUnion)
  }

  // Canonical message encoding:
  //  - arity 0: {op}
  //  - arity 1: {op, {Arg}}
  //  - arity n: {op, {A1, ..., An}}
  private def payloadType(op: String, arity: Int): String = {
    arity match {
      case 0 => s"{${erlAtom(op)}}"
      case 1 => s"{${erlAtom(op)}, {term()}}"
      case n => s"{${erlAtom(op)}, {" + List.fill(n)("term()").mkString(", ") + "}}"
    }
  }

  private def payloadPatternWithVars(op: String, varNames: List[String]): String = {
    varNames match {
      case Nil => s"{${erlAtom(op)}}"
      case one :: Nil => s"{${erlAtom(op)}, {${one}}}"
      case many => s"{${erlAtom(op)}, {" + many.mkString(", ") + "}}"
    }
  }

  private def underscorePayloadPattern(op: String, arity: Int): String = {
    if (arity == 0) s"{${erlAtom(op)}}"
    else if (arity == 1) s"{${erlAtom(op)}, {_}}"
    else s"{${erlAtom(op)}, {" + List.fill(arity)("_").mkString(", ") + "}}"
  }

  private def capFirst(s: String): String = if (s.isEmpty) s else s.head.toUpper.toString + s.tail

  private def hasTauAndRecv(efsm: GTEFSM, state: GTVState): Boolean = state.isEntry

  private def isEndState(efsm: GTEFSM, state: GTVState): Boolean = {
    org.scribble.ext.gt.codegen.erlang.GTGenUtil.filterEdgesByState(efsm, state).isEmpty
  }

  // Build next-state expression for a given successor, using make_choice_sX when that successor has >1 tau transitions
  private def nextExprForSucc(efsm: GTEFSM, succ: GTVState, dataVar: String): String = {
    if (isEndState(efsm, succ)) return s"{stop, normal, ${dataVar}}"
    val succEdges = org.scribble.ext.gt.codegen.erlang.GTGenUtil.filterEdgesByState(efsm, succ)
    // Preserve EFSM order of tau ops, deduplicated by first occurrence
    val tauOpsRaw: List[String] = succEdges.keySet().asScala.iterator
      .collect { case k if k.right.isInstanceOf[GTVTau] => k.right.asInstanceOf[GTVTau].op.toString }
      .toList
    val tauOps: List[String] = {
      val seen = scala.collection.mutable.LinkedHashSet[String]()
      tauOpsRaw.filter { op => val isNew = !seen.contains(op); if (isNew) seen += op; isNew }
    }
    val sname = s"s${succ.id}"
    tauOps match {
      case Nil => s"{next_state, ${sname}, ${dataVar}}"
      case op :: Nil => s"{next_state, ${sname}, ${dataVar}, [{next_event, internal, {${erlAtom(op)}}}]}"
      case many =>
        val cases = many.zipWithIndex.map { case (op, i) =>
          val idx = i + 1
          s"${idx} -> {next_state, ${sname}, ${dataVar}, [{next_event, internal, {${erlAtom(op)}}}]}"
        }.mkString(";\n        ")
        s"case make_choice_${sname}(${dataVar}) of\n        ${cases}\n    end"
    }
  }

  /**
    * Generates per-role callback modules (<role>.erl) used by the generic runtime.
    */
  def generateCallback(protocolName: String, roleAtom: String, efsm: GTEFSM, outDir: File, peerRolesLower: Seq[String], emitGC: Boolean = false): File = {
    val tmplRaw = loadResource("/templates/callback_module.template")

    val stateList = statesFrom(efsm)
    val initialState = s"s${efsm.init.id}"

    // Precompute non-end state names for filtering next_state in specs
    val nonEndStateNames: Set[String] = stateList.filterNot(s => isEndState(efsm, s)).map(s => s"s${s.id}").toSet

    // Determine init return spec (may include next_event internal when exactly one tau from init)
    val initEdgesAll = org.scribble.ext.gt.codegen.erlang.GTGenUtil.filterEdgesByState(efsm, efsm.init)
    val initTauOps: List[String] = initEdgesAll.keySet().asScala
      .map(_.right)
      .collect { case t: GTVTau => t.op.toString }
      .toList
    val initRetSpec: String =
      if (initTauOps.size == 1)
        s"{ok, ${initialState}, state_data(), [{next_event, internal, {${erlAtom(initTauOps.head)}}}]}"
      else if (initTauOps.size > 1)
        s"{ok, ${initialState}, state_data()} | {ok, ${initialState}, state_data(), [gen_statem:action()] }"
      else
        s"{ok, ${initialState}, state_data()}"

    def filterRetUnion(ret: String): String = {
      val parts = ret.split(" \\| ").toList
      val NextState = "\\{next_state,\\s*(s\\d+)\\b".r
      val kept = parts.filter {
        case NextState(stateName) => nonEndStateNames.contains(stateName)
        case _ => true
      }
      if (kept.isEmpty) "{keep_state, state_data()}" else kept.mkString(" | ")
    }

    // Determine immediate successor states of the initial state (kept for future use)
    val initEdges = org.scribble.ext.gt.codegen.erlang.GTGenUtil.filterEdgesByState(efsm, efsm.init)
    val firstAfterInit: Set[GTVState] = initEdges.values().asScala.flatMap(_.asScala.map(_.right)).toSet

    val perStateTmplStart = tmplRaw.indexOf("{{#states}}")
    val perStateTmplEnd   = tmplRaw.indexOf("{{/states}}")
    val perStateTmpl =
      if (perStateTmplStart >= 0 && perStateTmplEnd > perStateTmplStart)
        tmplRaw.substring(perStateTmplStart + "{{#states}}".length, perStateTmplEnd)
      else ""

    // Helper views over EFSM edges for this method
    type EdgePair = org.scribble.util.Pair[GTVAction, GTVState]

    def eventSetFor(state: GTVState, ev: AnyRef): List[EdgePair] = {
      val edges = org.scribble.ext.gt.codegen.erlang.GTGenUtil.filterEdgesByState(efsm, state)
      edges.asScala.collectFirst { case (k, v) if k.right eq ev => v.asScala.toList }.getOrElse(Nil)
    }

    def nextStatesFor(pairs: List[EdgePair]): List[GTVState] = pairs.map(_.right).distinct

    def tauLabelsFor(pairs: List[EdgePair]): List[String] =
      pairs.flatMap { p => p.left match { case t: GTVTau => Some(t.op.toString); case _ => None } }

    case class SendInfo(roleAtom: String, op: String, arity: Int, varNames: List[String])
    def sendsFor(pairs: List[EdgePair]): List[SendInfo] =
      pairs.flatMap { p =>
        p.left match {
          case s: GTVSend     =>
            val raw = s.pay.elems.asScala.toList.map(e => capFirst(e.toString))
            val seen = scala.collection.mutable.LinkedHashMap.empty[String, Int]
            val vs = raw.map { n => val i = seen.getOrElse(n, 0); seen.update(n, i + 1); if (i==0) n else s"${n}${i+1}" }
            Some(SendInfo(s.role.toString, s.op.toString, s.pay.elems.size(), vs))
          case s: GTVSendStar =>
            val raw = s.pay.elems.asScala.toList.map(e => capFirst(e.toString))
            val seen = scala.collection.mutable.LinkedHashMap.empty[String, Int]
            val vs = raw.map { n => val i = seen.getOrElse(n, 0); seen.update(n, i + 1); if (i==0) n else s"${n}${i+1}" }
            Some(SendInfo(s.role.toString, s.op.toString, s.pay.elems.size(), vs))
          case _              => None
        }
      }

    // Build per-state bodies; only include states that yield at least one clause, and skip end states entirely
    case class BuiltState(name: String, body: String)
    val builtStates: List[BuiltState] = stateList.flatMap { s =>
      if (isEndState(efsm, s)) None
      else {
        val sname = s"s${s.id}"
        // Build and filter signature to avoid next_state entries to end states
        val rawSig = buildSigPieces(efsm, s, sname)
        val sig = rawSig.copy(retUnion = filterRetUnion(rawSig.retUnion))

        val comment = if (hasTauAndRecv(efsm, s)) "%% Mixed-choice entry state\n" else ""

        val edges = org.scribble.ext.gt.codegen.erlang.GTGenUtil.filterEdgesByState(efsm, s)
        val events = edges.keySet().asScala.map(_.right)
        case class Key(kind: String, op: String, role: String, arity: Int)
        val seen = mutable.LinkedHashSet[Key]()

        val isInit = sname == initialState
        // We now connect at the initial state (first after gen_statem init)
        val connectHere = isInit

        def nextInternalFromSucc(succ: GTVState): Option[String] = {
          val succEdges = org.scribble.ext.gt.codegen.erlang.GTGenUtil.filterEdgesByState(efsm, succ)
          val tauOps = succEdges.keySet().asScala.map(_.right).collect{ case t: GTVTau => t.op.toString }.toList
          tauOps.headOption
        }

        val clauseList: List[String] = events.flatMap {
          case t: GTVTau =>
            val k = Key("tau", t.op.toString, "", 0)
            if (seen(k)) None else {
              seen += k
              val pairs = eventSetFor(s, t)
              val sends = sendsFor(pairs)
              val nstates = nextStatesFor(pairs)
              val dataVar = if (connectHere) "Data1" else "Data"
              val connectLine = if (connectHere) "    Data1 = connect(Data),\n" else ""

              val sendLines = sends.flatMap { ss =>
                val roleLower = ss.roleAtom.toLowerCase
                val roleVar = capFirst(ss.roleAtom) + "Pid"
                val pidLine = s"    ${roleVar} = ${dataVar}#state_data.${roleLower}_pid,\n"

                val payloadArgs: String =
                  if (ss.arity > 0) ", " + List.fill(ss.arity)("undefined").mkString(", ")
                  else ""

                val call = s"    gen_${roleAtom}:send_${sname}_${ss.op}(${roleVar}${payloadArgs}, ${dataVar}),\n"
                List(pidLine, call)
              }.mkString("")

              val finalExpr = nstates.headOption match {
                case Some(ns) => nextExprForSucc(efsm, ns, dataVar)
                case None     => s"{keep_state, ${dataVar}}"
              }
              Some(s"""
                |${sname}(internal, {${erlAtom(t.op.toString)}}, Data) ->
                |${connectLine}${sendLines}    ${finalExpr}
                |""".stripMargin.trim)
            }
          case r: GTVRecv =>
            val roleVar = capFirst(r.role.toString) + "Pid"
            val op = r.op.toString
            val arity = r.pay.elems.size()
            // Build payload pattern with variable names from payload aliases
            val rawNames: List[String] = r.pay.elems.asScala.toList.map(e => capFirst(e.toString))
            val varNames: List[String] = {
              val seen = scala.collection.mutable.LinkedHashMap.empty[String, Int]
              rawNames.map { n =>
                val idx = seen.getOrElse(n, 0)
                seen.update(n, idx + 1)
                if (idx == 0) n else s"${n}${idx + 1}"
              }
            }

            val payloadPatWithVars = payloadPatternWithVars(op, varNames)
            val payloadVars = varNames

            val senderField = r.role.toString.toLowerCase + "_pid"
            val k = Key("recv", op, r.role.toString, arity)
            if (seen(k)) None else {
              seen += k
              val pairs = eventSetFor(s, r)
              val nstates = nextStatesFor(pairs)
              val finalExpr = nstates.headOption match {
                case Some(ns) => nextExprForSucc(efsm, ns, "Data")
                case None     => "{keep_state, Data}"
              }
              val headDataVar = if (connectHere) "Data0" else "Data"
              val dataPattern = s"#state_data{${senderField} = ${roleVar}} = ${headDataVar}"
              val maybeConnect = if (connectHere) "    Data = connect(Data0),\n" else ""
              val varList = if (payloadVars.isEmpty) "[]" else s"[${payloadVars.mkString(", ")}]"
              val me = capFirst(roleAtom)
              val from = capFirst(r.role.toString)
              val placeholderSuffix = if (payloadVars.isEmpty) "" else " " + List.fill(payloadVars.size)("~p").mkString(", ")
              val logFmt = s"${me}: ${sname} Received ${op}${placeholderSuffix} from ${from} ~n"
              val logLine = s"    io:format(\"${logFmt}\", ${varList}),\n"
              Some(s"""
                |${sname}(cast, {${roleVar}, ${payloadPatWithVars}}, ${dataPattern}) ->
                |${maybeConnect}${logLine}    ${finalExpr}
                |""".stripMargin.trim)
            }
          case _ => None
        }.toList

        val clausesJoined = clauseList match {
          case Nil if connectHere && !isEndState(efsm, s) =>
            val defaultClause = s"""
              |${sname}(EventType, Event, Data0) ->
              |    Data = connect(Data0),
              |    {keep_state, Data}
              |""".stripMargin.trim
            defaultClause + "."
          case Nil => ""
          case one :: Nil => one + "."
          case many => many.mkString(";\n\n") + "."
        }

        if (clausesJoined.nonEmpty) {
          val body = replaceAll(
            perStateTmpl,
            "STATE_COMMENT" -> comment,
            "STATE_SPEC" -> s"-spec ${sname}(${sig.eventTypeUnion}, ${sig.msgArgUnion}, state_data()) -> ${sig.retUnion}.",
            "STATE_NAME" -> sname,
            "STATE_CLAUSES" -> clausesJoined
          )
          Some(BuiltState(sname, body))
        } else None
      }
    }

    val stateExports = builtStates.map(_.name + "/3").mkString(", ")
    val withStates = {
      val combinedBodies = builtStates.map(_.body)
      renderStatesSection(tmplRaw, "states", combinedBodies)
    }

    val callbackExports = {
      val base = List("init/1", "code_change/4", "terminate/3")
      val states = builtStates.map(bs => bs.name + "/3")
      (base ++ states).mkString(", ")
    }

    // Build connection(Data0) body using begin...end: resolve peers then update record
    val peers = peerRolesLower.filterNot(_ == roleAtom)
    val connProlog: String = if (peers.isEmpty) "" else peers.map { r =>
      val v = s"${capFirst(r)}Pid"
      val pv = s"Pid${capFirst(r)}"
      s"""${v} = case whereis(${r}) of
         |        undefined ->
         |            io:format(\"${r} is not available yet. Will retry...~n\", []),
         |            timer:sleep(1000),
         |            whereis(${r});
         |        ${pv} ->
         |            ${pv}
         |    end""".stripMargin
    }.mkString(",\n\n")

    val recordUpdate = if (peers.isEmpty) "Data0" else {
      val assigns = peers.map(r => s"${r}_pid = ${capFirst(r)}Pid").mkString(", ")
      s"Data0#state_data{${assigns}}"
    }

    val connectionBody = if (peers.isEmpty) "Data0" else s"begin\n${connProlog},\n\n${recordUpdate}\nend"

    val finalBody0 = replaceAll(
      withStates,
      "MODULE_NAME" -> roleAtom,
      "BEHAVIOUR_MODULE" -> s"gen_${roleAtom}",
      "HRL_BASENAME" -> roleAtom,
      "STATE_EXPORTS" -> stateExports,
      "CALLBACK_EXPORTS" -> callbackExports,
      "STATE_DATA_FIELDS" -> "{}",
      "GEN_OPTS" -> "[{debug, [trace]}]",
      "INITIAL_STATE" -> initialState,
      "INIT_ARGS" -> "[]",
      "STATE_DATA_INIT" -> "Data = #state_data{}",
      "INIT_RET_SPEC" -> initRetSpec,
      "INIT_ACTIONS_RETURN" -> {
        if (initTauOps.size == 1)
          s"{ok, ${initialState}, Data, [{next_event, internal, {${erlAtom(initTauOps.head)}}}]}"
        else s"{ok, ${initialState}, Data}"
      },
      "CONNECTION_BODY" -> connectionBody
    )

    // -------- make_choice_ helpers (state-level only) --------
    case class ChoiceState(name: String, choices: Int)
    val choiceStates: List[ChoiceState] = stateList.flatMap { st =>
      val tauCount = org.scribble.ext.gt.codegen.erlang.GTGenUtil
        .filterEdgesByState(efsm, st)
        .keySet().asScala
        .count(k => k.right.isInstanceOf[GTVTau])
      if (tauCount > 1) Some(ChoiceState(s"s${st.id}", tauCount)) else None
    }.distinct

    val stateChoiceFuncs: String = choiceStates.map { cs =>
      s"""
         |%% Random choice helper for state ${cs.name}
         |-spec make_choice_${cs.name}(state_data()) -> integer().
         |make_choice_${cs.name}(_Data) -> rand:uniform(${cs.choices}).
         |""".stripMargin.trim
    }.mkString("\n\n")

    val choiceHelpers = stateChoiceFuncs

    val gcHooks: String = ""

    val finalBody = {
      val withChoices = if (choiceHelpers.nonEmpty)
        finalBody0 + "\n\n%% ---------- Choice helpers ----------\n" + choiceHelpers + "\n"
      else finalBody0
      withChoices
    }

    val outFile = new File(outDir, s"${roleAtom}.erl")
    writeFile(outFile, finalBody)
    outFile
  }

}

