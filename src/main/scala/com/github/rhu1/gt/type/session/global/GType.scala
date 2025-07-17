package com.github.rhu1.gt.`type`.session.global

import com.github.rhu1.gt.`type`.session.*
import com.github.rhu1.gt.`type`.session.local.*
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

    // Post: values only include Role for nonEmpty Set[Op]
    def getCommitting: Map[Mid, Map[Role, Set[Op]]] =  // ...removing parens causing "overload ambiguity" ?
        getMids.map(c => (c, getCommittingC(c))).toMap

    // Post: keySet only includes Role for nonEmpty Set[Op]
    def getCommittingC(c: Mid): Map[Role, Set[Op]] =
        unfoldAllOnce |> (_.getCommittingAux(false, c, Set()))
    protected[global]def getNotCommittingC(c: Mid): Map[Role, Set[Op]] =
        unfoldAllOnce |> (_.getNotCommittingAux(false, c, Set()))

    protected[global] def getCommittingAux(entered: Boolean, c: Mid, com: Set[Role]): Map[Role, Set[Op]]
    protected[global] def getNotCommittingAux(entered: Boolean, c: Mid, com: Set[Role]): Map[Role, Set[Op]]

    def isWellFormed: Boolean =
        def checkForIsect(x: Map[Role, Set[Op]], y: Map[Role, Set[Op]]): Boolean = {
            (x.keySet ++ y.keySet).exists(r => {
                val ox = x.getOrElse(r, Set())
                val oy = y.getOrElse(r, Set())
                val dbug = (ox intersect oy).nonEmpty
                if (dbug) {
                    println(s"WFqqqq: $r ${ox intersect oy}")
                }
                dbug
            })
        }
        val isect = getMids.filter(c => checkForIsect(getCommittingC(c), getNotCommittingC(c)))
        if (isect.nonEmpty) {
            isect.foreach(x => println(s"WF1111: $x\n\t${getCommittingC(x)}\n\t${getNotCommittingC(x)}"))
        }
        isect.isEmpty

    def getSyntacticStrictDeps: Map[Role, Set[Role]]

    def getSyntacticEventualDeps: Map[Role, Set[Role]]

    def isSingleDecision: Boolean

    def isClearTermination: Boolean

    def isAware: Boolean = isSingleDecision && isClearTermination

    def isBalanced: Boolean = unfoldAllOnce |> (_.isBalancedAux)  // !!! unfold currently redundant

    protected[global] def isBalancedAux: Boolean

    def isValid: Boolean = isWellFormed && isAware && isBalanced


    /* projection */

    def project(r: Role): Option[LType] = rproject(r).map(_._1)

    def rproject(r: Role): Option[(LType, Sigma)] = rprojectAux(EPSILON, r)

    protected[global] def rprojectAux(pi: Path, r: Role): Option[(LType, Sigma)]


    /* dynamics */

    def getActions: Set[GAction]

    def step(com: Map[Mid, Set[Op]], a: GAction): Either[String, GType]


    // Post: keySet == getLiveRoles
    def getRoleCommitting: Map[Role, Map[Mid, Set[Op]]] =
        val com = getCommitting
        /*val s = com.toSeq.flatMap((c, rops) => rops.toSeq.map((r, ops) => (r, (c, ops))))
        s.foldLeft(Map.empty[Role, Map[Mid, Set[Op]]]) {
            case (acc, (r, (c, ops))) =>
                acc + (r -> (acc.getOrElse(r, Map.empty[Mid, Set[Op]]) + (c -> ops)))  // c's disjoint per r*/
        val rcom = com.foldLeft(Map.empty[Role, Map[Mid, Set[Op]]]) {
            case (acc, (c, rops)) =>
                (acc.keySet union rops.keySet).map(r => (
                    r,
                    { val gacc = acc.getOrElse(r, Map.empty[Mid, Set[Op]])
                      val gcom = rops.getOrElse(r, Set.empty[Op])
                      //gacc + (c -> (gacc.getOrElse(c, Set.empty[Op]) ++ gcom)) }  // getOrElse always empty for c
                      gacc + (c -> gcom) }
                )).toMap
        }
        getLiveRoles.map(r => (r, rcom.getOrElse(r, Map.empty[Mid, Set[Op]]))).toMap
}


