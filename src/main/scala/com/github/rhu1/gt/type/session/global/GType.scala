package com.github.rhu1.gt.`type`.session.global

import com.github.rhu1.gt.`type`.session.*
import com.github.rhu1.gt.util.{ConsoleColours, PipeForwards}

import scala.collection.immutable.ListMap


trait GType extends SType {

    /* ... */

    def subs(x: Map[RecVar, GType]): GType

    def unfold: GType = this

    def unfoldAllImmediate: GType = this

    def unfoldAllOnce: GType = unfoldAllOnceAux(Set())

    protected[global] def unfoldAllOnceAux(done: Set[RecVar]): GType

    def isDiverging(r: Role): Boolean = isDivergingAux(Set(), r)

    protected[global] def isDivergingAux(entered: Set[RecVar], r: Role): Boolean

    def getLiveRoles: Set[Role]

    def getMids: Set[Mid]

    /* static */

    def getCommitting(): Map[Mid, Map[Role, Set[Op]]] =  // ...removing parens causing "overload ambiguity" ?
        getMids.map(c => (c, getCommitting(c))).toMap

    def getCommitting(c: Mid): Map[Role, Set[Op]] =
        unfoldAllOnce |> (_.getCommittingAux(false, c, Set()))
    def getNotCommitting(c: Mid): Map[Role, Set[Op]] =
        unfoldAllOnce |> (_.getNotCommittingAux(false, c, Set()))

    protected[global] def getCommittingAux(entered: Boolean, c: Mid, com: Set[Role]): Map[Role, Set[Op]]
    protected[global] def getNotCommittingAux(entered: Boolean, c: Mid, com: Set[Role]): Map[Role, Set[Op]]

    def isWellFormed: Boolean =
        def checkIsect(x: Map[Role, Set[Op]], y: Map[Role, Set[Op]]): Boolean = {
            (x.keySet ++ y.keySet).exists(r => {
                val ox = x.getOrElse(r, Set())
                val oy = y.getOrElse(r, Set())
                ox.intersect(oy).nonEmpty
            })
        }
        val cc = getCommitting(1)
        val nc = getNotCommitting(1)
        val dbug = !getMids.exists(c => checkIsect(cc, nc))
        if (!dbug) {
            println(s"WF1111: ${cc} ,, ${nc}")
        }
        dbug

    def getSyntacticStrictDeps: Map[Role, Set[Role]]

    def getSyntacticEventualDeps: Map[Role, Set[Role]]

    def isSingleDecision: Boolean

    def isClearTermination: Boolean

    def isAware: Boolean = isSingleDecision && isClearTermination

    def isBalanced: Boolean = unfoldAllOnce |> (_.isBalancedAux)  // !!! unfold currently redundant

    protected[global] def isBalancedAux: Boolean

    def isValid: Boolean = isWellFormed && isAware && isBalanced


    /* dynamics */

    /*def getActions: Set[GAction]

    def step(a: GAction): Either[String, GType]*/
}


