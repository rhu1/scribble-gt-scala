package com.github.rhu1.gt.`type`.session.global

import com.github.rhu1.gt.`type`.session.*


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



