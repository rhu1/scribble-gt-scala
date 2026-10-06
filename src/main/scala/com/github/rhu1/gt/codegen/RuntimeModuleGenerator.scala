package com.github.rhu1.gt.codegen

import org.scribble.ext.gt.core.model.efsm.event.*
import org.scribble.ext.gt.core.model.efsm.{GTEFSM, GTVState}
import org.scribble.ext.gt.core.model.efsm.GTVRecVar

import java.io.File
import java.nio.charset.StandardCharsets
import java.nio.file.Files
import scala.jdk.CollectionConverters.*

/**
  * Generates the generic runtime module: gen_<role>.erl
  *  - Uses gen_statem behaviour in state_functions mode.
  *  - Path-based purging: receive triples {From, Label, Pi}, drop if stale(Pi).
  *  - External events are postponed (not dropped) to preserve selective receive,
  *   for recvs not handled directly in the current state.
  */
object RuntimeModuleGenerator {

  private sealed trait PathEffect
  private case object ContinuePath extends PathEffect
  private case object SelectLeft extends PathEffect
  private case object SelectRight extends PathEffect

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
    val mcIds: Map[GTVState, String] = mcStates.map(s => s -> s"mc${s.c}").toMap
    val mcByScope: Map[Int, GTVState] = mcStates.map(s => s.c -> s).toMap
    val emitGcHelpers: Boolean = emitGC && mcStates.nonEmpty

