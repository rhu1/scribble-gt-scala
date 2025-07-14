package com.github.rhu1.gt.`type`.session

import scala.collection.immutable.ListMap


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

object SType {

    def casesToString(cases: ListMap[(Op, Payload), SType]): String =
        def msgToString(x: (Op, Payload)) = s"${x._1}(${x._2})"
        if (cases.size == 1) {
            val c = cases.head
            s"${msgToString(c._1)} . ${c._2}"
        } else {
            val tmp = cases.map((x, y) => s"${msgToString(x)}: ${y}").mkString(", ")
            s"{${tmp}}"
        }
}


/* ... */

type Mid = Int
