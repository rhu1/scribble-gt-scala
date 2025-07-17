package com.github.rhu1.gt.`type`.session.local

import com.github.rhu1.gt.`type`.session
import com.github.rhu1.gt.`type`.session.*
import com.github.rhu1.gt.util.{ConsoleColours, PipeForwards}

import scala.collection.immutable.ListMap

trait LType extends SType {

    def subs(x: Map[RecVar, LType]): LType

    def unfold: LType = this

    //def unfoldAllImmediate: LType = this

    def unfoldAllOncePrefix: LType = unfoldAllOncePrefixAux(Set())
    protected[local] def unfoldAllOncePrefixAux(done: Set[RecVar]): LType

    // Pre: q.keySet contains all relevant roles
    def getActions(subj: Role, pi: Path, q: Sigma): Set[LAction] =
        unfoldAllOncePrefix |> (_.getActionsAux(subj, pi, q))
    protected[local] def getActionsAux(subj: Role, pi: Path, q: Sigma): Set[LAction]

    // Sigma is local (in) queue -- send queue managed by System.step
    def step(com: Map[Mid, Set[Op]], pi: Path, a: LAction, q: Sigma):
            Either[String, (Path, LType, Sigma)]
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

    override def subs(x: Map[RecVar, LType]): LSelect =
        LSelect(this.dst, this.cases.map((k, v) => (k, v.subs(x))))

    protected[local] def unfoldAllOncePrefixAux(done: Set[RecVar]): LType =
        LSelect(this.dst, cases.map((k, v) => (k, v.unfoldAllOncePrefixAux(done))))

    /* ... */

    override def getActionsAux(subj: Role, pi: Path, q: Sigma): Set[LAction] =
        this.cases.keySet.map((o, d) => LSend(subj, this.dst, o, d))

    override def step(com: Map[Mid, Set[Op]], pi: Path, a: LAction, q: Sigma):
            Either[String, (Path, LType, Sigma)] =
        val err = s"Cannot step $a in: ($pi, $this, $q)"
        a match {
            case LSend(src, dst, op, pay) if src == a.subj && dst == this.dst =>
                for {
                    cont <- this.cases.get((op, pay)).toRight(err)
                } yield (pi, cont, q)
            case _ => Left(err)
        }

    /* ... */

    override def toString: String =
        s"${this.dst}${ConsoleColours.OLPLUS}${SType.casesToString(this.cases)}"
}

case class LBranch(src: Role, cases: ListMap[(Op, Payload), LType]) extends LType {

    /* ... */

    def subs(x: Map[RecVar, LType]): LBranch =
        LBranch(this.src, this.cases.map((k, v) => (k, v.subs(x))))

    protected[local] def unfoldAllOncePrefixAux(done: Set[RecVar]): LType =
        LBranch(this.src, cases.map((k, v) => (k, v.unfoldAllOncePrefixAux(done))))

    /* ... */

    override def getActionsAux(subj: Role, pi: Path, q: Sigma): Set[LAction] =
        q(this.src).find(m => this.cases.contains(m.op, m.pay) && m.pi == pi) match {
            case None => Set()
            case Some(x) => Set(LRecv(this.src, subj, x.op, x.pay))
        }

    override def step(com: Map[Mid, Set[Op]], pi: Path, a: LAction, q: Sigma):
            Either[String, (Path, LType, Sigma)] =
        val err = s"Cannot step $a in: ($pi, $this, $q)"
        a match {
            case LRecv(src, dst, op, pay) if dst == a.subj && src == this.src =>
                for {
                    cont <- this.cases.get((op, pay)).toRight(err)
                    qs <- q.get(this.src).toRight(err)
                    qs1 <- {
                        def f(x: Msg): Boolean = x.op == op && x.pay == pay && x.pi == pi
                        val i = qs.indexWhere(f)
                        if (i == -1) Left(err) else Right(qs.take(i) ++ qs.drop(i+1))
                    }
                } yield (pi, cont, q + (src -> qs1))
            case _ => Left(err)
        }

    /* ... */

    override def toString: String =
        s"${this.src}&${SType.casesToString(this.cases)}"
}

