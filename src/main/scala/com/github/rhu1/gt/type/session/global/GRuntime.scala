package com.github.rhu1.gt.`type`.session.global

import com.github.rhu1.gt.`type`.session.*
import com.github.rhu1.gt.`type`.session.local.*


/* ... */

sealed trait GAction extends SAction {
    def toLAction(subj: Role): LAction
}

sealed abstract class GIO extends GAction {
    val src: Role
    val dst: Role
    val op: Op
    val pay: Payload

    protected def payToString: String = if (this.pay.elems.isEmpty) "" else s"${this.pay}, " // cf. Msg
}

case class GSend(pi: Path, src: Role, dst: Role, op: Op, pay: Payload) extends GIO {
    val subj = this.src
    override def toLAction(subj: Role): LSend =
        if (subj != this.subj) {
            throw new RuntimeException(s"Invalid subject $subj for: $this")
        } else {
            LSend(this.pi, this.src, this.dst, this.op, this.pay)
        }
    override def toString: String = s"$src!$dst:$op($payToString$pi)"
}

case class GRecv(pi: Path, src: Role, dst: Role, op: Op, pay: Payload) extends GIO {
    val subj = this.dst
    override def toLAction(subj: Role): LRecv =
        if (subj != this.subj) {
            throw new RuntimeException(s"Invalid subject $subj for: $this")
        } else {
            LRecv(this.pi, this.src, this.dst, this.op, this.pay)
        }
    override def toString: String = s"$src?$dst:$op($payToString$pi)"  // pq?a -- p is sender
}

// !!! c
case class GNu(pi: Path, c: Mid) extends GAction {
    val subj = Role("Dummy")  // ...hack
    override def toLAction(subj: Role): LNu = LNu(this.pi, subj, this.c)  // !!! ...dummy subj
}


/* ... */

// Root committing with current top-level G
// Pre: rcom.keySet == root getLiveRoles
case class GSystem(rcom: Map[Role, Map[Mid, Set[Op]]], G: GType) extends SSystem[GSystem, GAction] {

    override def getActions: Set[GAction] = this.G.getActions(EPSILON)  // cf. Participant

    override def stepPi(a: GAction): Either[String, (GSystem, Path)] =
        this.G.stepPi(this.rcom, EPSILON, a)
            .map((G, pi) => (GSystem(this.rcom, G), pi))

    override def isSafeTermination: Boolean = this.G.isSafeTermination(rcom.keySet)

    override def run(): Unit = SSystem.run(this)
}


/* ... */

case class ComSim(G: GSystem, Y: LSystem) extends SSystem[ComSim, GAction] {

    override def getActions: Set[GAction] =
        val aGs = this.G.getActions
        val aYs = this.Y.getActions
        def ok(x: GAction): Boolean = x match {
            case x: GIO => aYs.contains(x.toLAction(x.subj))
            case x: GNu => aYs.exists(_.isInstanceOf[LNu])  // !!! -- just pick one, <: will do any others
        }
        if (aGs.forall(x => ok(x))) aGs else Set.empty

    override def stepPi(a: GAction): Either[String, (ComSim, Path)] =
        val aYs = this.Y.getActions
        val err = s"Cannot step $a in: $this"
        for {
            aY <- a match {
                case x: GIO => Right(x.toLAction(x.subj))
                case x: GNu => aYs.find(_.isInstanceOf[LNu]).toRight("aaaa" + err)  // just pick one, <: will do any others
            }
            G1 <- this.G.stepPi(a)
            Y1 <- this.Y.stepPi(aY).map((Y, pi) => (Y.gcAll, pi))
            _YG <- G1._1.G.projectSystem(this.G.rcom).toRight("bbbb" + err)
            res <- Either.cond(Y1._1.pre(_YG) && G1._2 == Y1._2,
                (ComSim(G1._1, _YG), G1._2),
                "cccc" + err)
        } yield res

    override def isSafeTermination: Boolean = this.G.isSafeTermination && this.Y.isSafeTermination

    override def run(): Unit = SSystem.run(this)

    override def toString: String = s"ComSim(\n\tG=${this.G.G}\n\tY=${this.Y})"
}


/* ... */

case class FidSim(G: GSystem, Y: LSystem) extends SSystem[FidSim, LAction] {

    override def getActions: Set[LAction] =
        val aYs = this.Y.getActions
        val aGs = this.G.getActions
        def ok(x: YAction): Boolean = x match {
            case x: LAction => aGs.contains(x.toGAction)
            case _ => throw new RuntimeException(s"Shouldn't get here $x")  // Y already gc'd (LRho)
        }
        if (aYs.forall(x => ok(x))) aYs.map(_.asInstanceOf[LAction]) else Set.empty

    override def stepPi(a: LAction): Either[String, (FidSim, Path)] =
        val aG = a.toGAction
        val err = s"Cannot step $a in: $this"
        for {
            Y1 <- this.Y.stepPi(a).map((Y, pi) => (Y.gcAll, pi))
            G1 <- this.G.stepPi(aG)
            _YG <- G1._1.G.projectSystem(this.G.rcom).toRight("dddd" + err)
            res <- Either.cond(Y1._1.pre(_YG) && G1._2 == Y1._2,
                (FidSim(G1._1, _YG), G1._2),
                "eeee" + err)
        } yield res

    override def isSafeTermination: Boolean = this.G.isSafeTermination && this.Y.isSafeTermination

    override def run(): Unit = SSystem.run(this)

    override def toString: String = s"ComSim(\n\tG=${this.G.G}\n\tY=${this.Y})"
}