    val succCache = scala.collection.mutable.HashMap.empty[GTVState, List[GTVState]]
    def successors(s: GTVState): List[GTVState] = succCache.getOrElseUpdate(s, {
      val es = org.scribble.ext.gt.codegen.erlang.GTGenUtil.filterEdgesByState(efsm, s)
      es.values().asScala.toList
        .flatMap(_.asScala.map(_.right))
        .flatMap {
          case _: GTVRecVar => Nil
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

    val mcDescendants: Set[GTVState] =
      stateListAll.filter(s => mcByScope.contains(s.c)).toSet
    val mcDescendantsByEntry: Map[GTVState, Set[GTVState]] =
      mcStates.map { entry =>
        entry -> reachableFrom(entry).filter(s => s == entry || s.c != 0)
      }.toMap

    def enclosingMc(s: GTVState): Option[GTVState] =
      mcByScope.get(s.c)

    def pathEffect(source: GTVState, action: GTVAction): PathEffect = action match {
      case _: GTVSendStar | _: GTVEpsilonStar => SelectRight
      case _ if source.isEntry                => SelectLeft
      case _                                  => ContinuePath
    }

    def selectedSide(effect: PathEffect): Option[String] = effect match {
      case SelectLeft   => Some("left")
      case SelectRight  => Some("right")
      case ContinuePath => None
    }

    case class RecvKey(role: String, op: String, arity: Int)
    case class InterruptSpec(entry: GTVState, event: GTVRecv)

    val interruptSpecs: List[InterruptSpec] = mcStates.flatMap { entry =>
      val edges = org.scribble.ext.gt.codegen.erlang.GTGenUtil.filterEdgesByState(efsm, entry)
      edges.asScala.toList.flatMap { case (key, targets) =>
        key.right match {
          case recv: GTVRecv if targets.asScala.exists(_.left.isInstanceOf[GTVEpsilonStar]) =>
            Some(InterruptSpec(entry, recv))
          case _ => None
        }
      }
    }

    def recvKey(e: GTVRecv): RecvKey =
      RecvKey(e.role.toString, e.op.toString, e.pay.elems.size())

    def interruptFor(s: GTVState, key: RecvKey): Option[InterruptSpec] =
      interruptSpecs
        .filter(spec => recvKey(spec.event) == key && mcDescendantsByEntry(spec.entry).contains(s))
        .sortBy(_.entry.c)
        .lastOption

    val needsInterruptCommitHelper: Boolean = stateList.exists { state =>
      if (!emitGC || !mcDescendants.contains(state)) false
      else {
        val edges = org.scribble.ext.gt.codegen.erlang.GTGenUtil.filterEdgesByState(efsm, state)
        val handled = edges.keySet().asScala
          .map(_.right)
          .collect { case recv: GTVRecv => recvKey(recv) }
          .toSet
        interruptSpecs.exists { spec =>
          mcDescendantsByEntry(spec.entry).contains(state) && !handled.contains(recvKey(spec.event))
        }
      }
    }
    val needsDirectReceiveCommitHelper: Boolean = stateList.exists { state =>
      if (!emitGC || !mcDescendants.contains(state)) false
      else {
        val edges = org.scribble.ext.gt.codegen.erlang.GTGenUtil.filterEdgesByState(efsm, state)
        edges.entrySet().asScala.exists { edge =>
          edge.getKey.right.isInstanceOf[GTVRecv] &&
          edge.getValue.asScala.exists(pair => selectedSide(pathEffect(state, pair.left)).nonEmpty)
        }
      }
    }
    val needsCommitIfTakenHelper = needsInterruptCommitHelper || needsDirectReceiveCommitHelper

    // Export list: state functions and send helpers (only for non-end states)
    val exportStates = if (stateList.nonEmpty) stateList.map(s => localName(s) + "/3").mkString(",\n  ") else ""

    // ------------------- Send helpers -------------------
    case class SendSpec(funcName: String, exportArity: Int, code: String)

    def capitalizeFirst(s: String): String = if (s.isEmpty) s else s.head.toUpper.toString + s.tail

    def buildSendSpecs(s: GTVState): List[SendSpec] = {
      val name = localName(s)
      val edges = org.scribble.ext.gt.codegen.erlang.GTGenUtil.filterEdgesByState(efsm, s)
      case class SendAction(op: String, role: String, arity: Int, varNames: List[String], effect: PathEffect)
      def toVarNames(elems: java.util.List[?]): List[String] = {
        val raw = elems.asInstanceOf[java.util.List[AnyRef]].asScala.toList.map(x => capitalizeFirst(String.valueOf(x)))
        val seen = scala.collection.mutable.LinkedHashMap.empty[String, Int]
        raw.map { n =>
          val idx = seen.getOrElse(n, 0)
          seen.update(n, idx + 1)
          if (idx == 0) n else s"${n}${idx + 1}"
        }
      }
      val stateMcId = enclosingMc(s).flatMap(mcIds.get)
      def sendEffect(action: GTVAction): PathEffect =
        if (stateMcId.nonEmpty) pathEffect(s, action) else ContinuePath

      val sendActions: List[SendAction] = edges.values().asScala
        .flatMap(_.asScala)
        .map(_.left)
        .flatMap {
          case a: GTVSend =>
            Some(SendAction(a.op.toString, a.role.toString, a.pay.elems.size(), toVarNames(a.pay.elems), sendEffect(a)))
          case a: GTVSendStar =>
            Some(SendAction(a.op.toString, a.role.toString, a.pay.elems.size(), toVarNames(a.pay.elems), sendEffect(a)))
          case _ => None
        }
        .toList

      val underMC = emitGC && mcDescendants.contains(s)

      def uniqueEffect(actions: List[SendAction], op: String, role: String, arity: Option[Int]): PathEffect = {
        val effects = actions
          .filter(a => a.op == op && a.role == role && arity.forall(_ == a.arity))
          .map(_.effect)
          .distinct
        effects match {
          case effect :: Nil => effect
          case Nil => ContinuePath
          case many =>
            throw new IllegalStateException(
              s"Ambiguous path effects for send_${name}_${op}/${arity.getOrElse(0)}: ${many.mkString(", ")}"
            )
        }
      }

      def genSendVariant(opStr: String, roleName: String, varNames: List[String], effect: PathEffect): SendSpec = {
        val roleVar = capitalizeFirst(roleName) + "Pid"
        val arity = varNames.size
        val exportArity = 2 + arity
        val paramsList = (List(roleVar) ++ varNames :+ "_Data").mkString(", ")

        val payload = payloadTerm(opStr, varNames)
        val castTerm = if (underMC)
          s"{self(), ${payload}, Path}"
        else
          s"{self(), ${payload}}"

        val pathLine = if (underMC) {
          effect match {
            case SelectLeft =>
              val mcId = stateMcId.getOrElse(throw new IllegalStateException(s"Missing MC for left send at $s"))
              s"    Path = branch_path(${mcId}, left),\n    set_current_path(Path),\n"
            case SelectRight =>
              val mcId = stateMcId.getOrElse(throw new IllegalStateException(s"Missing MC for right send at $s"))
              s"    Path = branch_path(${mcId}, right),\n    commit_current(${mcId}, right),\n"
            case ContinuePath =>
              "    Path = current_path(),\n"
          }
        } else ""

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
      val zeroVariants = baseOps.map { case (op, role) =>
        genSendVariant(op, role, Nil, uniqueEffect(sendActions, op, role, None))
      }

      // Arity-specific variants with named variables; dedupe by (op, role, arity)
      val arityVariants = sendActions
        .groupBy(sa => (sa.op, sa.role, sa.arity))
        .values
        .map(_.head)
        .toList
        .map(sa => genSendVariant(
          sa.op,
          sa.role,
          sa.varNames,
          uniqueEffect(sendActions, sa.op, sa.role, Some(sa.arity))
        ))

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

    def transitionsFor(
        edges: java.util.Map[org.scribble.util.Pair[GTVState, GTVEvent], java.util.Set[org.scribble.util.Pair[GTVAction, GTVState]]],
        event: GTVEvent
    ): List[(GTVAction, GTVState)] =
      edges.asScala.toList
        .filter(_._1.right == event)
        .flatMap(_._2.asScala.toList.map(p => (p.left, p.right)))

    def incomingPathEffect(source: GTVState, transitions: List[(GTVAction, GTVState)]): PathEffect =
      if (transitions.nonEmpty && transitions.forall(_._1.isInstanceOf[GTVEpsilonStar])) SelectRight
      else if (source.isEntry) SelectLeft
      else ContinuePath

    def expectedPath(effect: PathEffect, mcId: String): String = effect match {
      case SelectLeft   => s"branch_path(${mcId}, left)"
      case SelectRight  => s"branch_path(${mcId}, right)"
      case ContinuePath => "current_path()"
    }

    def afterTransition(next: String): String =
      if (emitGcHelpers) s"after_transition(${next})" else next

    def receiveResultHandling(s: GTVState, event: GTVRecv, next: String): String = {
      val edges = org.scribble.ext.gt.codegen.erlang.GTGenUtil.filterEdgesByState(efsm, s)
      val transitions = transitionsFor(edges, event)
      val mcId = enclosingMc(s).flatMap(mcIds.get)

      mcId match {
        case None => afterTransition(next)
        case Some(id) =>
          def commitAndTransition(side: String): String =
            afterTransition(s"commit_if_taken(${next}, ${id}, ${side})")

          val rightTargets = transitions.collect {
            case (action, target) if pathEffect(s, action) == SelectRight && !isEndState(target) => localName(target)
          }.toSet
          val leftTargets = transitions.collect {
            case (action, target) if pathEffect(s, action) == SelectLeft && !isEndState(target) => localName(target)
          }.toSet -- rightTargets
          val endEffects = transitions.collect {
            case (action, target) if isEndState(target) => pathEffect(s, action)
          }.toSet

          val targetCases =
            rightTargets.toList.sorted.flatMap(ns => List(
              s"          {next_state, ${ns}, _} -> ${commitAndTransition("right")};",
              s"          {next_state, ${ns}, _, _} -> ${commitAndTransition("right")};"
            )) ++
            leftTargets.toList.sorted.flatMap(ns => List(
              s"          {next_state, ${ns}, _} -> ${commitAndTransition("left")};",
              s"          {next_state, ${ns}, _, _} -> ${commitAndTransition("left")};"
            ))

          val stopCases = endEffects.toList match {
            case SelectLeft :: Nil  => List(s"          {stop, _, _} -> ${commitAndTransition("left")};")
            case SelectRight :: Nil => List(s"          {stop, _, _} -> ${commitAndTransition("right")};")
            case _                  => Nil
          }

          (targetCases ++ stopCases :+ s"          _ -> ${afterTransition(next)}").mkString("\n")
      }
    }

    // ------------------- State functions -------------------
    def buildStateFunction(s: GTVState): String = {
      val sname = localName(s)
      val edges = org.scribble.ext.gt.codegen.erlang.GTGenUtil.filterEdgesByState(efsm, s)
      val events = edges.keySet().asScala.map(_.right)
      val isMCEntry = mcIds.contains(s)
      val underMC = mcDescendants.contains(s)
      // If GC/path logic is disabled, treat all states as not-under-MC
      // This makes casts be {From, Msg} and removes stale/path purging
      val underMC0 = emitGC && underMC
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

            val recvTransitions = transitionsFor(edges, e)
            val receiveExpectedPath = enclosingMc(s).flatMap(mcIds.get) match {
              case Some(id) => expectedPath(incomingPathEffect(s, recvTransitions), id)
              case None => "current_path()"
            }

            if (underMC0) Some((s"""
              |${sname}(cast, ${triplePat}, Data) ->
              |    case message_status(Path, ${receiveExpectedPath}) of
              |      stale ->
              |        io:format("${genModule}[${sname}]: Purging stale event ~p~n", [${payPatNamed}]),
              |        {keep_state, Data};
              |      ready ->
              |        CallbackModule = get(callback_module),
              |        Next = try CallbackModule:${sname}(cast, ${doublePat}, Data)
              |               catch error:function_clause ->
              |                 io:format("${genModule}[${sname}]: Callback had no clause for ~p, postponing~n", [${payPatNamed}]),
              |                 {keep_state, Data, [postpone]}
              |               end,
              |        case Next of
              |${receiveResultHandling(s, e, "Next")}
              |        end;
              |      not_ready ->
              |        io:format("${genModule}[${sname}]: Postponing not-ready event ~p~n", [${payPatNamed}]),
              |        {keep_state, Data, [postpone]}
              |    end""".stripMargin).trim)
            else Some((s"""
              |${sname}(cast, ${doublePat}, Data) ->
              |    CallbackModule = get(callback_module),
              |    Next = try CallbackModule:${sname}(cast, ${doublePat}, Data)
              |           catch error:function_clause ->
              |             io:format("${genModule}[${sname}]: Callback had no clause for ~p, ignoring~n", [${payPatNamed}]),
              |             {keep_state, Data}
              |           end,
              |    ${afterTransition("Next")}""".stripMargin).trim)
          }

        case e: GTVTau =>
          val op = e.op.toString
          val k = Key("tau", op, "", 0)
          if (seen.contains(k)) None
          else {
            seen += k
            Some((s"""
              |${sname}(internal, {${erlAtom(op)}}, Data) ->
              |    CallbackModule = get(callback_module),
              |    Next = CallbackModule:${sname}(internal, {${erlAtom(op)}}, Data),
              |    ${afterTransition("Next")}""".stripMargin).trim)
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
          case class PendingRecv(role: String, op: String, arity: Int, vars: List[String])

          // Use all receive signatures so we never miss a late message,
          // Skip those already specifically handled in this state.
          val keys: List[PendingRecv] = {
            val seen = scala.collection.mutable.LinkedHashSet[(String, String, Int)]()
            val b = List.newBuilder[PendingRecv]
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
                b += PendingRecv(e.role.toString, e.op.toString, e.pay.elems.size(), vars)
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
            val roleVar = capitalizeFirst(rk.role) + "Pid"
            val pp = payloadPatVars(rk.op, rk.arity, rk.vars)
            interruptFor(s, RecvKey(rk.role, rk.op, rk.arity)) match {
              case Some(interrupt) =>
                val entryName = localName(interrupt.entry)
                val mcId = mcIds(interrupt.entry)
                s"""
                   |${sname}(cast, {${roleVar}, ${pp}, Path}, Data) ->
                   |    case message_status(Path, branch_path(${mcId}, right)) of
                   |      stale ->
                   |        io:format("${genModule}[${sname}]: Purging stale interrupt ~p~n", [${pp}]),
                   |        {keep_state, Data};
                   |      ready ->
                   |        CallbackModule = get(callback_module),
                   |        Next = try CallbackModule:${entryName}(cast, {${roleVar}, ${pp}}, Data)
                   |               catch error:function_clause ->
                   |                 io:format("${genModule}[${sname}]: Callback had no interrupt clause for ~p, postponing~n", [${pp}]),
                   |                 {keep_state, Data, [postpone]}
                   |               end,
                   |        after_transition(commit_if_taken(Next, ${mcId}, right));
                   |      not_ready ->
                   |        io:format("${genModule}[${sname}]: Postponing not-ready interrupt ~p~n", [${pp}]),
                   |        {keep_state, Data, [postpone]}
                   |    end""".stripMargin.trim
              case None =>
                s"""
                   |${sname}(cast, {_${roleVar}, ${pp}, Path}, Data) ->
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

    val gcHelpers: String =
      if (emitGcHelpers) {
        val afterTransitionClauses = mcStates.flatMap { entry =>
          val stateName = localName(entry)
          val mcId = mcIds(entry)
          List(
            s"after_transition({next_state, ${stateName}, _} = Next) -> enter_mc(${mcId}), Next",
            s"after_transition({next_state, ${stateName}, _, _} = Next) -> enter_mc(${mcId}), Next"
          )
        } :+ "after_transition(Next) -> Next"
        val commitIfTakenHelper =
          if (needsCommitIfTakenHelper) {
            """
              |commit_if_taken(Next, McId, Side) ->
              |    case Next of
              |      {keep_state, _} -> Next;
              |      {keep_state, _, _} -> Next;
              |      _ -> commit_current(McId, Side), Next
              |    end.
              |""".stripMargin
          } else ""

        s"""
           |
           |get_commit() -> case get(commit_map) of undefined -> #{}; M -> M end.
           |set_commit(M) -> put(commit_map, M), M.
           |
           |init_context() ->
           |    set_current_path([]),
           |    set_commit(#{}),
           |    ok.
           |
           |-spec current_path() -> [left | right].
           |current_path() -> case get(mc_path) of undefined -> []; Path -> Path end.
           |
           |set_current_path(Path) -> put(mc_path, Path), Path.
           |
           |enter_mc(McId) ->
           |    Prefix = current_path(),
           |    set_commit(maps:put(Prefix, {McId, none}, get_commit())),
           |    ok.
           |
           |active_prefix(McId) ->
           |    Current = current_path(),
           |    Candidates = lists:filtermap(
           |      fun({Prefix, {FrameMc, _Side}}) ->
           |        case FrameMc =:= McId andalso lists:prefix(Prefix, Current) of
           |          true -> {true, {length(Prefix), Prefix}};
           |          false -> false
           |        end
           |      end, maps:to_list(get_commit())),
           |    case Candidates of
           |      [] -> error({missing_mixed_choice, McId, Current});
           |      _ -> element(2, lists:max(Candidates))
           |    end.
           |
           |branch_path(McId, Side) when Side =:= left; Side =:= right ->
           |    active_prefix(McId) ++ [Side].
           |
           |commit_current(McId, Side) when Side =:= left; Side =:= right ->
           |    Prefix = active_prefix(McId),
           |    set_commit(maps:put(Prefix, {McId, Side}, get_commit())),
           |    set_current_path(Prefix ++ [Side]),
           |    ok.
           |
           |${commitIfTakenHelper}
           |${afterTransitionClauses.mkString(";\n")}.
           |
           |message_status(Path, Expected) ->
           |    case stale(Path) of
           |      true -> stale;
           |      false when Path =:= Expected -> ready;
           |      false -> not_ready
           |    end.
           |
           |-spec stale([left | right]) -> boolean().
           |stale(Path) when is_list(Path) -> stale(Path, [], get_commit()).
           |
           |stale([], _Prefix, _Frames) -> false;
           |stale([Side | Rest], Prefix, Frames) ->
           |    case maps:find(Prefix, Frames) of
           |      {ok, {_McId, Commit}} when Commit =/= none, Commit =/= Side -> true;
           |      _ -> stale(Rest, Prefix ++ [Side], Frames)
           |    end.
           |""".stripMargin
      } else ""

    val initGcSetup: String =
      if (emitGcHelpers) {
        val enterInitial = mcIds.get(efsm.init).map(id => s"    enter_mc(${id}),\n").getOrElse("")
        s"    init_context(),\n${enterInitial}"
      } else {
        "    ok,\n"
      }

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
      |${initGcSetup.stripTrailing()}
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
