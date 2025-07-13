package com.github.rhu1.gt.`type`.session.global

import com.github.rhu1.gt.`type`.session.*
import com.github.rhu1.gt.util.ConsoleColours

import scala.collection.immutable.ListMap


trait GType extends SType {

    /* ... */

    def subs(x: Map[RecVar, GType]): GType

    def unfold: GType = this

    def unfoldAllImmediate: GType = this

    def unfoldAllOnce: GType = unfoldAllOnceAux(Set())

    protected[global] def unfoldAllOnceAux(done: Set[RecVar]): GType

    def getMids: Set[Mid]

    /* static */

    def getCommitting(): Map[Mid, Map[Role, Set[Op]]] =  // ...removing parens causing "overload ambiguity" ?
        getMids.map(c => (c, getCommitting(c))).toMap

    def getCommitting(c: Mid): Map[Role, Set[Op]] =
        unfoldAllOnce.getCommittingAux(c, Set())
    def getNotCommitting(c: Mid): Map[Role, Set[Op]] =
        unfoldAllOnce.getNotCommittingAux(c, Set())

    protected[global] def getCommittingAux(c: Mid, com: Set[Role]): Map[Role, Set[Op]]
    protected[global] def getNotCommittingAux(c: Mid, com: Set[Role]): Map[Role, Set[Op]]

    def isWellFormed: Boolean =
        def checkIsect(x: Map[Role, Set[Op]], y: Map[Role, Set[Op]]): Boolean =
            (x.keySet ++ y.keySet).exists(r => {
                val ox = x.getOrElse(r, Set())
                val oy = y.getOrElse(r, Set())
                ox.intersect(oy).nonEmpty
            })
        getMids.exists(c => checkIsect(getCommitting(c), getNotCommitting(c)))

    // strict deps
    def getSyntacticStrictDeps: Map[Role, Set[Role]]
    // eventual deps

    // single-decision
    // clear-termination

    // balance

    /* dynamics */
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

object GType {

    def mergeRoleOps(x: Map[Role, Set[Op]], y: Map[Role, Set[Op]]): Map[Role, Set[Op]] =
        y.foldLeft(x)({ case (acc, (r, ops)) =>
            acc + (r -> (acc.getOrElse(r, Set()) ++ ops))
        })

    /*def mergeCommitting
            (x: Map[Mid, Map[Role, Set[Op]]], y: Map[Mid, Map[Role, Set[Op]]]):
            Map[Mid, Map[Role, Set[Op]]] =
        y.foldLeft(x)({ case (acc, (c, rops)) =>
            acc + (c -> mergeRoleOps(acc.getOrElse(c, Map()), rops))
        })*/