sealed trait GAction { }
case class GSend(src: Role, dst: Role, op: Op, pay: Payload) extends GAction {
    override def toString: String = s"$src!$dst:$op($pay)"
}
case class GRecv(src: Role, dst: Role, op: Op, pay: Payload) extends GAction {
    override def toString: String = s"$src?$dst:$op($pay)"  // pq?a -- p is sender
}
case class Nu() extends GAction {}


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

    def isectDeps(x: Map[Role, Set[Role]], y: Map[Role, Set[Role]]): Map[Role, Set[Role]] =
        x.keySet.intersect(y.keySet).map(r => (
            r,
            //(for { xr <- x.get(r); yr <- y.get(r); res = xr.intersect(yr) } yield res).get
            //(x.get(r), y.get(r)) match { case (Some(xr), Some(yr)) => xr.intersect(yr)}
            { val (xr, yr) = (x.getOrElse(r, Set()), y.getOrElse(r, Set())); xr.intersect(yr) }
        )).toMap

    def unionDeps(x: Map[Role, Set[Role]], y: Map[Role, Set[Role]]): Map[Role, Set[Role]] =
        x.keySet.union(y.keySet).map(r => (
            r,
            { val (xr, yr) = (x.getOrElse(r, Set()), y.getOrElse(r, Set())); xr.union(yr) }
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

    override def isDivergingAux(entered: Set[RecVar], r: Role): Boolean =
        this.cases.forall(x => x._2.isDivergingAux(entered, r))

    override def getLiveRoles: Set[Role] = Set(this.src, this.dst) ++ this.cases.flatMap(_._2.getLiveRoles)

    override def getMids: Set[Mid] = this.cases.flatMap(_._2.getMids).toSet

    /* ... */

    override def getCommittingAux(entered: Boolean, c: Mid, com: Set[Role]): Map[Role, Set[Op]] =
        if (!com.contains(this.dst) && com.contains(this.src)) {
            val imm = if (!entered) Map() else Map(this.dst -> this.cases.keySet.map((op, _) => op))
            (Seq(imm) ++ this.cases.values.map(_.getCommittingAux(entered, c, com + this.dst)))
                .reduce(GType.mergeRoleOps)
        } else {
            this.cases.map(x => x._2.getCommittingAux(entered, c, com)).reduce(GType.mergeRoleOps)
        }

    override def getNotCommittingAux(entered: Boolean, c: Mid, com: Set[Role]): Map[Role, Set[Op]] =
        if (!com.contains(this.dst) && com.contains(this.src)) {
            //val imm = Map(this.src -> this.cases.keySet.map((op, _) => op))
            val imm = Map[Role, Set[Op]]()  // !!! ignoring sender ops...
            (Seq(imm) ++ this.cases.values.map(_.getNotCommittingAux(entered, c, com + this.dst)))
                .reduce(GType.mergeRoleOps)
        } else {
            val tmp = com + this.dst
            val imm = if (!entered) Map() else Map(
                //this.src -> this.cases.keySet.map((op, _) => op),  // !!! ignoring sender ops...
                this.dst -> this.cases.keySet.map((op, _) => op)
            )
            (Seq(imm) ++ this.cases.values.map(_.getNotCommittingAux(entered, c, tmp)))
                .reduce(GType.mergeRoleOps)
        }

    override def getSyntacticStrictDeps: Map[Role, Set[Role]] =
        var nested = this.cases.values.map(_.getSyntacticStrictDeps).reduce(GType.isectDeps)
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

    // !!! in-built transitivity (like strict), unlike formal eventual...
    override def getSyntacticEventualDeps: Map[Role, Set[Role]] =
        val R = getLiveRoles
        val rany = R.iterator.next
        val nonDiv = this.cases.values
                         .filter(!_.isDiverging(rany))  // !!! assumes balanced
                         .map(_.getSyntacticEventualDeps)
        var nested = if (nonDiv.isEmpty) Map() else nonDiv.reduce(GType.isectDeps)
        // ...same as strict except don't remove this.src << this.dst
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

    override def isSingleDecision: Boolean = this.cases.forall(_._2.isSingleDecision)

    override def isClearTermination: Boolean =
        val dbug = this.cases.forall(_._2.isClearTermination)
        if (!dbug) println(s"CT2222: ${this}")
        dbug

    override protected[global] def isBalancedAux: Boolean =
        val fst = this.cases.head._2.getLiveRoles -- Set(this.src, this.dst)
        this.cases.slice(1, this.cases.size)
                .forall(x => (x._2.getLiveRoles -- Set(this.src, this.dst)) == fst) &&
            this.cases.values.forall(_.isBalancedAux)

    /* ... */

    /* ... */

    override def toString: String =
        s"${this.src} ${ConsoleColours.RIGHT_ARROW} ${this.dst} ${SType.casesToString(this.cases)}"
}


/* ... */

class GMixed(id: Mid, left: GInteraction, other: Role, obs: Role, right: GInteraction) extends GType {

    /* ... */

    override def subs(x: Map[RecVar, GType]): GMixed =
        GMixed(this.id, this.left.subs(x), this.other, this.obs, this.right.subs(x))

    override def unfoldAllOnceAux(done: Set[RecVar]): GMixed =
        GMixed(id, this.left.unfoldAllOnceAux(done), this.other, this.obs,
            this.right.unfoldAllOnceAux(done))

    override def isDivergingAux(entered: Set[RecVar], r: Role): Boolean =
        this.left.isDivergingAux(entered, r) && this.right.isDivergingAux(entered, r)

    override def getLiveRoles: Set[Role] = this.left.getLiveRoles ++ this.right.getLiveRoles

    override def getMids: Set[Mid] = this.left.getMids ++ this.right.getMids + this.id

    /* ... */

    override def getCommittingAux(entered: Boolean, c: Mid, com: Set[Role]): Map[Role, Set[Op]] =
        if (c == this.id) {
            if (entered) {
                Map()
            } else {
                val ops_r = this.right.cases.keySet.map((op, _) => op)
                val imm = Map(
                    this.other -> ops_r,
                    //this.obs -> (this.left.cases.keySet.map((op, _) => op) ++ ops_r)  // !!! ignoring sender ops...
                )
                // !!! Reset com
                val left = this.left.cases.values.map(_.getCommittingAux(true, c, Set(this.obs)))
                val right = this.right.cases.values.map(_.getCommittingAux(true, c, Set(this.obs, this.other)))
                //GType.mergeRoleOps(GType.mergeRoleOps(imm, left), right)

                val dbug = left.foldLeft(imm)(GType.mergeRoleOps)
                            |> (a => right.foldLeft(a)(GType.mergeRoleOps))
                //println(s"WF2222: ${c}: ${dbug}")
                dbug
            }
        } else {
            //GType.mergeRoleOps(this.left.getCommittingAux(c, com), this.right.getCommittingAux(c, com))
            val left = this.left.cases.values.map(_.getCommittingAux(entered, c, com))
            val right = this.right.cases.values.map(_.getCommittingAux(entered, c, com))
            right.foldLeft(left.reduce(GType.mergeRoleOps))(GType.mergeRoleOps)
        }

    override def getNotCommittingAux(entered: Boolean, c: Mid, com: Set[Role]): Map[Role, Set[Op]] =
        if (c == this.id) {
            if (entered) {  // !!!
                Map()
            } else {
                // !!! reset com
                val left = this.left.cases.values.map(_.getNotCommittingAux(true, c, Set(this.obs)))
                val right = this.right.cases.values.map(_.getNotCommittingAux(true, c, Set(this.obs, this.other)))
                //GType.mergeRoleOps(left, right)
                val dbug = right.foldLeft(left.reduce(GType.mergeRoleOps))(GType.mergeRoleOps)
                //println(s"WF3333: ${c}: ${dbug} ,, ${this}")
                dbug
            }
        } else {
            //GType.mergeRoleOps(this.left.getNotCommittingAux(c, com), this.right.getNotCommittingAux(c, com))
            val left = this.left.cases.values.map(_.getNotCommittingAux(entered, c, com))
            val right = this.right.cases.values.map(_.getNotCommittingAux(entered, c, com))
            right.foldLeft(left.reduce(GType.mergeRoleOps))(GType.mergeRoleOps)
        }

    override def getSyntacticStrictDeps: Map[Role, Set[Role]] =
        GType.isectDeps(this.left.getSyntacticStrictDeps, this.right.getSyntacticStrictDeps)

    override def getSyntacticEventualDeps: Map[Role, Set[Role]] =
        GType.unionDeps(this.left.getSyntacticEventualDeps, this.right.getSyntacticEventualDeps)

    override def isSingleDecision: Boolean =
        val R = getLiveRoles - this.obs
        val dr = this.right.getSyntacticStrictDeps - this.obs
        R.subsetOf(dr.keySet) && dr.forall(_._2.contains(obs)) &&
            this.left.isSingleDecision && this.right.isSingleDecision

    override def isClearTermination: Boolean =
        val R = getLiveRoles - this.obs
        val dr = this.left.getSyntacticEventualDeps - this.obs
        val dbug =
            R.forall(r => this.left.isDiverging(r)
                || (dr.contains(r) && dr(r).contains(obs))
            ) && this.left.isClearTermination && this.right.isClearTermination
        if (!dbug) {
            println(s"CT1111: R=${R} ,, dr=${dr} ,, LHS=${R.forall(r => this.left.isDiverging(r) || (dr.contains(r) && dr(r).contains(obs)))} " +
                s",, left=${this.left.isClearTermination} ,, right=${this.right.isClearTermination} \n${this.left}\tP=${this.left.isDiverging(Role("P"))}")
        }
        dbug

    override protected[global] def isBalancedAux: Boolean =
        this.left.getLiveRoles == this.right.getLiveRoles &&
            this.left.isBalancedAux && this.right.isBalancedAux

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
            unfold |> (_.unfoldAllOnceAux(done + this.rvar))
        }

    override def unfold: GType = this.body.subs(Map(this.rvar -> this))

    override def unfoldAllImmediate: GType = unfold |> (_.unfold) // Assumes contractive...

    override def isDivergingAux(entered: Set[RecVar], r: Role): Boolean =
        val R = getLiveRoles
        if (R.contains(r)) {  // !!! Assumes projectable
            this.body.isDivergingAux(entered + this.rvar, r)
        } else {
            false
        }

    override def getLiveRoles: Set[Role] = this.body.getLiveRoles

    override def getMids: Set[Mid] = this.body.getMids

    /* ... */

    override def getCommittingAux(entered: Boolean, c: Mid, com: Set[Role]): Map[Role, Set[Op]] =
        this.body.getCommittingAux(entered, c, com)

    override def getNotCommittingAux(entered: Boolean, c: Mid, com: Set[Role]): Map[Role, Set[Op]] =
        this.body.getNotCommittingAux(entered: Boolean, c, com)

    override def getSyntacticStrictDeps: Map[Role, Set[Role]] = this.body.getSyntacticStrictDeps

    override def getSyntacticEventualDeps: Map[Role, Set[Role]] = this.body.getSyntacticStrictDeps

    override def isSingleDecision: Boolean = this.body.isSingleDecision

    override def isClearTermination: Boolean =
        val dbug = this.body.isClearTermination
        if (!dbug) println(s"CT3333: ${this}")
        dbug

    override protected[global] def isBalancedAux: Boolean = this.body.isBalancedAux


    /* ... */

    /* ... */

    override def toString: String = s"rec ${this.rvar} . ${this.body}"
}


