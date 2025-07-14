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

    // local static
    // syntax
    // projection

    // local dynamics
    // path
    // queue
    // system
}

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

case class LActiveLeft(id: Mid, left: LType, obs: Role) extends LType {

    /* ... */

    def subs(x: Map[RecVar, LType]): LActiveLeft =
        LActiveLeft(this.id, this.left.subs(x), obs)

    /* ... */

    /* ... */

    override def toString: String =
        s"[${this.left} ${ConsoleColours.BLACK_TRIANGLE}${id}_${this.obs} ${ConsoleColours.BULLET}]"
}

case class LActiveRight(id: Mid, obs: Role, right: LType) extends LType {

    /* ... */

    def subs(x: Map[RecVar, LType]): LActiveRight =
        LActiveRight(this.id, obs, this.right.subs(x))

    /* ... */

    /* ... */

    override def toString: String =
        s"[${ConsoleColours.BULLET} ${ConsoleColours.BLACK_TRIANGLE}${id}_${this.obs} ${this.right}]"
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