// !!! consider LOtherMixed, LObserverMixed
case class LMixed(id: Mid, left: LType, obs: Role, right: LType) extends LType {

    /* ... */

    def subs(x: Map[RecVar, LType]): LMixed =
        LMixed(this.id, this.left.subs(x), this.obs, this.right.subs(x))

    protected[local] def unfoldAllOncePrefixAux(done: Set[RecVar]): LType =
        LMixed(this.id, this.left.unfoldAllOncePrefixAux(done), this.obs, this.right.unfoldAllOncePrefixAux(done))

    /* ... */

    override def getActionsAux(subj: Role, pi: Path, q: Sigma): Set[LAction] =
        Set(LNu(subj, this.id))

    override def step(com: Map[Mid, Set[Op]], pi: Path, a: LAction, q: Sigma):
            Either[String, (Path, LType, Sigma)] =
        val err = s"Cannot step $a in: ($pi, $this, $q)"
        a match {
            case LNu(subj, c) if c == this.id =>
                Right((pi, LActiveMixed(this.id, this.left, this.obs, this.right), q))
            case _ => Left(err)
        }

    /* ... */

    override def toString: String =
        s"[${this.left} ${ConsoleColours.WHITE_TRIANGLE}${id}_${this.obs} ${this.right}]"
}

// Active but not committed
case class LActiveMixed(id: Mid, left: LType, obs: Role, right: LType) extends LType {

    /* ... */

    def subs(x: Map[RecVar, LType]): LActiveMixed =
        LActiveMixed(this.id, this.left.subs(x), this.obs, this.right.subs(x))

    protected[local] def unfoldAllOncePrefixAux(done: Set[RecVar]): LType =
        LActiveMixed(this.id, this.left.unfoldAllOncePrefixAux(done), this.obs, this.right.unfoldAllOncePrefixAux(done))

    /* ... */

    override def getActionsAux(subj: Role, pi: Path, q: Sigma): Set[LAction] =
        // !!! includes context rule \nu's
        val left = this.left.getActionsAux(subj, pi :+ pL, q)
        val right = this.right.getActionsAux(subj, pi :+ pR, q)
        if ((left intersect right).nonEmpty) {
            throw new RuntimeException(s"Shouldn't get here: left=$left, right = $right\n\t$this")
        } else {
           left union right
        }

    override def step(com: Map[Mid, Set[Op]], pi: Path, a: LAction, q: Sigma):
            Either[String, (Path, LType, Sigma)] =
        val err = s"Cannot step $a in: ($pi, $this, $q)"
        a match {
            case LSend(src, dst, op, pay) => //Left(err)
                val left = this.left.step(com, pi :+ pL, a, q)
                val right = this.right.step(com, pi :+ pR, a, q)
                (left, right) match {
                    case (Right(pi1, l1, q1), Left(_)) =>   // LSnd
                        Right((pi1, LActiveMixed(this.id, l1, this.obs, this.right), q1))
                    case (Left(_), Right(pi1, l1, q1)) =>  // RSnd 
                        Right((pi1, LActiveRight(this.id, l1), q1))
                    case _ => Left(err)
                }
            case LRecv(src, dst, op, pay) =>
                val left = this.left.step(com, pi :+ pL, a, q)
                val right = this.right.step(com, pi :+ pR, a, q)
                (left, right) match {
                    case (Right(pi1, l1, q1), Left(_)) =>  // LRcv1
                        if (com(this.id) contains op) {
                            Right((pi1, LActiveLeft(this.id, l1), q1))
                        } else {  // LRcv2
                            Right((pi1, LActiveMixed(this.id, l1, this.obs, this.right), q1))
                        }
                    case (Left(_), Right(pi1, l1, q1)) =>  // RRcv -- subj == src == this.obs
                        Right((pi1, LActiveRight(this.id, l1), q1))
                    case _ => Left(err)
                }
            case LNu(subj, c) =>  // !!!
                val left = this.left.step(com, pi :+ pL, a, q)
                val right = this.right.step(com, pi :+ pR, a, q)
                (left, right) match {
                    case (Right(pi1, l1, q1), Left(_)) =>
                        Right((pi1, LActiveMixed(this.id, l1, this.obs, this.right), q1))
                    case (Left(_), Right(pi1, l1, q1)) => Left(err)
                        Right((pi1, LActiveMixed(this.id, this.left, this.obs, l1), q1))
                    case _ => Left(err)
                }
            case _ => Left(err)
        }

    /* ... */

    override def toString: String =
        s"[${this.left} ${ConsoleColours.BLACK_TRIANGLE}${id}_${this.obs} ${this.right}]"
}

