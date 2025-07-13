package com.github.rhu1.gt.`type`.session


/* ... */

trait Name(name: String) {
    override def toString: String = this.name
}
case class Role(name: String) extends Name(name) {}
case class Op(name: String) extends Name(name) {}
case class Data(name: String) extends Name(name) {}
case class Payload(elems: List[Data]) {
    override def toString: String = this.elems.mkString(", ")
}
case class RecVar(name: String) extends Name(name) {}


/* ... */

trait SType {}
