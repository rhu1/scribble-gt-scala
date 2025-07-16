package com.github.rhu1.gt.`type`.session.local

import com.github.rhu1.gt.`type`.session.*

import scala.annotation.tailrec


sealed trait YAction {
    val subj: Role
}

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

// !!! m = alpha  // Actual queue contents (cf. LAction, no pi)
case class Msg(op: Op, pay: Payload, pi: Path) {

    def isStale(L: LType): Boolean = Msg.isStaleAux(this.pi, L)

    override def toString: String = s"$op($pay, $pi)"
}

object Msg {

    @tailrec
    private def isStaleAux(pi: Path, L: LType): Boolean = pi match {
        case List() => false  // EPSILON == List() == Nil
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

// Role is src
type Sigma = Map[Role, List[Msg]]
val EMPTY_SIGMA = Map.empty[Role, List[Msg]]

object Sigma {
    def apply(rs: Set[Role]): Sigma = rs.map(r => (r, List.empty[Msg])).toMap
}

implicit class SigmaOps[A <: Sigma](a: A) {

    def circ(b: A): Option[Sigma] =
        if (a.keySet == b.keySet) {
            Some(a.map((r, ms) => (r, ms ++ b(r))))
        } else {
            None
        }

    def gc(L: LType): Sigma = a.map((r, q) => (r, q.filter(!_.isStale(L))))
}

sealed trait pLR {}
object pL extends pLR {
    def unapply(x: pLR): Boolean = true
}
object pR extends pLR {
    def unapply(x: pLR): Boolean = true
}

type Path = List[pLR]
val EPSILON: Path = List.empty[pLR]

case class Participant(r: Role, com: Map[Mid, Set[Op]], L: LType, q: Sigma) {

    // Includes \rho when not "skip"
    def getActions: Set[YAction] = Set()

    def step(a: YAction): Either[String, (Path, Participant)] = a match {
        case a: LRho => gc(a).map(x => (EPSILON, x))  // gc top level, pi unused anyway
        case a: LAction => stepPi(a)
    }

    // Actual message communicated (if any) is LAction[Msg] version of (a, pi)
    private def stepPi(a: LAction): Either[String, (Path, Participant)] =
        this.L.step(com, EPSILON, a, this.q).map((pi, L1, q1) =>
            (pi, Participant(this.r, this.com, L1, q1)))

    def gc(a: LRho): Either[String, Participant] =
        Either.cond(a.subj != this.r,
            Participant(this.r, this.com, L, this.q.gc(this.L)),
            s"Cannot step $a in: $this"
        )
}

case class System(ps: Map[Role, Participant]) {

    // Post: Set[YAction] nonEmpty
    def getActions: Map[Role, Set[YAction]] =
        this.ps.map((r, p) => (r, p.getActions))
               .filter((r, as) => as.nonEmpty)

    def step(a: YAction): Either[String, System] = a match {
        case LSend(src, dst, op, pay) =>
            val err = s"Cannot step $a in: $this"
            for {
                ps <- this.ps.get(src).toRight(err)
                pd <- this.ps.get(dst).toRight(err)
                pp <- ps.step(a)
                (pi, ps1) = pp
                qs <- pd.q.get(src).map(_.appended(Msg(op, pay, pi))).toRight(err)
                pd1 = Participant(dst, pd.com, pd.L, pd.q + (src -> qs))
            } yield System(this.ps + (src -> ps1) + (dst -> pd1))
        case _ =>  // Other LActions and LRho
            for {
                p <- this.ps.get(a.subj).toRight(s"Cannot step $a in: $this")
                p1 <- p.step(a)
            } yield System(this.ps + (a.subj -> p1._2))
    }
}

object System {
    def run(s: System): Unit = {
        var i = 0
        var s1 = s
        var ras = s1.getActions  // as nonEmpty
        println(s"$i: $s1")
        while (ras.nonEmpty) {
            val (r, as) = ras.head
            val a = as.head
            print(s"$i: $a")
            s1 = s1.step(a) match {
                case Left(x) => throw new RuntimeException(x)
                case Right(x) => x
            }
            ras = s1.getActions
            i += 1
            println(s" -> $s1")
        }
    }

}

