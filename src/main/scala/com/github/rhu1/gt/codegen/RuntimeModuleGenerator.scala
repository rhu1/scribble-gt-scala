package com.github.rhu1.gt.codegen

import org.scribble.ext.gt.core.model.efsm.event.*
import org.scribble.ext.gt.core.model.efsm.{GTEFSM, GTVState}
import org.scribble.ext.gt.core.model.efsm.GTVRecVar
import org.scribble.core.`type`.name.RecVar

import java.io.File
import java.nio.charset.StandardCharsets
import java.nio.file.Files
import scala.jdk.CollectionConverters.*

/**
  * Generates the generic runtime module: gen_<role>.erl
  *  - Uses gen_statem behaviour in state_functions mode.
  *  - Path-based purging: receive triples {From, Label, Pi}, drop if stale(Pi).
  *  - Local commitments: process dictionary 'commit_map' (McId -> left|right).
  *  - Commit points: at entry mixed choice states (having both Tau and Recv):
  *      * on Tau: commit(RIGHT), on Recv: commit(LEFT).
  *  - Send helpers attach Pi using current_path_plus([{McId, Side}]) at MC entries,
  *    and current_path() elsewhere under mixed-choice regions.
  *  - External events are postponed (not dropped) to preserve selective receive,
  *   for recvs not handled directly in the current state.
  */
object RuntimeModuleGenerator {

  private sealed trait StateKind
  private object StateKind {
    case object Branch extends StateKind
    case object Select extends StateKind
    case object InternalMixed extends StateKind
    case object ExternalMixedOI extends StateKind
    case object ExternalMixedII extends StateKind
    case object ExternalMixedNotEntry extends StateKind
    case object End extends StateKind

    def fromJava(m: GTEFSM, s: GTVState): StateKind = {
      val name = org.scribble.ext.gt.codegen.erlang.GTGenUtil.getStateKind(m, s).name()
      name match {
        case "BRANCH"                   => Branch
        case "SELECT"                   => Select
        case "INTERNAL_MIXED"           => InternalMixed
        case "EXTERNAL_MIXED_OI"        => ExternalMixedOI
        case "EXTERNAL_MIXED_II"        => ExternalMixedII
        case "EXTERNAL_MIXED_NOT_ENTRY" => ExternalMixedNotEntry
        case "END"                      => End
        case other                       => throw new IllegalArgumentException(s"Unknown StateKind: $other")
      }
    }
  }

  private def erlAtom(op: String): String = {
    if (op.matches("^[a-z][a-zA-Z0-9_@]*$") ) op else s"'${op}'"
  }

  // Collect all receive events that are reachable from a given state.
  // do not filter out direct receives here, because in mixed-choice regions
  // the same op can arrive "late" at a different state, and we still need a safety clause.
  private def reachableRecvEvents(efsm: GTEFSM, from: GTVState): List[GTVRecv] = {
    val visited = scala.collection.mutable.HashSet.empty[GTVState]
    val q = scala.collection.mutable.Queue[GTVState](from)

    val out = scala.collection.mutable.ListBuffer.empty[GTVRecv]

    while (q.nonEmpty) {
      val s = q.dequeue()
      if (!visited.contains(s)) {
        visited += s
        val edges = org.scribble.ext.gt.codegen.erlang.GTGenUtil.filterEdgesByState(efsm, s)

        // record reachable recvs
        edges.keySet().asScala.foreach { k =>
          k.right match {
            case r: GTVRecv => out += r
            case _ =>
          }
        }

        // BFS successors
        edges.values().asScala.foreach { targets =>
          targets.asScala.foreach { pair =>
            q.enqueue(pair.right)
          }
        }
      }
    }

    // de-dupe by (role, op, arity)
    val seen = scala.collection.mutable.LinkedHashSet.empty[(String, String, Int)]
    out.toList.filter { r =>
      val key = (r.role.toString, r.op.toString, r.pay.elems.size())
      if (seen.contains(key)) false else { seen += key; true }
    }
  }