/* ... */

case class GRecVar(rvar: RecVar) extends GType {

    /* ... */

    override def subs(x: Map[RecVar, GType]): GType = x.getOrElse(this.rvar, this)

    override def unfoldAllOnceAux(done: Set[RecVar]): GType = this

    override def isDivergingAux(entered: Set[RecVar], r: Role): Boolean =
        entered.contains(this.rvar)  // Assumes pruning by GRec case

    override def getLiveRoles: Set[Role] = Set()

    override def getMids: Set[Mid] = Set()

    /* ... */

    override def getCommittingAux(entered: Boolean, c: Mid, com: Set[Role]): Map[Role, Set[Op]] = Map()

    override def getNotCommittingAux(entered: Boolean, c: Mid, com: Set[Role]): Map[Role, Set[Op]] = Map()

    override def getSyntacticStrictDeps: Map[Role, Set[Role]] = Map()

    override def getSyntacticEventualDeps: Map[Role, Set[Role]] = Map()

    override def isSingleDecision: Boolean = true

    override def isClearTermination: Boolean = true

    override protected[global] def isBalancedAux: Boolean = true

    /* ... */

    /* ... */

    override def toString: String = rvar.toString
}


/* ... */

object GEnd extends GType {

    /* ... */

    override def subs(x: Map[RecVar, GType]): GEnd.type = this

    override def unfoldAllOnceAux(done: Set[RecVar]): GType = this

    override def isDivergingAux(entered: Set[RecVar], r: Role): Boolean = false

    override def getLiveRoles: Set[Role] = Set()

    override def getMids: Set[Mid] = Set()

    /* ... */

    override def getCommittingAux(entered: Boolean, c: Mid, com: Set[Role]): Map[Role, Set[Op]] = Map()

    override def getNotCommittingAux(entered: Boolean, c: Mid, com: Set[Role]): Map[Role, Set[Op]] = Map()

    override def getSyntacticStrictDeps: Map[Role, Set[Role]] = Map()

    override def getSyntacticEventualDeps: Map[Role, Set[Role]] = Map()

    override def isSingleDecision: Boolean = true

    override def isClearTermination: Boolean = true

    override protected[global] def isBalancedAux: Boolean = true

    /* ... */

    /* ... */

    override def toString: String = "end"
}


/* ... */


private var MIdCounter = 0

def nextMid =
    MIdCounter = MIdCounter + 1
    MIdCounter
