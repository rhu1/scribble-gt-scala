package com.github.rhu1.gt.`type`.session.local

import com.github.rhu1.gt.`type`.session.*

import scala.annotation.tailrec


sealed trait YAction extends SAction {}

case class LRho(subj: Role) extends YAction {}

sealed trait LAction extends YAction { }

// !!! Same as GAction -- N.B. not using Msg, correspondence just erases pi anyway...
sealed abstract class LIO extends LAction {
    val src: Role
    val dst: Role
    val op: Op
    val pay: Payload
}

case class LSend(src: Role, dst: Role, op: Op, pay: Payload) extends LIO {
    val subj: Role = src
    override def toString: String = s"$src!$dst:$op($pay)"
}

case class LRecv(src: Role, dst: Role, op: Op, pay: Payload) extends LIO {
    val subj: Role = dst
    override def toString: String = s"$src?$dst:$op($pay)"  // pq?a -- p is sender
}

// !!! subj and c
case class LNu(subj: Role, c: Mid) extends LAction {}


/* ... */

/*// !!! using Sig (not Msg) for LAction -- correspondence just erases pi...
case class Sig(op: Op, pay: Payload) {

    //def toMsg: Msg = Msg(this.op, this.pay, EPSILON)

    override def toString: String = s"$op($pay)"
}*/

// Role is src
type Sigma = Map[Role, List[Msg]]
val EMPTY_SIGMA = Map.empty[Role, List[Msg]]

implicit class LMsg[A <: Msg](a: A) {

    final def isStale(L: LType): Boolean = isStaleAux(a.pi, L)

    @tailrec
    final def isStaleAux(pi: Path, L: LType): Boolean = pi match {
        case List() => false // EPSILON == List() == Nil
        case h :: t => h match {
            //case pL() => L match {
            case _: pL.type => L match {
                case LActiveRight(_, _) => true
                case LActiveLeft(_, x) => isStaleAux(t, x)
                case LActiveMixed(_, x, _, _) => isStaleAux(t, x)
                case _ => false
            }
            //case pL() => L match {
            case _: pR.type => L match {
                case LActiveLeft(_, _) => true
                case LActiveRight(_, x) => isStaleAux(t, x)
                case LActiveMixed(_, _, _, x) => isStaleAux(t, x)
                case _ => false
            }
        }
    }
}

object Sigma {
    def apply(rs: Set[Role]): Sigma = rs.map(r => (r, List.empty[Msg])).toMap
}

implicit class SigmaOps[A <: Sigma](a: A) {

    def hasNoMessages: Boolean = a.values.forall(_.isEmpty)

    def circ(b: A): Option[Sigma] =
        if (a.keySet == b.keySet) {
            Some(a.map((r, ms) => (r, ms ++ b(r))))
        } else {
            None
        }

    def containsStale(L: LType): Boolean = a.values.exists(ms => ms.exists(_.isStale(L)))

    def gc(L: LType): Sigma = a.map((r, ms) => (r, ms.filter(!_.isStale(L))))
}

case class Participant(r: Role, com: Map[Mid, Set[Op]], L: LType, q: Sigma) {

    // Only includes LRho when not a "skip"
    def getActions: Set[YAction] =
        val gc: Set[YAction] =
            if (this.q.containsStale(this.L)) Set(LRho(this.r)) else Set.empty[YAction]
        gc ++ this.L.getActions(this.r, EPSILON, q)  // cf. union

    def step(a: YAction): Either[String, (Path, Participant)] = a match {
        case a: LRho => gc(a).map(x => (EPSILON, x))  // gc top level, pi unused anyway
        case a: LAction => stepPi(a)
    }

    // Actual message communicated (if any) is LAction[Msg] version of (a, pi)
    private def stepPi(a: LAction): Either[String, (Path, Participant)] =
        this.L.step(com, EPSILON, a, this.q).map(
            (pi, L1, q1) => (pi, Participant(this.r, this.com, L1, q1)))

    def gc(a: LRho): Either[String, Participant] =
        Either.cond(a.subj == this.r,
            Participant(this.r, this.com, L, this.q.gc(this.L)),
            s"Cannot gc $a in: $this"
        )

    def isSafeTermination: Boolean = this.L.isEnded && this.q.hasNoMessages
}

case class LSystem(ps: Map[Role, Participant]) extends SSystem[LSystem, YAction] {

    // Post: Set[YAction] nonEmpty
    def getRoleActions: Map[Role, Set[YAction]] =
        this.ps.map((r, p) => (r, p.getActions))
               .filter((r, as) => as.nonEmpty)

    override def getActions: Set[YAction] = getRoleActions.flatMap(_._2).toSet

    def step(a: YAction): Either[String, LSystem] = stepPi(a).map(_._1)

    override def stepPi(a: YAction): Either[String, (LSystem, Path)] = a match {
        case LSend(src, dst, op, pay) =>
            val err = s"Cannot step $a in: $this"
            for {
                ps <- this.ps.get(src).toRight(err)
                pp <- ps.step(a)
                (pi, ps1) = pp
                pd <- this.ps.get(dst).toRight(err)
                qs <- pd.q.get(src).map(_.appended(Msg(op, pay, pi))).toRight(err)
                pd1 = Participant(dst, pd.com, pd.L, pd.q + (src -> qs))
            } yield (LSystem(this.ps + (src -> ps1) + (dst -> pd1)), pi)
        case _ =>  // Other LActions and LRho
            for {
                p <- this.ps.get(a.subj).toRight(s"Cannot step $a in: $this")
                p1 <- p.step(a)
            } yield (LSystem(this.ps + (a.subj -> p1._2)), p1._1)
    }

    override def isSafeTermination: Boolean = this.ps.values.forall(_.isSafeTermination)

    override def run(): Unit = SSystem.run(this)

    override def toString: String =
        val ps = this.ps.mkString("\n\t")
        s"LSystem(\n\t$ps)"
}

