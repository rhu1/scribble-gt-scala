package com.github.rhu1.gt.`type`.session.local

import com.github.rhu1.gt.`type`.session.*
import com.github.rhu1.gt.util.ConsoleColours

import scala.collection.immutable.ListMap

trait LType extends SType {

    def subs(x: Map[RecVar, LType]): LType

    def unfold: LType = this

    def unfoldAllImmediate: LType = this

    /*def unfoldAllOnce: LType = unfoldAllOnceAux(Set())
    protected[global] def unfoldAllOnceAux(done: Set[RecVar]): LType*/

    // local dynamics
    // path
    // queue
    // system

    /*def getActions: Set[GAction]

    def step(a: GAction): Either[String, GType]*/
}

object LType {

    def merge(x: LType, y: LType): Option[LType] =
        if (x == y) {
            Some(x)
        } else {
            (x, y) match {
                case (LBranch(src1, cases1), LBranch(src2, cases2)) =>
                    if (src1 == src2 && cases1.keySet.intersect(cases2.keySet).isEmpty) {
                        Some(LBranch(src1, cases1 ++ cases2))
                    } else {
                        None
                    }
                case (LRec(rvar1, body1), LRec(rvar2, body2)) =>
                    if (rvar1 == rvar2) {
                        merge(body1, body2).map(z => LRec(rvar1, z))
                    } else {
                        None
                    }
                case _ => None  // !!! no MC cases
            }
        }

    def mergeSigma(x: Sigma, y: Sigma): Option[Sigma] = if (x == y) Some(x) else None
}


/* ... */

case class LSelect(dst: Role, cases: ListMap[(Op, Payload), LType]) extends LType {

    /* ... */

    def subs(x: Map[RecVar, LType]): LSelect =
        LSelect(this.dst, this.cases.map((k, v) => (k, v.subs(x))))

    /* ... */

    /* ... */

    override def toString: String =
        s"${this.dst}&${SType.casesToString(this.cases)}"
}

case class LBranch(src: Role, cases: ListMap[(Op, Payload), LType]) extends LType {

    /* ... */

    def subs(x: Map[RecVar, LType]): LBranch =
        LBranch(this.src, this.cases.map((k, v) => (k, v.subs(x))))

    /* ... */

    /* ... */

    override def toString: String =
        s"${this.src}${ConsoleColours.OLPLUS}${SType.casesToString(this.cases)}"
}

// !!! consider LOtherMixed, LObserverMixed
case class LMixed(id: Mid, left: LType, obs: Role, right: LType) extends LType {

    /* ... */

    def subs(x: Map[RecVar, LType]): LMixed =
        LMixed(this.id, this.left.subs(x), obs, this.right.subs(x))

    /* ... */

    /* ... */

    override def toString: String =
        s"[${this.left} ${ConsoleColours.WHITE_TRIANGLE}${id}_${this.obs} ${this.right}]"
}

// Active but not committed
case class LActiveMixed(id: Mid, left: LType, obs: Role, right: LType) extends LType {

    /* ... */

    def subs(x: Map[RecVar, LType]): LActiveMixed =
        LActiveMixed(this.id, this.left.subs(x), obs, this.right.subs(x))

    /* ... */

    /* ... */

    override def toString: String =
        s"[${this.left} ${ConsoleColours.BLACK_TRIANGLE}${id}_${this.obs} ${this.right}]"
}

// !!! no obs -- ...also LActiveMixed ?
case class LActiveLeft(id: Mid, left: LType) extends LType {

    /* ... */

    def subs(x: Map[RecVar, LType]): LActiveLeft =
        LActiveLeft(this.id, this.left.subs(x))

    /* ... */

    /* ... */

    override def toString: String =
        s"[${this.left} ${ConsoleColours.BLACK_TRIANGLE}${id} ${ConsoleColours.BULLET}]"
}

case class LActiveRight(id: Mid, right: LType) extends LType {

    /* ... */

    def subs(x: Map[RecVar, LType]): LActiveRight =
        LActiveRight(this.id, this.right.subs(x))

    /* ... */

    /* ... */

    override def toString: String =
        s"[${ConsoleColours.BULLET} ${ConsoleColours.BLACK_TRIANGLE}${id} ${this.right}]"
}

case class LRec(rvar: RecVar, body: LType) extends LType {

    /* ... */

    def subs(x: Map[RecVar, LType]): LType =
        if (x.contains(this.rvar)) this else LRec(this.rvar, this.body.subs(x))

    /* ... */

    /* ... */

    override def toString: String = s"rec ${this.rvar} . ${this.body}"
}

case class LRecVar(rvar: RecVar) extends LType {

    /* ... */

    override def subs(x: Map[RecVar, LType]): LType = x.getOrElse(this.rvar, this)

    /* ... */

    /* ... */

    override def toString: String = rvar.toString
}

object LEnd extends LType {

    /* ... */

    override def subs(x: Map[RecVar, LType]): LEnd.type = this

    /* ... */

    /* ... */

    override def toString: String = "end"
}


