package com.github.rhu1.gt.`type`.session.local

import com.github.rhu1.gt.`type`.session.*


/* ... */

case class Msg(op: Op, pi: Path) {}

type Sigma = Map[Role, List[Msg]]
val EMPTY_SIGMA = Map.empty[Role, List[Msg]]

implicit class SigmaOps[A <: Sigma](a: A) {
    def circ(b: A): Option[Sigma] =
        if (a.keySet != b.keySet) {
            None
        } else {
            var aa = a
            aa.toSeq
            Some(a.map((r, ms) => (r, ms ++ b(r))))
        }
}

sealed trait pLR {}
object pL extends pLR {}
object pR extends pLR {}

type Path = List[pLR]
val EPSILON: Path = List[pLR]()


