package com.github.rhu1.gt.`type`.session.global

import com.github.rhu1.gt.`type`.session.*
import com.github.rhu1.gt.util.ConsoleColours


trait GType extends SType {
    def subs(x: Map[RecVar, GType]): GType

    def unfold: GType = this

    def unfoldAllImmediate: GType = this

    // global static
    // committing
    // not committing
    // well-formed
    // strict deps
    // eventual deps
    // single-decision
    // clear-termination
    // balance

    // global dynamics
    // wiggly
    // active mixed

    // local static
    // syntax
    // projection

    // local dynamics
    // path
    // queue
    // system
}

type MId = Int

private var MIdCounter = 0

def nextMid =
    MIdCounter = MIdCounter + 1
    MIdCounter

class GMixed(id: MId, left: GType, other: Role, obs: Role, right: GType) extends GType {
    override def subs(x: Map[RecVar, GType]): GType =
        GMixed(this.id, this.left.subs(x), this.other, this.obs, this.right.subs(x))

    override def toString: String =
        s"[${this.left} ${ConsoleColours.WHITE_TRIANGLE}${id}_${this.other},${this.obs} ${this.right}]"
}

object GEnd extends GType {
    override def subs(x: Map[RecVar, GType]): GType = this

    override def toString: String = "end"
}

case class GRec(rvar: RecVar, body: GType) extends GType {
    override def subs(x: Map[RecVar, GType]): GType =
        if (x.contains(this.rvar)) this else GRec(this.rvar, this.body.subs(x))

    override def unfold: GType = this.body.subs(Map(this.rvar -> this))

    override def unfoldAllImmediate: GType = unfold.unfold // Assumes contractive...

    override def toString: String = s"rec ${this.rvar} . ${this.body}"
}

case class GRecVar(rvar: RecVar) extends GType {
    override def subs(x: Map[RecVar, GType]): GType = x.getOrElse(this.rvar, this)

    override def toString: String = rvar.toString
}

case class GInteraction(
                           src: Role,
                           dst: Role,
                           cases: Map[(Op, Payload), GType]
                       ) extends GType {

    override def subs(x: Map[RecVar, GType]): GType =
        GInteraction(this.src, this.dst, this.cases.map((k, v) => (k, v.subs(x))))

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
        s"${this.src} ${ConsoleColours.RIGHT_ARROW} ${this.dst} ${casesToString}"
}
