package com.github.rhu1.gt.`type`.session.global

import com.github.rhu1.gt.`type`.session.*
import com.github.rhu1.gt.`type`.session.local.*
import com.github.rhu1.gt.util.ConsoleColours

import scala.collection.immutable.ListMap


// Means runtime only
trait GRuntimeType extends GType {

    override protected[global] def isBalancedAux: Boolean =
        throw new RuntimeException(s"Invalid for runtime types: $this")

    /* ... */

    override def getCommittingAux(entered: Boolean, c: Mid, com: Set[Role]): Map[Role, Set[Op]] =
        throw new RuntimeException(s"Invalid for runtime types: $this")

    override def getNotCommittingAux(entered: Boolean, c: Mid, com: Set[Role]): Map[Role, Set[Op]] =
        throw new RuntimeException(s"Invalid for runtime types: $this")

    override def getSyntacticStrictDeps: Map[Role, Set[Role]] =
        throw new RuntimeException(s"Invalid for runtime types: $this")

    override def getSyntacticEventualDeps: Map[Role, Set[Role]] =
        throw new RuntimeException(s"Invalid for runtime types: $this")

    override def isSingleDecision: Boolean =
        throw new RuntimeException(s"Invalid for runtime types: $this")

    override def isClearTermination: Boolean =
        throw new RuntimeException(s"Invalid for runtime types: $this")

}



/* ... */

case class GWiggly(
           src: Role,
           dst: Role,
           op: Op,
           cases: ListMap[(Op, Payload), GType]
       ) extends GRuntimeType {

    private val cont: ListMap[(Op, Payload), GType] =
        this.cases filter { case ((op, _), _) => op == this.op }

    /* ... */

    override def subs(x: Map[RecVar, GType]): GWiggly =
        GWiggly(this.src, this.dst, this.op, this.cont.map((k, v) => (k, v.subs(x))))

    override def unfoldAllOnceAux(done: Set[RecVar]): GWiggly =
        GWiggly(this.src, this.dst, this.op,
            this.cont.map((k, v) => (k, v.unfoldAllOnceAux(done))))

    override def isDivergingAux(entered: Set[RecVar], r: Role): Boolean =
        this.cont.forall(x => x._2.isDivergingAux(entered, r))

    override def getLiveRoles: Set[Role] = Set(this.dst) ++ this.cont.flatMap(_._2.getLiveRoles)

    override def getMids: Set[Mid] = this.cont.flatMap(_._2.getMids).toSet

    /* ... */

    /* ... */

    override def rprojectAux(all: Set[Role], pi: Path, r: Role): Option[(LType, Sigma)] =
        for {
            (cases, sigmas) <-
                this.cases.foldLeft
                    (Option[(ListMap[(Op, Payload), LType], ListMap[Op, Sigma])](ListMap.empty, ListMap.empty)) {
                       case (None, _) => None
                       case (Some(acc), (k, g)) =>
                           g.rprojectAux(all, pi, r)
                            .map((L, q) => (acc._1 + ((k, L)), acc._2 + (k._1 -> q)))
                   }
            head <- this.cont.headOption  // head._1._1 == this.op
            res <-
                if (r == this.src) {
                    val filt = sigmas.filter((k, _) => k != this.op).values.toSet
                    //println(s"eeee1: $r ,, $filt")
                    if ((filt.size == 1 && !filt.head.isEmptyQueues)  // !!! all non this.op cases if any, cf. not checked
                            || filt.size >= 2) {
                        None
                    } else {
                        //println(s"eeee2: $r")
                        Some((cases(head._1), sigmas(this.op)))
                    }
                } else if (r == this.dst) {
                    val filt = sigmas.filter((k, _) => k != this.op).values.toSet
                    if ((filt.size == 1 && !filt.head.isEmptyQueues)  // !!! all non this.op cases if any, cf. just pairwise equal
                            || filt.size >= 2) {
                        None
                    } else {
                        val s: Sigma = sigmas(this.op)
                        if (s.contains(this.src)) {
                            val s1: Sigma = s +
                                (this.src -> (Msg(this.op, head._1._2, pi) :: s(this.src)))  // Empty already guarded
                            Some((LBranch(this.src, cases), s1))
                        } else {
                            None
                        }
                    }
                } else {
                    for {
                        cc <- cases.values.tail.foldLeft(Option(cases.values.head)) {  // cases non-empty
                            case (None, _) => None
                            case (Some(acc), x) => LType.merge(acc, x)
                        }
                        ss <- sigmas.values.tail.foldLeft(Option(sigmas.values.head)) {
                            case (None, _) => None
                            case (Some(acc), x) => LType.mergeSigma(acc, x)  // !!! cf. defs
                        }
                    } yield (cc, ss)
                }
        } yield res

    /* ... */

    override def getActionsAux(env: Path, rem: Set[Role]): Set[GAction] =
        val cont = this.cont.head
        val curr =
            if (rem.contains(this.dst)) {
                Set(GRecv(env, this.src, this.dst, this.op, cont._1._2))
            } else {
                Set.empty
            }
        val rem1 = rem - this.dst
        val nested = if (rem1.isEmpty) Set.empty else cont._2.getActionsAux(env, rem1)
        curr ++ nested

    override def stepPiAux(com: Map[Role, Map[Mid, Set[Op]]], env: Path, entered: Set[RecVar], a: GAction):
            Either[String, (GType, Path)] =
        a match {
            case GRecv(pi, src, dst, op, pay) =>
                if (dst == this.dst) {
                    if (pi != env || src != this.src || op != this.op) {
                        Left(s"Cannot step $a in: $this")
                    } else { // Rcv
                        this.cont.find((k, _) => k == (op, pay)) match { // ...only checking pay
                            case None => Left(s"Cannot step $a in: $this")
                            case Some((_, x)) => Right((x, pi))
                        }
                    }
                } else {
                    stepPiAuxNested(com, env, entered, a)
                }
            case _ => stepPiAuxNested(com, env, entered, a)
        }

    protected def stepPiAuxNested(com: Map[Role, Map[Mid, Set[Op]]], env: Path, entered: Set[RecVar], a: GAction):
            Either[String, (GType, Path)] =
        if (this.dst == a.subj) {
            Left(s"Cannot step $a in: $this")
        } else {
            val h = this.cont.head
            h._2.stepPiAux(com, env, entered, a).map(x =>
                (GWiggly(this.src, this.dst, this.op, this.cases + (h._1 -> x._1)), x._2))  // x._2 == a.pi
        }

    /*override def step(com: Map[Role, Map[Mid, Set[Op]]], a: GAction): Either[String, GType] =
        stepPi(com, a).map((G, _) => G)*/

    override def isSafeTermination(all: Set[Role]): Boolean = true

    /* ... */

    def casesToString: String =
        def msgToString(x: (Op, Payload)) = s"${x._1}(${x._2})"
        if (cases.size == 1) {
            val c = cases.head
            s"${msgToString(c._1)} . ${c._2}"
        } else {
            val tmp = this.cases.map((x, y) => s"${msgToString(x)}: ${y}").mkString(", ")
            s"{${tmp}}"
        }

    override def toString: String =
        s"${this.src} ${ConsoleColours.WAVE_ARROW} ${this.dst} ${this.op} ${casesToString}"
}