// !!! no obs -- ...also LActiveMixed ?
case class LActiveLeft(id: Mid, left: LType) extends LType {

    /* ... */

    def subs(x: Map[RecVar, LType]): LActiveLeft =
        LActiveLeft(this.id, this.left.subs(x))

    protected[local] def unfoldAllOncePrefixAux(done: Set[RecVar]): LType =
        LActiveLeft(this.id, this.left.unfoldAllOncePrefixAux(done))

    /* ... */

    override def getActionsAux(subj: Role, pi: Path, q: Sigma): Set[LAction] =
        this.left.getActionsAux(subj, pi :+ pL, q)

    override def step(com: Map[Mid, Set[Op]], pi: Path, a: LAction, q: Sigma):
            Either[String, (Path, LType, Sigma)] =
        val err = s"Cannot step $a in: ($pi, $this, $q)"
        for {
            left <- this.left.step(com, pi :+ pL, a, q)
            (pi1, _L1, q1) = left
        } yield (pi1, LActiveLeft(this.id, _L1), q1)

    /* ... */

    override def toString: String =
        s"[${this.left} ${ConsoleColours.BLACK_TRIANGLE}${id} ${ConsoleColours.BULLET}]"
}

case class LActiveRight(id: Mid, right: LType) extends LType {

    /* ... */

    def subs(x: Map[RecVar, LType]): LActiveRight =
        LActiveRight(this.id, this.right.subs(x))

    protected[local] def unfoldAllOncePrefixAux(done: Set[RecVar]): LType =
        LActiveRight(this.id, this.right.unfoldAllOncePrefixAux(done))

    /* ... */

    override def getActionsAux(subj: Role, pi: Path, q: Sigma): Set[LAction] =
        this.right.getActionsAux(subj, pi :+ pR, q)

    override def step(com: Map[Mid, Set[Op]], pi: Path, a: LAction, q: Sigma):
            Either[String, (Path, LType, Sigma)] =
        val err = s"Cannot step $a in: ($pi, $this, $q)"
        for {
            right <- this.right.step(com, pi :+ pR, a, q)
            (pi1, _L1, q1) = right
        } yield (pi1, LActiveRight(this.id, _L1), q1)

    /* ... */

    override def toString: String =
        s"[${ConsoleColours.BULLET} ${ConsoleColours.BLACK_TRIANGLE}${id} ${this.right}]"
}

case class LRec(rvar: RecVar, body: LType) extends LType {

    /* ... */

    override def subs(x: Map[RecVar, LType]): LType =
        if (x.contains(this.rvar)) this else LRec(this.rvar, this.body.subs(x))

    override def unfold: LType = this.body.subs(Map(this.rvar -> this))

    override protected[local] def unfoldAllOncePrefixAux(done: Set[RecVar]): LType =
        if (done.contains(this.rvar)) {
            LEnd
        } else {
            unfold |> (_.unfoldAllOncePrefixAux(done + this.rvar))
        }

    /* ... */

    override def getActionsAux(subj: Role, pi: Path, q: Sigma): Set[LAction] =
        unfold |> (_.getActionsAux(subj, pi, q))

    override def step(com: Map[Mid, Set[Op]], pi: Path, a: LAction, q: Sigma):
            Either[String, (Path, LType, Sigma)] = unfold.step(com, pi, a, q)

    /* ... */

    override def toString: String = s"rec ${this.rvar} . ${this.body}"
}

case class LRecVar(rvar: RecVar) extends LType {

    /* ... */

    override def subs(x: Map[RecVar, LType]): LType = x.getOrElse(this.rvar, this)

    protected[local] def unfoldAllOncePrefixAux(done: Set[RecVar]): LType =
        throw new RuntimeException(s"Shouldn't get here: $this")

    /* ... */

    override def getActionsAux(subj: Role, pi: Path, q: Sigma): Set[LAction] =
        throw new RuntimeException(s"Shouldn't get here: $this")

    override def step(com: Map[Mid, Set[Op]], pi: Path, a: LAction, q: Sigma):
            Either[String, (Path, LType, Sigma)] =
        Left(s"Cannot step $a in: ($pi, $this, $q)")

    /* ... */

    override def toString: String = rvar.toString
}

object LEnd extends LType {

    /* ... */

    override def subs(x: Map[RecVar, LType]): LEnd.type = this

    protected[local] def unfoldAllOncePrefixAux(done: Set[RecVar]): LEnd.type = this

    /* ... */

    override def getActionsAux(subj: Role, pi: Path, q: Sigma): Set[LAction] = Set()

    override def step(com: Map[Mid, Set[Op]], pi: Path, a: LAction, q: Sigma):
            Either[String, (Path, LType, Sigma)] =
        Left(s"Cannot step $a in: ($pi, $this, $q)")

    /* ... */

    override def toString: String = "end"
}