    def isectStrictDeps(x: Map[Role, Set[Role]], y: Map[Role, Set[Role]]): Map[Role, Set[Role]] =
        x.keySet.intersect(y.keySet).map(r => (
            r,
            //(for { xr <- x.get(r); yr <- y.get(r); res = xr.intersect(yr) } yield res).get
            //(x.get(r), y.get(r)) match { case (Some(xr), Some(yr)) => xr.intersect(yr)}
            {
                val (xr, yr) = (x.getOrElse(r, Set()), y.getOrElse(r, Set())); xr.intersect(yr)
            }
        )).toMap
}


/* ... */

case class GInteraction(
           src: Role,
           dst: Role,
           cases: ListMap[(Op, Payload), GType]
       ) extends GType {

    /* ... */

    override def subs(x: Map[RecVar, GType]): GInteraction =
        GInteraction(this.src, this.dst, this.cases.map((k, v) => (k, v.subs(x))))

    override def unfoldAllOnceAux(done: Set[RecVar]): GInteraction =
        GInteraction(this.src, this.dst,
            this.cases.map((k, v) => (k, v.unfoldAllOnceAux(done))))

    override def getMids: Set[Mid] = this.cases.flatMap(_._2.getMids).toSet

    /* ... */

    override def getCommittingAux(c: Mid, com: Set[Role]): Map[Role, Set[Op]] =
        if (!com.contains(this.dst) && com.contains(this.src)) {
            val tmp = com + this.dst
            val imm = Map(this.dst -> this.cases.keySet.map((op, pay) => op))
            (Seq(imm) ++ this.cases.map(x => x._2.getCommittingAux(c, tmp))).reduce(GType.mergeRoleOps)
        } else {
            this.cases.map(x => x._2.getCommittingAux(c, com)).reduce(GType.mergeRoleOps)
        }

    override def getNotCommittingAux(c: Mid, com: Set[Role]): Map[Role, Set[Op]] =
        if (!com.contains(this.dst) && com.contains(this.src)) {
            this.cases.map(x => x._2.getNotCommittingAux(c, com)).reduce(GType.mergeRoleOps)
        } else {
            val tmp = com + this.dst
            val imm = Map(
                this.src -> this.cases.keySet.map((op, pay) => op),
                this.dst -> this.cases.keySet.map((op, pay) => op))
            (Seq(imm) ++ this.cases.map(x => x._2.getNotCommittingAux(c, tmp))).reduce(GType.mergeRoleOps)
        }

    override def getSyntacticStrictDeps: Map[Role, Set[Role]] =
        var nested = this.cases.values.map(_.getSyntacticStrictDeps).reduce(GType.isectStrictDeps)
        nested = nested + (this.src -> (nested.getOrElse(this.src, Set()) - this.dst))
        def shouldUp(r: Role): Boolean = !nested.getOrElse(r, Set()).contains(this.src)
        var up = if (shouldUp(this.dst)) Set(this.dst) else Set()  // Pre: need to updated nested
        while (up.nonEmpty) {  // fix
            up.foreach(r => {
                up = up - r
                val curr = nested.getOrElse(r, Set())
                nested = nested + (r -> (curr + this.src))
                up = up ++ nested.filter((r1, ds) => ds.contains(r) && shouldUp(r1)).keys
            })
        }
        nested

    /* ... */

    /* ... */

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


/* ... */

class GMixed(id: Mid, left: GInteraction, other: Role, obs: Role, right: GInteraction) extends GType {

    /* ... */

    override def subs(x: Map[RecVar, GType]): GMixed =
        GMixed(this.id, this.left.subs(x), this.other, this.obs, this.right.subs(x))

    override def unfoldAllOnceAux(done: Set[RecVar]): GMixed =
        GMixed(id, this.left.unfoldAllOnceAux(done), this.other, this.obs,
            this.right.unfoldAllOnceAux(done))

    override def getMids: Set[Mid] = this.left.getMids ++ this.right.getMids + this.id

    /* ... */

    override def getCommittingAux(c: Mid, com: Set[Role]): Map[Role, Set[Op]] =
        if (c == this.id) {
            val ops_r = this.right.cases.keySet.map((op, pay) => op)
            val imm = Map(
                this.other -> ops_r,
                this.obs -> (this.left.cases.keySet.map((op, pay) => op) ++ ops_r))
            val left = this.left.getCommittingAux(c, com + this.obs)
            val right = this.right.getCommittingAux(c, com ++ Set(this.obs, this.other))
            GType.mergeRoleOps(GType.mergeRoleOps(imm, left), right)
        } else {
            GType.mergeRoleOps(
                this.left.getCommittingAux(c, com), this.right.getCommittingAux(c, com))
        }

    override def getNotCommittingAux(c: Mid, com: Set[Role]): Map[Role, Set[Op]] =
        if (c == this.id) {
            val left = this.left.getNotCommittingAux(c, com + this.obs)
            val right = this.right.getNotCommittingAux(c, com ++ Set(this.obs, this.other))
            GType.mergeRoleOps(left, right)
        } else {
            GType.mergeRoleOps(
                this.left.getNotCommittingAux(c, com), this.right.getNotCommittingAux(c, com))
        }

    override def getSyntacticStrictDeps: Map[Role, Set[Role]] =
        GType.isectStrictDeps(this.left.getSyntacticStrictDeps, this.right.getSyntacticStrictDeps)

    /* ... */

    /* ... */

    override def toString: String =
        s"[${this.left} ${ConsoleColours.WHITE_TRIANGLE}${id}_${this.other},${this.obs} ${this.right}]"
}


/* ... */

case class GRec(rvar: RecVar, body: GType) extends GType {

    /* ... */

    override def subs(x: Map[RecVar, GType]): GRec =
        if (x.contains(this.rvar)) this else GRec(this.rvar, this.body.subs(x))

    override def unfoldAllOnceAux(done: Set[RecVar]): GType =
        if (done.contains(this.rvar)) {
            this
        } else {
            unfold.unfoldAllOnceAux(done + this.rvar)
        }

    override def getMids: Set[Mid] = this.body.getMids

    override def unfold: GType = this.body.subs(Map(this.rvar -> this))

    override def unfoldAllImmediate: GType = unfold.unfold // Assumes contractive...

    /* ... */

    override def getCommittingAux(c: Mid, com: Set[Role]): Map[Role, Set[Op]] =
        this.body.getCommittingAux(c, com)

    override def getNotCommittingAux(c: Mid, com: Set[Role]): Map[Role, Set[Op]] =
        this.body.getNotCommittingAux(c, com)

    override def getSyntacticStrictDeps: Map[Role, Set[Role]] = this.body.getSyntacticStrictDeps

    /* ... */

    /* ... */

    override def toString: String = s"rec ${this.rvar} . ${this.body}"
}


/* ... */

case class GRecVar(rvar: RecVar) extends GType {

    /* ... */

    override def subs(x: Map[RecVar, GType]): GType = x.getOrElse(this.rvar, this)

    override def unfoldAllOnceAux(done: Set[RecVar]): GType = this

    override def getMids: Set[Mid] = Set()

    /* ... */

    override def getCommittingAux(c: Mid, com: Set[Role]): Map[Role, Set[Op]] = Map()

    override def getNotCommittingAux(c: Mid, com: Set[Role]): Map[Role, Set[Op]] = Map()

    override def getSyntacticStrictDeps: Map[Role, Set[Role]] = Map()

    /* ... */

    /* ... */

    override def toString: String = rvar.toString
}


/* ... */

object GEnd extends GType {

    /* ... */

    override def subs(x: Map[RecVar, GType]): GEnd.type = this

    override def unfoldAllOnceAux(done: Set[RecVar]): GType = this

    override def getMids: Set[Mid] = Set()

    /* ... */

    override def getCommittingAux(c: Mid, com: Set[Role]): Map[Role, Set[Op]] = Map()

    override def getNotCommittingAux(c: Mid, com: Set[Role]): Map[Role, Set[Op]] = Map()

    override def getSyntacticStrictDeps: Map[Role, Set[Role]] = Map()

    /* ... */

    /* ... */

    override def toString: String = "end"
}


/* ... */

type Mid = Int


private var MIdCounter = 0

def nextMid =
    MIdCounter = MIdCounter + 1
    MIdCounter