  // Canonical message encoding:
  //  - arity 0: {op}
  //  - arity 1: {op, {Arg}}
  //  - arity n: {op, {A1, ..., An}}
  private def payloadTerm(opStr: String, args: List[String]): String = {
    val op = erlAtom(opStr)
    args match {
      case Nil => s"{$op}"
      case one :: Nil => s"{$op, {$one}}"
      case many => s"{$op, {" + many.mkString(", ") + "}}"
    }
  }

  private def payloadType(opStr: String, arity: Int): String = {
    val op = erlAtom(opStr)
    arity match {
      case 0 => s"{$op}"
      case 1 => s"{$op, {term()}}"
      case n => s"{$op, {" + List.fill(n)("term()").mkString(", ") + "}}"
    }
  }

  private def payloadPatNamed(opStr: String, varNames: List[String]): String = {
    val op = erlAtom(opStr)
    varNames match {
      case Nil => s"{$op}"
      case one :: Nil => s"{$op, {$one}}"
      case many => s"{$op, {" + many.mkString(", ") + "}}"
    }
  }

  def generate(protocolName: String, roleAtom: String, efsm: GTEFSM, outDir: File, emitGC: Boolean = false): File = {
    val genModule = s"gen_${roleAtom}"
    val stateListAll = efsm.S.asScala.toList.sortBy(_.id)

    // Precompute all receive event signatures in this EFSM (used for GC safety handlers)
    val allRecvEvents: List[GTVRecv] =
      stateListAll
        .flatMap(s => org.scribble.ext.gt.codegen.erlang.GTGenUtil.filterEdgesByState(efsm, s).keySet().asScala.map(_.right))
        .collect { case r: GTVRecv => r }

    stateListAll.foreach { s =>
      val kindName = org.scribble.ext.gt.codegen.erlang.GTGenUtil.getStateKind(efsm, s).name()
      val edges = org.scribble.ext.gt.codegen.erlang.GTGenUtil.filterEdgesByState(efsm, s)
      val edgeKeys = edges.keySet().asScala.map(k => s"(${k.left.id}, ${k.right})").mkString(", ")
    }

    val localName: Map[GTVState, String] = stateListAll.map(s => s -> s"s${s.id}").toMap
    val statesAll = stateListAll.map(localName)
    val initState = localName.getOrElse(efsm.init, statesAll.headOption.getOrElse("s0"))

    // Helper: end/sink state has no outgoing behaviour
    def isEndState(s: GTVState): Boolean =
      StateKind.fromJava(efsm, s) == StateKind.End

    // Only generate non-end states
    val stateList = stateListAll.filterNot(isEndState)

    // Identify entry mixed-choice states
    def isEntryMC(s: GTVState): Boolean = s.isEntry
    val mcStates: List[GTVState] = stateList.filter(isEntryMC)
    val mcIds: Map[GTVState, String] = mcStates.zipWithIndex.map{ case (s, i) => s -> s"mc${i+1}" }.toMap

    // Recursion variables are represented by GTVRecVar states
    val recVarEntries: Map[RecVar, GTVState] = {
      val m = scala.collection.mutable.LinkedHashMap.empty[RecVar, GTVState]
      stateListAll.foreach { st =>
        st.recvars.asScala.foreach(rv => m.update(rv, st))
      }
      m.toMap
    }

    val succCache = scala.collection.mutable.HashMap.empty[GTVState, List[GTVState]]
    def successors(s: GTVState): List[GTVState] = succCache.getOrElseUpdate(s, {
      val es = org.scribble.ext.gt.codegen.erlang.GTGenUtil.filterEdgesByState(efsm, s)
      es.values().asScala.toList
        .flatMap(_.asScala.map(_.right))
        .flatMap {
          case r: GTVRecVar =>
            // Loop-back: redirect to recursion entry if known; otherwise treat as no successor.
            recVarEntries.get(r.recvar).toList
          case other => List(other)
        }
    })

    def reachableFrom(seed: GTVState): Set[GTVState] = {
      val visited = scala.collection.mutable.LinkedHashSet[GTVState]()
      val stack = scala.collection.mutable.Stack[GTVState](seed)
      while (stack.nonEmpty) {
        val cur = stack.pop()
        if (!visited.contains(cur)) {
          visited += cur
          successors(cur).foreach(stack.push)
        }
      }
      visited.toSet
    }

    // Descendants of mixed-choice entries: states reachable from any MC entry (including itself).
    // Track by id so membership checks are stable.
    val mcDescendantIds: Set[Int] = mcStates.flatMap(reachableFrom).map(_.id).toSet
    val mcDescendants: Set[GTVState] = stateListAll.filter(s => mcDescendantIds.contains(s.id)).toSet

    // For each MC entry, compute left/right successor state name sets (for commit-after-callback)
    case class LRMap(left: Set[String], right: Set[String])
    val mcLR: Map[GTVState, LRMap] = mcStates.map { s =>
      val edges = org.scribble.ext.gt.codegen.erlang.GTGenUtil.filterEdgesByState(efsm, s)
      val rightSuccs = edges.asScala.collectFirst { case (k, v) if k.right.isInstanceOf[GTVTau] => v.asScala.toList.map(p => localName(p.right)) }.getOrElse(Nil).toSet
      val leftSuccs  = edges.asScala.collectFirst { case (k, v) if k.right.isInstanceOf[GTVRecv] => v.asScala.toList.map(p => localName(p.right)) }.getOrElse(Nil).toSet
      s -> LRMap(leftSuccs, rightSuccs)
    }.toMap

    // Export list: state functions and send helpers (only for non-end states)
    val exportStates = if (stateList.nonEmpty) stateList.map(s => localName(s) + "/3").mkString(",\n  ") else ""

    // ------------------- Send helpers -------------------
    case class SendSpec(funcName: String, exportArity: Int, code: String)

    def capitalizeFirst(s: String): String = if (s.isEmpty) s else s.head.toUpper.toString + s.tail

    def buildSendSpecs(s: GTVState): List[SendSpec] = {
      val name = localName(s)
      val edges = org.scribble.ext.gt.codegen.erlang.GTGenUtil.filterEdgesByState(efsm, s)
      // Collect concrete send actions with payload var names from EFSM
      case class SendAction(op: String, role: String, arity: Int, varNames: List[String])
      def toVarNames(elems: java.util.List[?]): List[String] = {
        val raw = elems.asInstanceOf[java.util.List[AnyRef]].asScala.toList.map(x => capitalizeFirst(String.valueOf(x)))
        val seen = scala.collection.mutable.LinkedHashMap.empty[String, Int]
        raw.map { n =>
          val idx = seen.getOrElse(n, 0)
          seen.update(n, idx + 1)
          if (idx == 0) n else s"${n}${idx + 1}"
        }
      }
      val sendActions: List[SendAction] = edges.values().asScala
        .flatMap(_.asScala)
        .map(_.left)
        .flatMap {
          case a: GTVSend => Some(SendAction(a.op.toString, a.role.toString, a.pay.elems.size(), toVarNames(a.pay.elems)))
          case a: GTVSendStar => Some(SendAction(a.op.toString, a.role.toString, a.pay.elems.size(), toVarNames(a.pay.elems)))
          case _ => None
        }
        .toList

      val underMC = emitGC && mcDescendants.contains(s)
      val isEntry = emitGC && mcIds.contains(s)
      val mcIdAtom: String = mcIds.getOrElse(s, "mc")

      // Decide send-side tagging for MC entries by inspecting which sends belong to tau vs recv keys
      val tauSendPairs: Set[(String, String)] = edges.asScala.collect {
        case (k, v) if k.right.isInstanceOf[GTVTau] =>
          v.asScala.toList.flatMap { p => p.left match {
            case sa: GTVSend     => Some((sa.op.toString, sa.role.toString))
            case sa: GTVSendStar => Some((sa.op.toString, sa.role.toString))
            case _               => None
          }}
      }.flatten.toSet
      val recvSendPairs: Set[(String, String)] = edges.asScala.collect {
        case (k, v) if k.right.isInstanceOf[GTVRecv] =>
          v.asScala.toList.flatMap { p => p.left match {
            case sa: GTVSend     => Some((sa.op.toString, sa.role.toString))
            case sa: GTVSendStar => Some((sa.op.toString, sa.role.toString))
            case _               => None
          }}
      }.flatten.toSet

      def genSendVariant(opStr: String, roleName: String, varNames: List[String]): SendSpec = {
        val roleVar = capitalizeFirst(roleName) + "Pid"
        val arity = varNames.size
        val exportArity = 2 + arity
        val paramsList = (List(roleVar) ++ varNames :+ "_Data").mkString(", ")

        val payload = payloadTerm(opStr, varNames)
        val castTerm = if (underMC)
          s"{self(), ${payload}, Path}"
        else
          s"{self(), ${payload}}"

        val pathLine =
          if (underMC)
            "    Path = current_path(),\n"
          else
            ""

        val specLine =
          s"-spec send_${name}_${opStr}(${roleVar} :: pid()" +
            (if (arity > 0) ", " + varNames.map(_ => "term()").mkString(", ") else "") +
            ", _Data :: state_data()) -> ok."

        val body =
          s"""
             |${specLine}
             |send_${name}_${opStr}(${paramsList}) ->
             |${pathLine}    gen_statem:cast(${roleVar}, ${castTerm}).
             |""".stripMargin
        SendSpec(s"send_${name}_${opStr}", exportArity, body)
      }

      // Zero-arity compatibility variants per op/role
      val baseOps: List[(String, String)] = sendActions.map(sa => (sa.op, sa.role)).distinct
      val zeroVariants = baseOps.map { case (op, role) => genSendVariant(op, role, Nil) }

      // Arity-specific variants with named variables; dedupe by (op, role, arity)
      val arityVariants = sendActions
        .groupBy(sa => (sa.op, sa.role, sa.arity))
        .values
        .map(_.head)
        .toList
        .map(sa => genSendVariant(sa.op, sa.role, sa.varNames))

      // Deduplicate by (name, arity)
      (zeroVariants ++ arityVariants)
        .groupBy(ss => (ss.funcName, ss.exportArity))
        .values
        .map(_.head)
        .toList
    }

    val sendSpecs: List[SendSpec] = stateList.flatMap(buildSendSpecs)

    // ------------------- Callback contracts per state -------------------
    case class SigPieces(eventTypeUnion: String, msgArgUnion: String, retUnion: String)

    def buildCallbackSigPieces(state: GTVState): SigPieces = {
      val edges = org.scribble.ext.gt.codegen.erlang.GTGenUtil.filterEdgesByState(efsm, state)

      val tauOps = edges.keySet().asScala.map(_.right).collect{case t: GTVTau => t.op.toString}.toSet.toList.sorted

      case class RecvSig(role: String, op: String, arity: Int)
      val recvSigs = edges.keySet().asScala.map(_.right).collect{case r: GTVRecv => RecvSig(r.role.toString, r.op.toString, r.pay.elems.size())}.toSet.toList.sortBy(rs => (rs.role, rs.op, rs.arity))

      val eventTypeUnion = if (tauOps.nonEmpty && recvSigs.nonEmpty) "internal | cast" else if (tauOps.nonEmpty) "internal" else if (recvSigs.nonEmpty) "cast" else "gen_statem:event_type()"

      val internalArgTypes = tauOps.map(op => s"{${erlAtom(op)}}")
      val castArgTypes =
        recvSigs.map { rs => s"{pid(), ${payloadType(rs.op, rs.arity)}}" }
      val msgArgUnion = (internalArgTypes ++ castArgTypes) match { case Nil => "term()"; case single :: Nil => single; case many => many.mkString(" | ") }

      // Filter out end states from next_state union
      val succStates = edges.values().asScala.flatMap(_.asScala).map(_.right).toSet.toList
      val nextStates = succStates.filterNot(isEndState).map(s => s"s${s.id}").sorted
      val baseNexts = nextStates.map(ns => s"{next_state, ${ns}, state_data()}")
      val withActions = for { ns <- nextStates; l <- tauOps } yield s"{next_state, ${ns}, state_data(), [{next_event, internal, {${erlAtom(l)}}}] }"
      val extras = List("{keep_state, state_data()}", "{stop, normal, state_data()}")
      val retUnion = (baseNexts ++ withActions ++ extras).distinct match { case Nil => "{keep_state, state_data()}"; case xs => xs.mkString(" | ") }

      SigPieces(eventTypeUnion, msgArgUnion, retUnion)
    }

    def buildCallbackSpec(state: GTVState): String = {
      val sname = localName(state)
      val sig = buildCallbackSigPieces(state)
      s"-callback ${sname}(${sig.eventTypeUnion}, ${sig.msgArgUnion}, state_data()) -> ${sig.retUnion}."
    }

    // Build init callback return spec similar to Java GTErlGenUtil.getNextStateReturnType for succ = init
    val initEdgesAll = org.scribble.ext.gt.codegen.erlang.GTGenUtil.filterEdgesByState(efsm, efsm.init)
    val initTauOps: List[String] = initEdgesAll.keySet().asScala
      .map(_.right)
      .collect { case t: GTVTau => t.op.toString }
      .toList
    val initCallbackRetSpec: String =
      if (initTauOps.size == 1)
        s"{ok, ${initState}, state_data(), [{next_event, internal, {${erlAtom(initTauOps.head)}}}]}"
      else if (initTauOps.size > 1)
        s"{ok, ${initState}, state_data()} | {ok, ${initState}, state_data(), [gen_statem:action()]}"
      else
        s"{ok, ${initState}, state_data()}"

    val callbackDecls = (Seq(s"-callback init(Args :: list()) -> ${initCallbackRetSpec}.") ++ stateList.map(buildCallbackSpec)).mkString("\n")

    // Join Erlang clauses with ";\n" and end last with "."
    def joinClauses(clauses: List[String]): String =
      if (clauses.isEmpty) "" else clauses.mkString(";\n") + "."

    def cap1(s: String): String = if (s.isEmpty) s else s.head.toUpper.toString + s.tail

    // For building payload patterns in recv/postpone clauses
    def payloadPat(op: String, arity: Int, named: Boolean): String =
      if (arity == 0) s"{${erlAtom(op)}}"
      else if (arity == 1) (if (named) s"{${erlAtom(op)}, V1}" else s"{${erlAtom(op)}, _}")
      else "{%s, {%s}}".format(erlAtom(op), (1 to arity).map(i => if (named) s"V$i" else "_").mkString(", "))

    // ------------------- State functions -------------------
    def buildStateFunction(s: GTVState): String = {
      val sname = localName(s)
      val edges = org.scribble.ext.gt.codegen.erlang.GTGenUtil.filterEdgesByState(efsm, s)
      val events = edges.keySet().asScala.map(_.right)
      val isMCEntry = mcIds.contains(s)
      val underMC = mcDescendants.contains(s)
      val kind: StateKind = StateKind.fromJava(efsm, s)

      // If GC/path logic is disabled, treat all states as not-under-MC
      // This makes casts be {From, Msg} and removes stale/path purging
      val underMC0 = emitGC && underMC
      val isMCEntry0 = emitGC && isMCEntry

      // Precompute LR next-state sets for MC entry
      val lr = mcLR.getOrElse(s, LRMap(Set.empty, Set.empty))

      case class Key(kind: String, op: String, role: String, arity: Int)
      val seen = scala.collection.mutable.LinkedHashSet[Key]()

      val specificClauses: List[String] = events.flatMap {
        case e: GTVRecv =>
          val roleName = e.role.toString
          val roleVar = capitalizeFirst(roleName) + "Pid"
          val op = e.op.toString
          val arity = e.pay.elems.size()
          val k = Key("recv", op, roleName, arity)
          if (seen.contains(k)) None
          else {
            seen += k
            val rawNames = e.pay.elems.asScala.toList.map(x => capitalizeFirst(x.toString))
            val counts = scala.collection.mutable.LinkedHashMap.empty[String, Int]
            val varNames = rawNames.map { n =>
              val idx = counts.getOrElse(n, 0)
              counts.update(n, idx + 1)
              if (idx == 0) n else s"${n}${idx + 1}"
            }
            val payPatNamed = payloadPatNamed(op, varNames)

            val doublePat = s"{${roleVar}, ${payPatNamed}}"
            val triplePat = s"{${roleVar}, ${payPatNamed}, Path}"

            val gcCheckLine = if (underMC0) "    case stale(Path) of" else ""

            if (underMC0) Some((s"""
              |${sname}(cast, ${triplePat}, Data) ->
              |${gcCheckLine}
              |      true ->
              |        io:format("${genModule}[${sname}]: Purging stale event ~p~n", [${payPatNamed}]),
              |        {keep_state, Data};
              |      false ->
              |        CallbackModule = get(callback_module),
              |        Next = try CallbackModule:${sname}(cast, ${doublePat}, Data)
              |               catch error:function_clause ->
              |                 io:format("${genModule}[${sname}]: Callback had no clause for ~p, postponing~n", [${payPatNamed}]),
              |                 {keep_state, Data, [postpone]}
              |               end,
              |        case Next of
              |${{
                    val rightList = lr.right.toList.sorted
                    val leftOnly = (lr.left -- lr.right).toList.sorted
                    val lines =
                      rightList.map(ns => s"          {next_state, ${ns}, _} -> commit_entry(${mcIds(s)}, right), Next;") ++
                      rightList.map(ns => s"          {next_state, ${ns}, _, _} -> commit_entry(${mcIds(s)}, right), Next;") ++
                      leftOnly.map(ns => s"          {next_state, ${ns}, _} -> commit_entry(${mcIds(s)}, left), Next;") ++
                      leftOnly.map(ns => s"          {next_state, ${ns}, _, _} -> commit_entry(${mcIds(s)}, left), Next;") :+
                      "          _ -> Next"
                    lines.mkString("\n")
                  }}
              |        end
              |    end""".stripMargin).trim)
            else Some((s"""
              |${sname}(cast, ${doublePat}, Data) ->
              |    CallbackModule = get(callback_module),
              |    try CallbackModule:${sname}(cast, ${doublePat}, Data)
              |    catch error:function_clause ->
              |      io:format("${genModule}[${sname}]: Callback had no clause for ~p, ignoring~n", [${payPatNamed}]),
              |      {keep_state, Data}
              |    end""".stripMargin).trim)
          }

        case e: GTVTau =>
          val op = e.op.toString
          val k = Key("tau", op, "", 0)
          if (seen.contains(k)) None
          else {
            seen += k
            // Sending on the LHS is non-committing
            val commitCase: String = "        Next"
            Some((s"""
              |${sname}(internal, {${erlAtom(op)}}, Data) ->
              |    CallbackModule = get(callback_module),
              |    Next = CallbackModule:${sname}(internal, {${erlAtom(op)}}, Data),
              |        Next""".stripMargin).trim)
          }
        case _ => None
      }.toList

      // Build -spec for the state function: casts include Path only when emitGC && under mixed-choice regions
      val tauOpsForSpec = edges.keySet().asScala.map(_.right).collect{ case t: GTVTau => t.op.toString }.toSet.toList.sorted
      case class RecvSig(role: String, op: String, arity: Int)
      val recvSigsForSpec = edges.keySet().asScala.map(_.right).collect{ case r: GTVRecv => RecvSig(r.role.toString, r.op.toString, r.pay.elems.size()) }.toSet.toList

      val internalArgTypes = tauOpsForSpec.map(op => s"{${erlAtom(op)}}")
      val castArgTypesForSpec = recvSigsForSpec.map { rs =>
        if (underMC0) s"{pid(), ${payloadType(rs.op, rs.arity)}, list()}" else s"{pid(), ${payloadType(rs.op, rs.arity)}}"
      }

      val eventTypeUnion = if (tauOpsForSpec.nonEmpty && recvSigsForSpec.nonEmpty) "internal | cast" else if (tauOpsForSpec.nonEmpty) "internal" else if (recvSigsForSpec.nonEmpty) "cast" else "gen_statem:event_type()"
      val msgArgUnion = (internalArgTypes ++ castArgTypesForSpec) match {
        case Nil => "term()"
        case single :: Nil => single
        case many => many.mkString(" | ")
      }

      val sigRet = buildCallbackSigPieces(s).retUnion // same range of next_state outcomes
      val specLine = s"-spec ${sname}(${eventTypeUnion}, ${msgArgUnion}, state_data()) -> ${sigRet}."

      // -------- Postpone / purge clauses (selective receive) --------
      // Only needed under mixed-choice regions when emitGC=true, because those are the states
      // where Path-tagged messages can arrive "late" and would otherwise crash

      val specificallyHandledInThisState: Set[(String, String, Int)] =
        edges.keySet().asScala
          .map(_.right)
          .collect { case r: GTVRecv => (r.role.toString, r.op.toString, r.pay.elems.size()) }
          .toSet

      val postponeClauses: List[String] =
        if (!underMC0) {
          Nil
        } else {
          case class RecvKey(role: String, op: String, arity: Int, vars: List[String])

          // Use all receive signatures so we never miss a late message,
          // Skip those already specifically handled in this state.
          val keys: List[RecvKey] = {
            val seen = scala.collection.mutable.LinkedHashSet[(String, String, Int)]()
            val b = List.newBuilder[RecvKey]
            allRecvEvents.foreach { e =>
              val key = (e.role.toString, e.op.toString, e.pay.elems.size())
              if (!specificallyHandledInThisState.contains(key) && !seen.contains(key)) {
                seen += key
                val raw = e.pay.elems.asScala.toList.map(x => capitalizeFirst(x.toString))
                val counts = scala.collection.mutable.LinkedHashMap.empty[String, Int]
                val vars = raw.map { n =>
                  val idx = counts.getOrElse(n, 0)
                  counts.update(n, idx + 1)
                  if (idx == 0) n else s"${n}${idx + 1}"
                }
                b += RecvKey(e.role.toString, e.op.toString, e.pay.elems.size(), vars)
              }
            }
            b.result()
          }

          def payloadPatVars(op: String, arity: Int, vars: List[String]): String =
            arity match {
              case 0 => s"{${erlAtom(op)}}"
              case 1 => s"{${erlAtom(op)}, {${vars.headOption.getOrElse("V1")}}}"
              case _ => s"{${erlAtom(op)}, {" + vars.mkString(", ") + "}}"
            }

          keys.map { rk =>
            val roleVar = "_" + capitalizeFirst(rk.role) + "Pid"
            val pp = payloadPatVars(rk.op, rk.arity, rk.vars)
            s"""
               |${sname}(cast, {${roleVar}, ${pp}, Path}, Data) ->
               |    case stale(Path) of
               |      true ->
               |        io:format("${genModule}[${sname}]: Purging stale event ~p~n", [${pp}]),
               |        {keep_state, Data};
               |      false ->
               |        io:format("${genModule}[${sname}]: Postponing event ~p~n", [${pp}]),
               |        {keep_state, Data, [postpone]}
               |    end""".stripMargin.trim
          }
        }

      // when GC is enabled, a Path tagged message may arrive before the receiver
      // enters the mixed-choice region (e.g., sender tags at MC entry but receiver is still in a
      // pre-MC state)
      val preMcTripleSafety: List[String] =
        if (emitGC && !underMC0) {
          List(
            s"""
               |${sname}(cast, {_From, _Msg, Path}, Data) ->
               |    case stale(Path) of
               |      true ->
               |        io:format("${genModule}[${sname}]: Purging stale early-path event ~p~n", [_Msg]),
               |        {keep_state, Data};
               |      false ->
               |        io:format("${genModule}[${sname}]: Postponing early-path event ~p~n", [_Msg]),
               |        {keep_state, Data, [postpone]}
               |    end""".stripMargin.trim
          )
        } else Nil

      val clauses: List[String] = specificClauses ++ postponeClauses ++ preMcTripleSafety
      val comment = if (isMCEntry) "%% Mixed-choice entry state\n" else ""
      comment + specLine + "\n" + joinClauses(clauses) + "\n"
    }

    val stateFunctions = stateList.map(buildStateFunction).mkString("\n")

    val emitGcHelpers: Boolean = emitGC && mcStates.nonEmpty

    val gcHelpers: String =
      if (emitGcHelpers) {
        // Only emit current_path if we generate at least one send helper that builds a Path.
        val usesCurrentPath: Boolean = emitGC && sendSpecs.exists(_.code.contains("Path = current_path()"))

        val currentPathDecl =
          if (usesCurrentPath)
            """
              |%% current_path/0 is used only to annotate outgoing messages with the sender's
              |%% current MC context, when this role is inside an active mixed-choice region.
              |-spec current_path() -> [{atom(), left | right}].
              |current_path() ->
              |    Commit = get_commit(),
              |    lists:sort(maps:to_list(Commit)).
              |""".stripMargin
          else ""

        s"""
           |
           |%% ---------- GC / commitment helpers (per-mixed-choice side) ----------
           |%% We track, per MC id, which side this role is committed to: left | right.
           |%% Uncommitted MCs have no entry.
           |get_commit() -> case get(commit_map) of undefined -> #{}; M -> M end.
           |set_commit(M) -> put(commit_map, M), M.
           |
           |-spec commit_entry(atom(), left | right) -> map().
           |commit_entry(McId, Side) when Side =:= left; Side =:= right ->
           |    set_commit(maps:put(McId, Side, get_commit())).
           |
           |%% Staleness follows Section 4.1: a message is stale if, for some MC on its Path,
           |%% following the Path hits a stale side (i.e., we are committed to the opposite side).
           |%% We approximate local type commitment using the commit_map.
           |
           |-spec stale([{atom(), left | right}]) -> boolean().
           |stale(Path) when is_list(Path) ->
           |    Commit = get_commit(),
           |    lists:any(
           |      fun({Mc, MsgSide}) ->
           |        case maps:find(Mc, Commit) of
           |          error -> false; %% not committed => nothing is stale for this MC
           |          {ok, LocalSide} -> LocalSide =/= MsgSide
           |        end
           |      end, Path).
           |
           |${currentPathDecl.stripTrailing()}
           |""".stripMargin
      } else ""

    val content = s"""
      |%%%-------------------------------------------------------------------
      |%%% ${genModule}.erl — generated generic behaviour module (gen_statem)
      |%%%-------------------------------------------------------------------
      |-module(${genModule}).
      |-behaviour(gen_statem).
      |
      |%% Public API
      |-export([start_link/2, callback_mode/0]).
      |
      |%% gen_statem callbacks
      |-export([init/1, code_change/4, terminate/3${if (exportStates.nonEmpty) ",\n  " + exportStates else ""}${if (sendSpecs.nonEmpty) ",\n  " + sendSpecs.map(s => s.funcName + "/" + s.exportArity).mkString(",\n  ") else ""}]).
      |
      |%% Types & records
      |-include(\"${roleAtom}.hrl\").
      |-export_type([state_data/0]).
      |-type state_data() :: #state_data{}.
      |
      |${callbackDecls}
      |
      |%% ===== API =====
      |-spec start_link(CallbackModule :: module(), Args :: list()) ->
      |    {ok, pid()} | {error, term()}.
      |start_link(CallbackModule, Args) ->
      |    case code:ensure_loaded(CallbackModule) of
      |        {module, CallbackModule} ->
      |            gen_statem:start_link({local, CallbackModule}, ${genModule}, {CallbackModule, Args}, [{debug, [trace, {log_to_file, \"${roleAtom}_debug.log\"}]}]);
      |        {error, Reason} ->
      |            {error, Reason}
      |    end.
      |
      |-spec callback_mode() -> state_functions.
      |callback_mode() -> state_functions.
      |
      |%% ===== gen_statem =====
      |-spec init({module(), list()}) ->
      |    ${initCallbackRetSpec}.
      |init({CallbackModule, _Args}) ->
      |    io:format(\"${roleAtom}: Initializing with callback module ~p~n\", [CallbackModule]),
      |    put(callback_module, CallbackModule),
      |    ${if (emitGC) "set_commit(#{})," else "ok,"}
      |    CallbackModule:init([]).
      |
      |%% ---------- State functions----------
      |${stateFunctions}
      |
      |%% ---------- Send helpers----------
      |${sendSpecs.map(_.code).mkString("\n")}
      |
      |%% ===== misc OTP =====
      |-spec code_change(OldVsn :: term(), StateName :: atom(), StateData :: state_data(), Extra :: term()) ->
      |    {ok, state_data()}.
      |code_change(_Vsn, _StateName, StateData, _Extra) ->
      |    {ok, StateData}.
      |
      |-spec terminate(Reason :: term(), State :: atom(), Data :: state_data()) -> ok.
      |terminate(_Reason, _State, _StateData) ->
      |    ok.
      |${gcHelpers}
      |""".stripMargin

    val outFile = outDir.toPath.resolve(s"${genModule}.erl").toFile
    outFile.getParentFile.mkdirs()
    Files.write(outFile.toPath, content.getBytes(StandardCharsets.UTF_8))
    outFile
  }
}

