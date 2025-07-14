package com.github.rhu1.gt.`type`.session.global

import com.github.rhu1.gt.`type`.session.*
import com.github.rhu1.gt.`type`.session.local.*
import com.github.rhu1.gt.util.{ConsoleColours, PipeForwards}

import scala.collection.immutable.ListMap


// Means runtime only
trait GRuntimeType extends GType {

    override protected[global] def isBalancedAux: Boolean =
        throw new RuntimeException(s"Invalid for runtime types: $this")

    /* ... */

    override def getCommittingAux(entered: Boolean, c: Mid, com: Set[Role]): Map[Role, Set[Op]] =
        throw new RuntimeException(s"Invalid for runtime types: $this")

    override def getNotCommittingAux(entered: Boolean, c: Mid, com: Set[Role]): Map[Role, Set[Op]] =
        throw new RuntimeException(s"Invalid for runtime types: $this")

    override def getSyntacticStrictDeps: Map[Role, Set[Role]] =
        throw new RuntimeException(s"Invalid for runtime types: $this")

    override def getSyntacticEventualDeps: Map[Role, Set[Role]] =
        throw new RuntimeException(s"Invalid for runtime types: $this")

    override def isSingleDecision: Boolean =
        throw new RuntimeException(s"Invalid for runtime types: $this")

    override def isClearTermination: Boolean =
        throw new RuntimeException(s"Invalid for runtime types: $this")

}



/* ... */

case class GWiggly(
           src: Role,
           dst: Role,
           op: Op,
           cases: ListMap[(Op, Payload), GType]
       ) extends GRuntimeType {

    private val cont: ListMap[(Op, Payload), GType] = this.cases.filter(_._1 == this.op)

    /* ... */

    override def subs(x: Map[RecVar, GType]): GWiggly =
        GWiggly(this.src, this.dst, this.op, this.cont.map((k, v) => (k, v.subs(x))))

    override def unfoldAllOnceAux(done: Set[RecVar]): GWiggly =
        GWiggly(this.src, this.dst, this.op,
            this.cont.map((k, v) => (k, v.unfoldAllOnceAux(done))))

    override def isDivergingAux(entered: Set[RecVar], r: Role): Boolean =
        this.cont.forall(x => x._2.isDivergingAux(entered, r))

    override def getLiveRoles: Set[Role] = Set(this.dst) ++ this.cont.flatMap(_._2.getLiveRoles)

    override def getMids: Set[Mid] = this.cont.flatMap(_._2.getMids).toSet

    /* ... */

    /* ... */

    override def rprojectAux(pi: Path, r: Role): Option[(LType, Sigma)] = throw new RuntimeException("TODO")

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
        s"${this.src} ${ConsoleColours.RIGHT_ARROW} ${this.dst} $this.op ${casesToString}"
}


/* ... */

class GActiveMixed(
        id: Mid,
        left: GInteraction,
        other: Role,
        obs: Role,
        comL: Set[Role],
        comR: Set[Role],
        right: GInteraction
    ) extends GRuntimeType {

    /* ... */

    override def subs(x: Map[RecVar, GType]): GActiveMixed =
        GActiveMixed(this.id, this.left.subs(x), this.other, this.obs, this.comL, this.comR, this.right.subs(x))

    override def unfoldAllOnceAux(done: Set[RecVar]): GActiveMixed =
        GActiveMixed(id, this.left.unfoldAllOnceAux(done), this.other, this.obs,
            this.comL, this.comR, this.right.unfoldAllOnceAux(done))

    override def isDivergingAux(entered: Set[RecVar], r: Role): Boolean =
        this.left.isDivergingAux(entered, r) && this.right.isDivergingAux(entered, r)

    override def getLiveRoles: Set[Role] =
        (this.left.getLiveRoles -- this.comR) ++ (this.right.getLiveRoles -- this.comL)

    override def getMids: Set[Mid] = this.left.getMids ++ this.right.getMids + this.id

    /* ... */

    /* ... */

    override def rprojectAux(pi: Path, r: Role): Option[(LType, Sigma)] = throw new RuntimeException("TODO")

    /* ... */

    /* ... */

    override def toString: String =
        s"[${this.left} $comL ${ConsoleColours.WHITE_TRIANGLE}${id}_${this.other},${this.obs} $comR ${this.right}]"
}