object GType {

    /* ... */

    def unionRoleOps(x: Map[Role, Set[Op]], y: Map[Role, Set[Op]]): Map[Role, Set[Op]] =
        y.foldLeft(x) { case (acc, (r, ops)) =>
            acc + (r -> (acc.getOrElse(r, Set()) ++ ops))
        }

    /*def mergeCommitting
            (x: Map[Mid, Map[Role, Set[Op]]], y: Map[Mid, Map[Role, Set[Op]]]):
            Map[Mid, Map[Role, Set[Op]]] =
        y.foldLeft(x)({ case (acc, (c, rops)) =>
            acc + (c -> mergeRoleOps(acc.getOrElse(c, Map()), rops))
        })*/

    def isectDeps(x: Map[Role, Set[Role]], y: Map[Role, Set[Role]]): Map[Role, Set[Role]] =
        // fold better
        x.keySet.intersect(y.keySet).map(r => (
            r,
            //(for { xr <- x.get(r); yr <- y.get(r); res = xr.intersect(yr) } yield res).get
            //(x.get(r), y.get(r)) match { case (Some(xr), Some(yr)) => xr.intersect(yr)}
            { val (xr, yr) = (x.getOrElse(r, Set()), y.getOrElse(r, Set())); xr.intersect(yr) }
        )).toMap

