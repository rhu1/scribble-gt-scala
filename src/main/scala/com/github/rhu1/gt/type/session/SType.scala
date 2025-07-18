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

sealed trait pLR {}

object pL extends pLR {
    def unapply(x: pLR): Boolean = true

    override def toString: String = "l"
}

object pR extends pLR {
    def unapply(x: pLR): Boolean = true

    override def toString: String = "r"
}

type Path = List[pLR]
val EPSILON: Path = List.empty[pLR]


/* ... */

trait SAction {}

trait SSystem[+T <: SSystem[T, U], U <: SAction] {
    def getActions: Map[Role, Set[U]]

    def stepPi(a: U): Either[String, (T, Path)]

    def isSafeTermination: Boolean

    def run(): Unit
}

object SSystem {

    def run[T <: SSystem[T, U], U <: SAction](Y: T): Unit = {
        var n = 0
        def nextN: Int = { n += 1; n }
        def indent(top: String, par: String, x: String) = top + x.replaceAll("\\n", s"\n$par")

        val hist = collection.mutable.Map.empty[T, (Integer, List[U])]  // List is (first) trace
        val done = collection.mutable.LinkedHashSet.empty[(T, (Role, U))]
        val todo = collection.mutable.LinkedHashSet.empty[(T, (Role, U))]
        // Pre: ras = _Y1.getActions -- split for debugging
        def addHist(Y: T, a: U, Y1: T): Unit = {
            if (!hist.contains(Y1)) {
                hist += (Y1 -> (nextN, hist(Y)._2 :+ a))
            }
        }
        // Pre: Y in hist.keySet
        def checkAndAddTodo(top: String, pi: Path, Y: T, ras: Map[Role, Set[U]]): Unit = {
            val h = hist(Y)
            if (ras.isEmpty) {
                if (!Y.isSafeTermination) {
                    throw new RuntimeException(s"Stuck: $pi: $Y")
                }
                println(s"$top\t${h._1} terminated.")
            } else {
                if (pi.size > 3) {
                    println(s"$top\tPruning ${h._1} at ${pi} ...")
                } else if (h._2.size > 12) {  // cf. non-terminating rec within MC
                    println(s"$top\tPruning ${h._1} at ${h._2} ...")
                } else {
                    for (r, as) <- ras; a <- as do // as nonEmpty
                        val s = (Y, (r, a)) // r == a.subj, redundant
                        if (done.contains(s)) {
                            println(s"$top\t${hist(s._1)._1}, $a already done.")
                        } else {
                            todo += s
                        }
                }
            }
        }

        hist(Y) = (nextN, List.empty)
        val ras = Y.getActions
        checkAndAddTodo("", EPSILON, Y, ras)
        println(s"$Y\n\tactions=$ras\n---")

        def todoStr = todo.map(x => "(" + hist(x._1)._1.toString + ", " + x._2._2 + ")").mkString("; ")
        while (todo.nonEmpty) {
            println(s"todo: $todoStr")
            val pop = todo.last
            todo -= pop
            done += pop
            val (_Y1, (_, a1)) = pop  // r == a1.subj, redundant
            val (i, trace) = hist(_Y1)
            val ind = "    " * trace.size
            println(indent(ind, ind, s"$i: $_Y1"))
            print(indent(ind, ind, s"\t$trace |- $a1"))
            val (succ, pi) = _Y1.stepPi(a1) match {
                case Left(x) => throw new RuntimeException(x)
                case Right(x) => x
            }
            val ras1 = succ.getActions
            addHist(_Y1, a1, succ)
            println(indent("", ind, s" -> ${hist(succ)._1} $succ\n\tactions=$ras1"))  // Assumes addHist
            checkAndAddTodo(ind, pi, succ, ras1)
            n += 1
        }
        println(s"Ran ${nextN-1} states.")
    }

}