/* ... */

class GActiveMixed(
        id: Mid,
        left: GType,
        other: Role,
        obs: Role,
        comL: Set[Role],
        comR: Set[Role],
        right: GType
    ) extends GRuntimeType {

    /* ... */

    override def subs(x: Map[RecVar, GType]): GActiveMixed =
        GActiveMixed(this.id, this.left.subs(x), this.other, this.obs,
            this.comL, this.comR, this.right.subs(x))

    override def unfoldAllOnceAux(done: Set[RecVar]): GActiveMixed =
        GActiveMixed(id, this.left.unfoldAllOnceAux(done), this.other, this.obs,
            this.comL, this.comR, this.right.unfoldAllOnceAux(done))

    override def isDivergingAux(entered: Set[RecVar], r: Role): Boolean =
        this.left.isDivergingAux(entered, r) && this.right.isDivergingAux(entered, r)

    override def getLiveRoles: Set[Role] =
        (this.left.getLiveRoles -- this.comR) ++ (this.right.getLiveRoles -- this.comL)

    override def getMids: Set[Mid] = this.left.getMids ++ this.right.getMids + this.id

    /* ... */

    /* ... */

    override def rprojectAux(all: Set[Role], pi: Path, r: Role): Option[(LType, Sigma)] =
        println(s"bbbbb1: $r ,, $this")
        if (this.comL contains r) {
            //println(s"ccccc1: $this ,, $r")
            this.left.rprojectAux(all, pi :+ pL, r) map {
                case (_L, q) => (LActiveLeft(this.id, _L), q)
            }
        } else if (this.comR contains r) {
            //println(s"ccccc2: $this ,, $r")
            this.right.rprojectAux(all, pi :+ pR, r) map {
                case (_L, q) => (LActiveRight(this.id, _L), q)
            }
        } else {
            for {
               left <- {
                   println(s"bbbbb2: ${this.left.rprojectAux(all, pi :+ pL, r)}");
                   this.left.rprojectAux(all, pi :+ pL, r)
               }
               right <- {
                   println(s"bbbbb3: ${this.right.rprojectAux(all, pi :+ pR, r)}");
                   this.right.rprojectAux(all, pi :+ pR, r)
               }
               s <- {
                   //println(s"bbbbb4: ${left._2 circ right._2}")
                   left._2 circ right._2
               }
            } yield (
                LActiveMixed(this.id, left._1, right._1), s)
        }

    /*protected def inferPeer(x: LType): Role =
        x match {
            case x: LSelect => x.dst
            case x: LBranch => x.src
            case x: LMixed =>
                (inferPeer(x.left), inferPeer(x.right)) match {
                    case (l, r) if l == r => l
                    case (l, r) => throw new RuntimeException(s"Shouldn't get here l=$l, r=$r in: $x")
                }
            case x: LActiveMixed =>
                (inferPeer(x.left), inferPeer(x.right)) match {
                    case (l, r) if l == r => l
                    case (l, r) => throw new RuntimeException(s"Shouldn't get here l=$l, r=$r in: $x")
                }
            case x: LActiveLeft => inferPeer(x.left)
            case x: LActiveRight => inferPeer(x.right)
            case x: LRec => inferPeer(x.unfold)
            case x: LRecVar => throw new RuntimeException(s"Shouldn't get here: $x")
            case LEnd => ???  // XXX cannot infer directly
            _ => throw new RuntimeException(s"Shouldn't get here: $x")
        }*/

    /* ... */

    override def getActionsAux(env: Path, rem: Set[Role]): Set[GAction] =
        val left = this.left.getActionsAux(env :+ pL, rem).filter({
            case GSend(_, src, _, _, _) => !comR.contains(src)
            case GRecv(_, _, dst, _, _) => !comR.contains(dst)
            case GNu(_, _) => comR != getLiveRoles  // ...allow instantiation as long as someone not committed
        })
        val right = this.right.getActionsAux(env :+ pR, rem).filter({
            case GSend(_, src, _, _, _) => !comL.contains(src)
            case GRecv(_, _, dst, _, _) => !comL.contains(dst)
            case GNu(_, _) => this.comL.isEmpty
        })
        left union right

    override def stepPiAux(com: Map[Role, Map[Mid, Set[Op]]], env: Path, entered: Set[RecVar], a: GAction):
            Either[String, (GActiveMixed, Path)] =
        val R = getLiveRoles
        val left = this.left.stepPiAux(com, env :+ pL, entered, a)
        val right = this.right.stepPiAux(com, env :+ pR, entered, a)
        (left, right) match {
            case (Right(_G, pi), Left(_)) =>  // pi == a.pi
                a match {
                    case GSend(_, src, _, _, _) if !comR.contains(src) => // LSnd
                        Right((GActiveMixed(this.id, _G, this.other,
                            this.obs, this.comL, this.comR, this.right), pi))
                    case GRecv(_, _, dst, op, pay) if !comR.contains(dst) =>
                        val comL1 =
                            if (com(dst)(this.id).contains(op)) { // LRcv1
                                this.comL + dst
                            } else { // LRcv2
                                this.comL
                            }
                        Right((GActiveMixed(this.id, _G, this.other,
                            this.obs, comL1, this.comR, this.right), pi))
                    case GNu(_, _) if this.comR != R => // !!! LNu -- ...allow instantiation as long as someone not committed
                        Right((GActiveMixed(this.id, _G, this.other, this.obs,
                            this.comL, this.comR, this.right), pi))
                    case _ => Left(s"Cannot step $a in: $this")
                }
            case (Left(_), Right(_G, pi)) =>  // pi == a.pi
                a match {
                    case GSend(_, src, _, _, _) if !comL.contains(src) =>  // RSnd
                        val comR1 = this.comR + src
                        Right((GActiveMixed(this.id, this.left, this.other,
                            this.obs, this.comL, comR1, _G), pi))
                    case GRecv(_, _, dst, op, pay) if !comL.contains(dst) =>  // RRcv // !!! cf. defs
                        val comR1 = this.comR + dst
                        Right((GActiveMixed(this.id, this.left, this.other, this.obs,
                            this.comL, comR1, _G), pi))
                    case GNu(_, _) if this.comL.isEmpty =>  // !!! RNu
                        Right((GActiveMixed(this.id, this.left, this.other,
                            this.obs, this.comL, this.comR, _G), pi))
                    case _ => Left(s"Cannot step $a in: $this")
                }
            case _ => Left(s"Cannot step $a in: $this")
        }

    /*override def step(com: Map[Role, Map[Mid, Set[Op]]], a: GAction):
            Either[String, GActiveMixed] =
        stepPi(com, a).map((G, _) => G)*/

    override def isSafeTermination(all: Set[Role]): Boolean =
        if (this.comL == all) {
            this.left.isSafeTermination(all)
        } else if (this.comR == all) {
            this.right.isSafeTermination(all)
        } else {
            false
        }

    /* ... */

    override def toString: String =
        s"[${this.left} $comL ${ConsoleColours.BLACK_TRIANGLE}${id}_${this.other},${this.obs} $comR ${this.right}]"
}
