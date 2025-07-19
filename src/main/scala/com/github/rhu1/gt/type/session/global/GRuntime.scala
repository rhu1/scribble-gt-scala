package com.github.rhu1.gt.`type`.session.global

import com.github.rhu1.gt.`type`.session.*


/* ... */

sealed trait GAction extends SAction {}

sealed abstract class GIO extends GAction {
    val src: Role
    val dst: Role
    val op: Op
    val pay: Payload
}

case class GSend(pi: Path, src: Role, dst: Role, op: Op, pay: Payload) extends GIO {
    val subj = this.src
    override def toString: String = 
        val pay = if (this.pay.elems.isEmpty) "" else s"${this.pay}, "  // cf. Msg
        s"$src!$dst:$op($pay$pi)"
}

case class GRecv(pi: Path, src: Role, dst: Role, op: Op, pay: Payload) extends GIO {
    val subj = this.dst
    override def toString: String =
        val pay = if (this.pay.elems.isEmpty) "" else s"${this.pay}, "  // cf. Msg
        s"$src?$dst:$op($pay$pi)"  // pq?a -- p is sender
}

// !!! c
case class GNu(pi: Path, c: Mid) extends GAction {
    val subj = Role("Dummy")  // ...hack
}