    def unionDeps(x: Map[Role, Set[Role]], y: Map[Role, Set[Role]]): Map[Role, Set[Role]] =
        // fold better
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
                .reduce(GType.unionRoleOps)
        } else {
            this.cases.map(x => x._2.getCommittingAux(entered, c, com)).reduce(GType.unionRoleOps)
        }

    override def getNotCommittingAux(entered: Boolean, c: Mid, com: Set[Role]): Map[Role, Set[Op]] =
        if (!com.contains(this.dst) && com.contains(this.src)) {
            //val imm = Map(this.src -> this.cases.keySet.map((op, _) => op))
            val imm = Map[Role, Set[Op]]()  // !!! ignoring sender ops...
            (Seq(imm) ++ this.cases.values.map(_.getNotCommittingAux(entered, c, com + this.dst)))
                .reduce(GType.unionRoleOps)
        } else {
            val imm = if (!entered) Map() else Map(
                //this.src -> this.cases.keySet.map((op, _) => op),  // !!! ignoring sender ops...
                this.dst -> this.cases.keySet.map((op, _) => op)
            )
            (Seq(imm) ++ this.cases.values.map(_.getNotCommittingAux(entered, c, com)))
                .reduce(GType.unionRoleOps)
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
        //if (!dbug) println(s"CT2222: ${this}")
        dbug

    override protected[global] def isBalancedAux: Boolean =
        val fst = this.cases.head._2.getLiveRoles -- Set(this.src, this.dst)
        this.cases.slice(1, this.cases.size)
                .forall(x => (x._2.getLiveRoles -- Set(this.src, this.dst)) == fst) &&
            this.cases.values.forall(_.isBalancedAux)

    /* ... */

    override def rprojectAux(pi: Path, r: Role): Option[(LType, Sigma)] =
        for {
            (cases, sigmas) <- this.cases.foldLeft
                (Option((ListMap.empty[(Op, Payload), LType], List.empty[Sigma]))) {
                    case (None, _) => None
                    case (Some(acc), (k, g)) =>
                        g.rprojectAux(pi, r).map(y => (acc._1 + ((k, y._1)), acc._2 :+ y._2))
                }
            cs <-
                if (r == this.src) {
                    Some(LSelect(this.dst, cases))
                } else if (r == this.dst) {
                    Some(LBranch(this.src, cases))
                } else {
                    cases.values.tail.foldLeft(Option(cases.values.head)) {  // cases non-empty
                            case (None, _) => None
                            case (Some(acc), x) => LType.merge(acc, x)
                        }
                }
            s <- sigmas.tail.foldLeft(Option(sigmas.head)) {
                    case (None, _) => None
                    case (Some(acc), x) => LType.mergeSigma(acc, x)
                }
        } yield (cs, s)

    /* ... */

    override def getActions: Set[GAction] =
        val pq = Set(this.src, this.dst)
        this.cases.keySet.map((o, d) => GSend(this.src, this.dst, o, d)) union
            this.cases.values
                .map(_.getActions filter {
                    case x: GIO => !pq.contains(x.src) && !pq.contains(x.dst)
                    case _ => false
                })
                .reduce((x, y) => x intersect y)

    override def step(com: Map[Mid, Set[Op]], a: GAction): Either[String, GType] = a match {
        case GSend(src, dst, op, pay) =>
            if (src == this.src || dst == this.dst) {
                if (src != this.src || dst != this.dst) {
                    Left(s"Cannot step $a in: $this")
                } else {
                    this.cases.find((k, v) => k == (op, pay)) match {
                        case None => Left(s"Cannot step $a in: $this")
                        case Some(x) => Right(x._2)
                    }
                }
            } else {
                stepNested(com, a)
            }
        case _ => stepNested(com, a)
    }

    protected def stepNested(com: Map[Mid, Set[Op]], a: GAction): Either[String, GInteraction] = for {
        q <- this.cases.foldLeft[Either[String, ListMap[(Op, Payload), GType]]]
                 (Right(ListMap.empty[(Op, Payload), GType])) {
                     case (acc, (m, p)) => acc match
                         case Right(x) => p.step(com, a).map(y => x + ((m, y)))
                         case Left(x) => Left(x)
                 }
    } yield GInteraction(this.src, this.dst, q)


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
                    this.obs -> this.left.cases.keySet.map((op, _) => op)
                )
                // !!! Reset com
                val left = this.left.cases.values.map(_.getCommittingAux(true, c, Set(this.obs)))
                val right = this.right.cases.values.map(_.getCommittingAux(true, c, Set(this.obs, this.other)))
                //GType.mergeRoleOps(GType.mergeRoleOps(imm, left), right)

                val dbugl = left.foldLeft(imm)(GType.unionRoleOps)
                val dbug = dbugl |> (a => right.foldLeft(a)(GType.unionRoleOps))
                //println(s"WF2222: ${c}: ${imm} ,, ${left} ,, ${dbugl} ,, ${dbug}")
                dbug
            }
        } else {
            //GType.mergeRoleOps(this.left.getCommittingAux(c, com), this.right.getCommittingAux(c, com))
            val left = this.left.cases.values.map(_.getCommittingAux(entered, c, com))
            val right = this.right.cases.values.map(_.getCommittingAux(entered, c, com))
            right.foldLeft(left.reduce(GType.unionRoleOps))(GType.unionRoleOps)
        }

    override def getNotCommittingAux(entered: Boolean, c: Mid, com: Set[Role]): Map[Role, Set[Op]] =
        if (c == this.id) {
            if (entered) {  // !!!
                Map()
            } else {
                // !!! reset com
                val left = this.left.cases.values.map(
                    _.getNotCommittingAux(true, c, Set(this.obs)))
                val right = this.right.cases.values.map(
                    _.getNotCommittingAux(true, c, Set(this.obs, this.other)))
                //GType.mergeRoleOps(left, right)
                val dbug = right.foldLeft(left.reduce(GType.unionRoleOps))(GType.unionRoleOps)
                //println(s"WF3333: ${c}: ${dbug} ,, ${this}")
                dbug
            }
        } else {
            //GType.mergeRoleOps(this.left.getNotCommittingAux(c, com), this.right.getNotCommittingAux(c, com))
            val left = this.left.cases.values.map(_.getNotCommittingAux(entered, c, com))
            val right = this.right.cases.values.map(_.getNotCommittingAux(entered, c, com))
            right.foldLeft(left.reduce(GType.unionRoleOps))(GType.unionRoleOps)
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

    override def rprojectAux(pi: Path, r: Role): Option[(LType, Sigma)] =
        for {
            left <- this.left.rprojectAux(pi, r)
            right <- this.right.rprojectAux(pi, r)
            s0 <- if (left._2 == right._2) Some(left._2) else None
            obs <- right._1 match {
                case LSelect(_, _) => Some(this.obs)
                case LBranch(src, _) => Some(src)
                case _ => None
            }
        } yield (LMixed(this.id, left._1, obs, right._1), s0)

    /* ... */

    override def getActions: Set[GAction] = Set(GNu(this.id))

    override def step(com: Map[Mid, Set[Op]], a: GAction): Either[String, GActiveMixed] = a match {
        case GNu(c) =>
            if (c == this.id) {
                Right(GActiveMixed(this.id, this.left, this.other, this.obs, Set(), Set(), this.right))
            } else{
                Left(s"Cannot step $a in: $this")
            }
        case _ => Left(s"Cannot step $a in: $this")
    }

    /* ... */

    override def toString: String =
        s"[${this.left} ${ConsoleColours.WHITE_TRIANGLE}${id}_${this.other},${this.obs} ${this.right}]"
}


