package com.github.rhu1.gt.`type`.session.global

import com.github.rhu1.gt.`type`.session.*
import com.github.rhu1.gt.`type`.session.local.*
import com.github.rhu1.gt.util.{ConsoleColours, PipeForwards}

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

    private val cont: ListMap[(Op, Payload), GType] = this.cases.filter(_._1 == this.op)

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

    override def rprojectAux(pi: Path, r: Role): Option[(LType, Sigma)] =
        for {
            (cases, sigmas) <- this.cases.foldLeft
                                   (Option((ListMap.empty[(Op, Payload), LType], ListMap.empty[Op, Sigma]))) {
                                       case (None, _) => None
                                       case (Some(acc), (k, g)) =>
                                           g.rprojectAux(pi, r).map(y => (acc._1 + ((k, y._1)), acc._2 + ((k._1 -> y._2))))
                                   }
            head <- this.cont.headOption
            res <-
                if (r == this.src) {
                    val filt = sigmas.filter((k, _) => k != this.op).values.toSet
                    if (filt.size != 1 || filt.head.nonEmpty) {  // !!! cf. no check
                        None
                    } else {
                        Some((cases(head._1), sigmas(this.op)))
                    }
                } else if (r == this.dst) {
                    val filt = sigmas.filter((k, _) => k != this.op).values.toSet
                    if (filt.size != 1 || filt.head.nonEmpty) {  // !!! cf. just pairwise equal
                        None
                    } else {
                        val s: Sigma = sigmas(this.op)
                        if (s.contains(this.src)) {
                            val s1: Sigma = s +
                                (this.src -> (Msg(this.op, pi) :: s(this.src)))  // Empty already checked
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

    override def getActions: Set[GAction] =
        val cont = this.cont.head
        Set(GRecv(this.src, this.dst, this.op, cont._1._2)) union
            cont._2.getActions.filter {
                case x: GIO => x.src != this.dst && x.dst != this.dst
                case _ => false
            }

    override def step(com: Map[Mid, Set[Op]], a: GAction): Either[String, GType] = a match {
        case GRecv(src, dst, op, pay) =>
            if (dst == this.dst) {
                if (src != this.src || dst != this.dst || op != this.op) {
                    Left(s"Cannot step $a in: $this")
                } else {
                    this.cont.find((k, _) => k == (op, pay)) match {   // ...only checking pay
                        case None => Left(s"Cannot step $a in: $this")
                        case Some((_, x)) => Right(x)
                    }
                }
            } else {
                stepNested(com, a)
            }
        case _ => stepNested(com, a)
    }

    protected def stepNested(com: Map[Mid, Set[Op]], a: GAction): Either[String, GType] =
        this.cont.head._2.step(com, a)


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
        s"${this.src} ${ConsoleColours.RIGHT_ARROW} ${this.dst} $this.op ${casesToString}"
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
        GActiveMixed(this.id, this.left.subs(x), this.other, this.obs, this.comL, this.comR, this.right.subs(x))

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

    override def rprojectAux(pi: Path, r: Role): Option[(LType, Sigma)] =
        if (this.comL contains r) {
            this.left.rprojectAux(pi :+ pL, r) map {
                case (p, s) => (LActiveLeft(this.id, p), s)
            }
        } else if (this.comR contains r) {
            this.right.rprojectAux(pi :+ pR, r) map {
                case (p, s) => (LActiveRight(this.id, p), s)
            }
        } else {
            for {
               left <- this.left.rprojectAux(pi :+ pL, r)
               right <- this.right.rprojectAux(pi :+ pR, r)
               circ <- left._2.circ(right._2)
            } yield (
                LActiveMixed(this.id, left._1, this.obs, right._1), circ)
        }


        /* ... */

    override def getActions: Set[GAction] =
        val left = this.left.getActions.filter({
            case GSend(src, _, _, _) => !comR.contains(src)
            case GRecv(src, dst, op, pay) => !comR.contains(dst)
            case GNu(_) => comR != getLiveRoles
        })
        val right = this.right.getActions.filter({
            case GSend(src, _, _, _) => !comL.contains(src)
            case GRecv(src, dst, op, pay) => true
            case GNu(_) => this.comL.isEmpty
        })
        left union right

    override def step(com: Map[Mid, Set[Op]], a: GAction): Either[String, GActiveMixed] =
        val R = getLiveRoles
        val left = this.left.step(com, a)
        val right = this.right.step(com, a)
        (left, right) match {
            case (Right(x), Left(_)) => a match {
                case GSend(src, _, _, _) =>
                    if (comR.contains(src)) {
                        Left("Cannot step $a in: $this")
                    } else {
                       Right(GActiveMixed(this.id, x, this.other, this.obs, this.comL, this.comR, this.right))
                    }
                case GRecv(_, dst, op, pay) =>
                    if (comR.contains(dst)) {
                        Left("Cannot step $a in: $this")
                    } else {
                        val comL1 = if (com(this.id).contains(op)) this.comL else this.comL + dst
                        Right(GActiveMixed(this.id, x, this.other, this.obs, comL1, this.comR, this.right))
                    }
                case GNu(_) => if (this.comR == R) Left("Cannot step $a in: $this") else
                    Right(GActiveMixed(this.id, x, this.other, this.obs, this.comL, this.comR, this.right))
            }
            case (Left(_), Right(x)) => a match {
                case GSend(src, _, _, _) =>
                    if (comL.contains(src)) {
                        Left("Cannot step $a in: $this")
                    } else {
                        val comR1 = this.comR + src
                        Right(GActiveMixed(this.id, x, this.other, this.obs, this.comL, comR1, this.right))
                    }
                case GRecv(_, dst, op, pay) =>
                    if (comR.contains(dst)) {  // !!! cf. defs
                        Left("Cannot step $a in: $this")
                    } else {
                        val comR1 = this.comR + dst
                        Right(GActiveMixed(this.id, x, this.other, this.obs, this.comL, comR1, this.right))
                    }
                case GNu(_) => if (this.comL.nonEmpty) Left("Cannot step $a in: $this") else
                    Right(GActiveMixed(this.id, this.left, this.other, this.obs, this.comL, this.comR, x))
            }
            case _ => Left("Cannot step $a in: $this")
        }
    //.map(x => GActiveMixed(this.id, x, this.other, this.obs, ))


    /* ... */

    override def toString: String =
        s"[${this.left} $comL ${ConsoleColours.WHITE_TRIANGLE}${id}_${this.other},${this.obs} $comR ${this.right}]"
}


/* ... */

sealed trait GAction { }
sealed abstract class GIO extends GAction {
    val src: Role
    val dst: Role
    val op: Op
    val pay: Payload
}
case class GSend(src: Role, dst: Role, op: Op, pay: Payload) extends GIO {
    override def toString: String = s"$src!$dst:$op($pay)"
}
case class GRecv(src: Role, dst: Role, op: Op, pay: Payload) extends GIO {
    override def toString: String = s"$src?$dst:$op($pay)"  // pq?a -- p is sender
}
// !!! c
case class GNu(c: Mid) extends GAction {}


/* ... */

