package com.github.rhu1.gt.`type`.session.local

import com.github.rhu1.gt.`type`.session.*


sealed trait LAction { }

sealed abstract class LIO extends LAction {
    val src: Role
    val dst: Role
    val alpha: Msg
}

case class LSend(src: Role, dst: Role, alpha: Msg) extends LIO {
    override def toString: String = s"$src!$dst:$alpha)"
}

case class LRecv(src: Role, dst: Role, alpha: Msg) extends LIO {
    override def toString: String = s"$src?$dst:$alpha)"  // pq?a -- p is sender
}

// !!! c
case class LNu(c: Mid) extends LAction {}

case class LRho(r: Role) extends LAction {}


/* ... */

// alpha
case class Msg(op: Op, pay: Payload, pi: Path) {

    def isStale(L: LType): Boolean = isStaleAux(this.pi, L)

    def isStaleAux(pi: Path, L: LType): Boolean = pi match {
        case List() => false  // EPSILON == List()
        case h :: t => h match {  // CHECKME exhaustive ?
            case pL() => L match {
                case LActiveRight(_, _) => true
                case LActiveLeft(_, x) => isStaleAux(t, x)
                case LActiveMixed(_, x, _, _) => isStaleAux(t, x)
                case _ => false
            }
            case pR() => L match {
                case LActiveLeft(_, _) => true
                case LActiveRight(_, x) => isStaleAux(t, x)
                case LActiveMixed(_, _, _, x) => isStaleAux(t, x)
                case _ => false
            }
        }
    }

    override def toString: String = s"$op($pay, $pi)"
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

case class Participant(r: Role, p: LType, q: Sigma) {}

case class System(ps: Map[Role, Participant]) {

}