/* ... */

case class GRec(rvar: RecVar, body: GType) extends GType {

    /* ... */

    override def subs(x: Map[RecVar, GType]): GRec =
        if (x.contains(this.rvar)) this else GRec(this.rvar, this.body.subs(x))

    override def unfold: GType = this.body.subs(Map(this.rvar -> this))

    override def unfoldAllOnceAux(done: Set[RecVar]): GType =
        if (done.contains(this.rvar)) {
            this
        } else {
            unfold |> (_.unfoldAllOnceAux(done + this.rvar))
        }

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

    override def rprojectAux(pi: Path, r: Role): Option[(LType, Sigma)] =
        for {
            (b, s) <- this.body.rprojectAux(pi, r)
            b1 = b match {
                case LEnd => LEnd
                case LRecVar(v) => if (v == this.rvar) LEnd else LRecVar(v)
                case _ => LRec(this.rvar, b)
            }
            s1 <- if (s.isEmpty) Some(EMPTY_SIGMA) else None
        } yield (b1, s1)

    /* ... */

    override def getActions: Set[GAction] =
        unfold |> (_.getActions)

    override def step(com: Map[Mid, Set[Op]], a: GAction): Either[String, GType] =
        unfold |> (_.step(com, a))

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

    override def rprojectAux(pi: Path, r: Role): Option[(LType, Sigma)] =
        Some((LRecVar(this.rvar), EMPTY_SIGMA))
        
    /* ... */

    override def getActions: Set[GAction] = Set()

    override def step(com: Map[Mid, Set[Op]], a: GAction): Either[String, GType] =
        Left("Stuck: $this")

    /* ... */

    override def toString: String = rvar.toString
}


/* ... */

object GEnd extends GType {

    /* ... */

    override def subs(x: Map[RecVar, GType]): GEnd.type = this

    override def unfoldAllOnceAux(done: Set[RecVar]): GEnd.type = this

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

    override def rprojectAux(pi: Path, r: Role): Option[(LType, Sigma)] = 
        Some((LEnd, EMPTY_SIGMA))
        
    /* ... */

    override def getActions: Set[GAction] = Set()

    override def step(com: Map[Mid, Set[Op]], a: GAction): Either[String, GType] = Left("Stuck: $this")

    /* ... */

    override def toString: String = "end"
}


/* ... */


private var MIdCounter = 0

def nextMid =
    MIdCounter = MIdCounter + 1
    MIdCounter


