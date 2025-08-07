package com.github.rhu1.gt.`type`.session.local

import com.github.rhu1.gt.`type`.session
import com.github.rhu1.gt.`type`.session.*
import com.github.rhu1.gt.`type`.session.global.Scrib2GT
import com.github.rhu1.gt.util.{ConsoleColours, PipeForwards}
import org.scribble.core.`type`.name.DataName
import org.scribble.ext.gt.core.model.efsm.{GTEFSM, GTVRecVar, GTVState}
import org.scribble.ext.gt.core.model.efsm.event.{GTVAction, GTVEpsilon, GTVEpsilonStar, GTVEvent, GTVRecv, GTVSend, GTVTau}

import scala.collection.immutable.ListMap
import scala.jdk.CollectionConverters.*

/*
    public final Set<GTVState> S;
    public final GTVState init;
    public final Set<GTVEvent> E;
    public final Set<GTVAction> A;
    public final Map<
            Pair<GTVState, GTVEvent>,
            Set<Pair<GTVAction, GTVState>>> delta;
 */
case class EFSM(
       S: scala.collection.mutable.LinkedHashSet[GTVState],
       init: GTVState,
       E: scala.collection.mutable.LinkedHashSet[GTVEvent],
       A: scala.collection.mutable.LinkedHashSet[GTVAction],
       delta: scala.collection.mutable.LinkedHashMap[(GTVState, GTVEvent), scala.collection.mutable.LinkedHashSet[(GTVAction, GTVState)]]
) {}

trait LType extends SType {

    /* ... */

    def subs(x: Map[RecVar, LType]): LType

    def unfold: LType = this

    //def unfoldAllImmediate: LType = this

    /*def unfoldAllOncePrefix: LType = unfoldAllOncePrefixAux(Set())
    protected[local] def unfoldAllOncePrefixAux(done: Set[RecVar]): LType*/

    /* ... */

    def construct(r: Role, com: Map[Mid, Set[Op]], recvStars: Map[Mid, (GTVRecv, GTVState)],
        c: Mid, s: GTVState, end: GTVState): EFSM

    /* ... */

    // Pre: q.keySet contains all relevant roles
    def getActions(subj: Role, pi: Path, q: Sigma): Set[LAction]

    // Sigma is local (in) queue -- send queue managed by System.step
    // For leafs, a.pi == env
    // For all, res Path == a.pi
    def step(com: Map[Mid, Set[Op]], pi: Path, a: LAction, q: Sigma):
            Either[String, (Path, LType, Sigma)]

    def isEnded: Boolean

    // this <: x
    def pre(x: LType): Boolean = LType.pre(this, x)
}

object LType {

    /* ... */

    def merge(x: LType, y: LType): Option[LType] =
        if (x == y) {
            Some(x)
        } else {
            //println(s"mmmmm1:\n\t$x\n\t$y")
            (x, y) match {
                case (LBranch(src1, cases1), LBranch(src2, cases2)) =>
                    if (src1 == src2
                            && cases1.keySet.intersect(cases2.keySet).isEmpty) {  // HERE TODO relax, check intersect identity
                        Some(LBranch(src1, cases1 ++ cases2))
                    } else {
                        None
                    }
                case (LRec(rvar1, body1), LRec(rvar2, body2)) if (rvar1 == rvar2) =>
                    merge(body1, body2).map(z => LRec(rvar1, z))
                case _ => None  // !!! no MC cases
            }
        }

    /*def runtimeMerge(x: LType, y: LType): Option[LType] =
        if (x == y) {
            Some(x)
        } else {
            println(s"mmmmm2:\n\t$x\n\t$y")
            (x, y) match {
                case (_, LEnd) => Some(LEnd)  // XXX not general, cf. OnlineWallet (need to merge Sel/Bra...) => need regular choice committment to distinguish third-party wiggly cases of merge versus committed
                case (LEnd, _) => Some(LEnd)
                case (LBranch(src1, cases1), LBranch(src2, cases2)) =>
                    if (src1 == src2
                            && cases1.keySet.intersect(cases2.keySet).isEmpty) {  // HERE TODO relax, check intersect identity
                        Some(LBranch(src1, cases1 ++ cases2))
                    } else {
                        None
                    }
                case (LRec(rvar1, body1), LRec(rvar2, body2)) if (rvar1 == rvar2) =>
                    merge(body1, body2).map(z => LRec(rvar1, z))
                case _ => None  // !!! no MC cases
            }
        }*/

    def mergeSigma(x: Sigma, y: Sigma): Option[Sigma] = if (x == y) Some(x) else None

    /* ... */

    def convertRole(r: Role): org.scribble.core.`type`.name.Role =
        new org.scribble.core.`type`.name.Role(r.toString)

    def convertOp(op: Op): org.scribble.core.`type`.name.Op =
        new org.scribble.core.`type`.name.Op(op.toString)

    def convertPay(pay: Payload): org.scribble.core.`type`.session.Payload =
        val ds: java.util.List[org.scribble.core.`type`.name.PayElemType[?]] =   // !!! annot needed
            pay.elems.map(convertPayElem).asJava
        new org.scribble.core.`type`.session.Payload(ds)

    def convertPayElem(d: Data): org.scribble.core.`type`.name.DataName =
        new org.scribble.core.`type`.name.DataName(d.toString)

    def convertRecVar(rvar: RecVar): org.scribble.core.`type`.name.RecVar =
        new org.scribble.core.`type`.name.RecVar(rvar.toString)

    /* ... */

    // x <: y -- x fastforward to y including under nested non-redex contexts
    def pre(x: LType, y: LType): Boolean = (x, y) match {
        /*case (LBranch(s1, c1), LBranch(s2, c2)) =>
            s1 == s2 && c2.keySet.subsetOf(c1.keySet) &&  // !!! fast forward, not subtype -- branch/select same variance
                c2.keySet.forall(k => pre(c1(k), c2(k)))
        case (LSelect(s1, c1), LSelect(s2, c2)) =>
            s1 == s2 && c1.keySet.subsetOf(c2.keySet) &&
                c2.keySet.forall(k => pre(c1(k), c2(k)))*/
        case (LBranch(s1, c1), LBranch(s2, c2)) if c1.keySet == c2.keySet
            || c2.keySet.size == 1 =>  // !!! fast forward, not subtype -- branch/select same variance
            s1 == s2 && c2.keySet.forall(k => pre(c1(k), c2(k)))
        case (LSelect(s1, c1), LSelect(s2, c2)) if c1.keySet == c2.keySet
            || c2.keySet.size == 1 =>
            s1 == s2 && c2.keySet.forall(k => pre(c1(k), c2(k)))
        case (LMixed(i1, l1, o1, r1), LMixed(i2, l2, o2, r2)) =>
            i1 == i2 && pre(l1, l2) && o1 == o2 && pre(r1, r2)
        case (LActiveMixed(i1, l1, r1), LActiveMixed(i2, l2, r2)) =>
            i1 == i2 && pre(l1, l2) && pre(r1, r2)
        case (LMixed(i1, l1, o1, r1), LActiveMixed(i2, l2, r2)) =>
            i1 == i2 && pre(l1, l2) && pre(r1, r2)
        case (LActiveLeft(i1, l1), LActiveLeft(i2, l2)) => i1 == i2 && pre(l1, l2)
        case (LActiveRight(i1, r1), LActiveRight(i2, r2)) => i1 == i2 && pre(r1, r2)
        case (LRec(v1, b1), LRec(v2, b2)) =>
            (v1 == v2 && pre(b1, b2)) || pre(x.unfold, y)  // this direction of unfold only for FF
        case (LRec(v1, b1), _) => pre(x.unfold, y)
        case (LRecVar(v1), LRecVar(v2)) => v1 == v2
        case (LEnd, LEnd) => true
        case _ => false
    }
}


/* ... */

case class LSelect(dst: Role, cases: ListMap[(Op, Payload), LType]) extends LType {

    /* ... */

    override def subs(x: Map[RecVar, LType]): LSelect =
        LSelect(this.dst, this.cases.map((k, v) => (k, v.subs(x))))

    /*override protected[local] def unfoldAllOncePrefixAux(done: Set[RecVar]): LType =
        LSelect(this.dst, cases.map((k, v) => (k, v.unfoldAllOncePrefixAux(done))))*/

    /* ... */

    def construct(r: Role, com: Map[Mid, Set[Op]], recvStars: Map[Mid, (GTVRecv, GTVState)],
                  c: Mid, s: GTVState, end: GTVState): EFSM = {
        val S = scala.collection.mutable.LinkedHashSet(s)
        val E: scala.collection.mutable.LinkedHashSet[GTVEvent] = scala.collection.mutable.LinkedHashSet.empty
        val A: scala.collection.mutable.LinkedHashSet[GTVAction] = scala.collection.mutable.LinkedHashSet.empty
        val delta: scala.collection.mutable.LinkedHashMap[(GTVState, GTVEvent), scala.collection.mutable.LinkedHashSet[(GTVAction, GTVState)]] = scala.collection.mutable.LinkedHashMap.empty

        for (((op_i, _), succ_i) <- this.cases) {
            var stars: Map[Mid, (GTVRecv, GTVState)] = recvStars
            for ((yk, yv) <- com) {
                if (yv.contains(op_i)) {
                    stars = stars - yk
                }
            }
            val s_i = new GTVState(c)
            val m_i = succ_i.construct(r, com, stars, c, s_i, end)
            S.addAll(m_i.S)
            E.addAll(m_i.E)
            A.addAll(m_i.A)
            val e = new GTVTau(LType.convertOp(op_i))
            val a = new GTVSend(LType.convertRole(this.dst), LType.convertOp(op_i), LType.convertPay(getPay(op_i)))

            val tmp = delta.getOrElseUpdate((s, e), scala.collection.mutable.LinkedHashSet.empty)
            tmp.add((a, m_i.init))
            for ((k, v) <- m_i.delta) {
                val tmp2 = delta.getOrElseUpdate(k, scala.collection.mutable.LinkedHashSet.empty)
                tmp2.addAll(v)
            }
        }

        LMixed.drawExternals(recvStars, s, delta)
        EFSM(S, s, E, A, delta)
    }

    /* ... */

    override def getActions(subj: Role, env: Path, q: Sigma): Set[LAction] =
        this.cases.keySet.map((o, d) => LSend(env, subj, this.dst, o, d))

    override def step(com: Map[Mid, Set[Op]], env: Path, a: LAction, q: Sigma):
            Either[String, (Path, LType, Sigma)] =
        val err = s"Cannot step $a in: ($env, $this, $q)"
        a match {
            case LSend(pi, src, dst, op, pay) if pi == env && src == a.subj && dst == this.dst =>
                for {
                    cont <- this.cases.get((op, pay)).toRight(err)
                } yield (pi, cont, q)
            case _ => Left(err)
        }

    override def isEnded: Boolean = false

    /* ... */

    override def toString: String =
        s"${this.dst}${ConsoleColours.OLPLUS}${SType.casesToString(this.cases)}"

    def getPay(op: Op): Payload =
        this.cases.find { case ((o, p), _) => o == op }.get._1._2
}

case class LBranch(src: Role, cases: ListMap[(Op, Payload), LType]) extends LType {

    /* ... */

    override def subs(x: Map[RecVar, LType]): LBranch =
        LBranch(this.src, this.cases.map((k, v) => (k, v.subs(x))))

    /*override protected[local] def unfoldAllOncePrefixAux(done: Set[RecVar]): LType =
        LBranch(this.src, cases.map((k, v) => (k, v.unfoldAllOncePrefixAux(done))))*/

    /* ... */

    def construct(r: Role, com: Map[Mid, Set[Op]], recvStars: Map[Mid, (GTVRecv, GTVState)],
                  c: Mid, s: GTVState, end: GTVState): EFSM = {
        val S = scala.collection.mutable.LinkedHashSet(s)
        val E: scala.collection.mutable.LinkedHashSet[GTVEvent] = scala.collection.mutable.LinkedHashSet.empty
        val A: scala.collection.mutable.LinkedHashSet[GTVAction] = scala.collection.mutable.LinkedHashSet.empty
        val delta: scala.collection.mutable.LinkedHashMap[(GTVState, GTVEvent), scala.collection.mutable.LinkedHashSet[(GTVAction, GTVState)]] = scala.collection.mutable.LinkedHashMap.empty

        for (((op_i, _), succ_i) <- this.cases) {
            var stars: Map[Mid, (GTVRecv, GTVState)] = recvStars
            for ((yk, yv) <- com) {
                if (yv.contains(op_i)) {
                    stars = stars - yk
                }
            }
            val s_i = new GTVState(c)
            val m_i = succ_i.construct(r, com, stars, c, s_i, end)
            S.addAll(m_i.S)
            E.addAll(m_i.E)
            A.addAll(m_i.A)
            val e = new GTVRecv(LType.convertRole(this.src), LType.convertOp(op_i), LType.convertPay(getPay(op_i)))

            val tmp = delta.getOrElseUpdate((s, e), scala.collection.mutable.LinkedHashSet.empty)
            tmp.add((GTVEpsilon.EPSILON, m_i.init))
            for ((k, v) <- m_i.delta) {
                val tmp2 = delta.getOrElseUpdate(k, scala.collection.mutable.LinkedHashSet.empty)
                tmp2.addAll(v)
            }
        }

        LMixed.drawExternals(recvStars, s, delta)
        EFSM(S, s, E, A, delta)
    }

    /* ... */

    override def getActions(subj: Role, env: Path, q: Sigma): Set[LAction] =
        q(this.src).find(m => this.cases.contains(m.op, m.pay) && m.pi == env) match {
            case None => Set()
            case Some(x) => Set(LRecv(env, this.src, subj, x.op, x.pay))
        }

    override def step(com: Map[Mid, Set[Op]], env: Path, a: LAction, q: Sigma):
            Either[String, (Path, LType, Sigma)] =
        val err = s"Cannot step $a in: ($env, $this, $q)"
        a match {
            case LRecv(pi, src, dst, op, pay) if pi == env && dst == a.subj && src == this.src =>
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

    override def isEnded: Boolean = false

    /* ... */

    override def toString: String =
        s"${this.src}&${SType.casesToString(this.cases)}"

    def getPay(op: Op): Payload =
        this.cases.find { case ((o, p), _) => o == op }.get._1._2
}

// !!! consider LOtherMixed, LObserverMixed
case class LMixed(id: Mid, left: LType, obs: Role, right: LType) extends LType {

    /* ... */

    override def subs(x: Map[RecVar, LType]): LMixed =
        LMixed(this.id, this.left.subs(x), this.obs, this.right.subs(x))

    /*override protected[local] def unfoldAllOncePrefixAux(done: Set[RecVar]): LType =
        LMixed(this.id, this.left.unfoldAllOncePrefixAux(done), this.obs, this.right.unfoldAllOncePrefixAux(done))*/

    /* ... */

    override def getActions(subj: Role, env: Path, q: Sigma): Set[LAction] =
        Set(LNu(env, subj, this.id))

    override def step(com: Map[Mid, Set[Op]], env: Path, a: LAction, q: Sigma):
            Either[String, (Path, LType, Sigma)] =
        val err = s"Cannot step $a in: ($env, $this, $q)"
        a match {
            case LNu(pi, subj, c) if pi == env && c == this.id =>
                Right((pi, LActiveMixed(this.id, this.left, this.right), q))
            case _ => Left(err)
        }

    override def isEnded: Boolean = false

    /* ... */

    override def toString: String =
        s"[${this.left} ${ConsoleColours.WHITE_TRIANGLE}${id}_${this.obs} ${this.right}]"
}

object LMixed {

    def drawExternals(recvStars: Map[Mid, (GTVRecv, GTVState)], init: GTVState,
                                delta: scala.collection.mutable.LinkedHashMap[(GTVState, GTVEvent), scala.collection.mutable.LinkedHashSet[(GTVAction, GTVState)]]): Unit = {
        for ((a, s) <- recvStars.values) {
            val tmp = delta.getOrElseUpdate((init, a), scala.collection.mutable.LinkedHashSet.empty)
            tmp.add((GTVEpsilonStar.EPSILON_STAR, s))
        }
    }
}

// Active but not committed
case class LActiveMixed(id: Mid, left: LType, //obs: Role,  // Unnecessary and awkward for runtime projection (e.g., end cases)
        right: LType) extends LType {

    /* ... */

    override def subs(x: Map[RecVar, LType]): LActiveMixed =
        LActiveMixed(this.id, this.left.subs(x), this.right.subs(x))

    /*override protected[local] def unfoldAllOncePrefixAux(done: Set[RecVar]): LType =
        LActiveMixed(this.id, this.left.unfoldAllOncePrefixAux(done), this.obs, this.right.unfoldAllOncePrefixAux(done))*/

    /* ... */

    override def construct(r: Role, com: Map[Mid, Set[Op]], recvStars: Map[Mid, (GTVRecv, GTVState)],
                  c: Mid, s: GTVState, end: GTVState): EFSM =
        throw new RuntimeException(s"Unsupported: $this")

    /* ... */

    override def getActions(subj: Role, pi: Path, q: Sigma): Set[LAction] =
        // !!! includes context rule \nu's
        val left = this.left.getActions(subj, pi :+ pL, q)
        val right = this.right.getActions(subj, pi :+ pR, q)
        if ((left intersect right).nonEmpty) {
            throw new RuntimeException(s"Shouldn't get here: left=$left, right = $right\n\t$this")
        } else {
           left union right
        }

    override def step(com: Map[Mid, Set[Op]], env: Path, a: LAction, q: Sigma):
            Either[String, (Path, LType, Sigma)] =
        val err = s"Cannot step $a in: ($env, $this, $q)"
        a match {
            case LSend(pi, src, dst, op, pay) =>
                val left = this.left.step(com, env :+ pL, a, q)
                val right = this.right.step(com, env :+ pR, a, q)
                (left, right) match {
                    case (Right(pi1, l1, q1), Left(_)) =>   // LSnd  // pi1 == a.pi
                        Right((pi1, LActiveMixed(this.id, l1, this.right), q1))
                    case (Left(_), Right(pi1, l1, q1)) =>  // RSnd   // pi1 == a.pi
                        Right((pi1, LActiveRight(this.id, l1), q1))
                    case _ => Left(err)
                }
            case LRecv(pi, src, dst, op, pay) =>
                val left = this.left.step(com, env :+ pL, a, q)
                val right = this.right.step(com, env :+ pR, a, q)
                (left, right) match {
                    case (Right(pi1, l1, q1), Left(_)) =>  // LRcv1  // pi1 == a.pi
                        if (com(this.id) contains op) {
                            Right((pi1, LActiveLeft(this.id, l1), q1))
                        } else {  // LRcv2
                            Right((pi1, LActiveMixed(this.id, l1, this.right), q1))
                        }
                    case (Left(_), Right(pi1, l1, q1)) =>  // RRcv -- subj == src == this.obs, pi1 == a.pi
                        Right((pi1, LActiveRight(this.id, l1), q1))
                    case _ => Left(err)
                }
            case LNu(pi, subj, c) =>  // !!!
                val left = this.left.step(com, env :+ pL, a, q)
                val right = this.right.step(com, env :+ pR, a, q)
                (left, right) match {
                    case (Right(pi1, l1, q1), Left(_)) =>  // pi1 == a.pi
                        Right((pi1, LActiveMixed(this.id, l1, this.right), q1))
                    case (Left(_), Right(pi1, l1, q1)) =>  // pi1 == a.pi
                        Right((pi1, LActiveMixed(this.id, this.left, l1), q1))
                    case _ => Left(err)
                }
        }

    override def isEnded: Boolean = false

    /* ... */

    override def toString: String =
        s"[${this.left} ${ConsoleColours.BLACK_TRIANGLE}${id} ${this.right}]"
}

// !!! no obs -- ...also LActiveMixed ?
case class LActiveLeft(id: Mid, left: LType) extends LType {

    /* ... */

    override def subs(x: Map[RecVar, LType]): LActiveLeft =
        LActiveLeft(this.id, this.left.subs(x))

    /*override protected[local] def unfoldAllOncePrefixAux(done: Set[RecVar]): LType =
        LActiveLeft(this.id, this.left.unfoldAllOncePrefixAux(done))*/

    /* ... */

    override def construct(r: Role, com: Map[Mid, Set[Op]], recvStars: Map[Mid, (GTVRecv, GTVState)],
                           c: Mid, s: GTVState, end: GTVState): EFSM =
        throw new RuntimeException(s"Unsupported: $this")

    /* ... */

    override def getActions(subj: Role, env: Path, q: Sigma): Set[LAction] =
        this.left.getActions(subj, env :+ pL, q)

    override def step(com: Map[Mid, Set[Op]], env: Path, a: LAction, q: Sigma):
            Either[String, (Path, LType, Sigma)] =
        val err = s"Cannot step $a in: ($env, $this, $q)"
        for {
            left <- this.left.step(com, env :+ pL, a, q)
            (pi1, _L1, q1) = left  // q1 == a.pi
        } yield (pi1, LActiveLeft(this.id, _L1), q1)

    override def isEnded: Boolean = this.left.isEnded

    /* ... */

    override def toString: String =
        s"[${this.left} ${ConsoleColours.BLACK_TRIANGLE}${id} ${ConsoleColours.BULLET}]"
}

case class LActiveRight(id: Mid, right: LType) extends LType {

    /* ... */

    override def subs(x: Map[RecVar, LType]): LActiveRight =
        LActiveRight(this.id, this.right.subs(x))

    /*override protected[local] def unfoldAllOncePrefixAux(done: Set[RecVar]): LType =
        LActiveRight(this.id, this.right.unfoldAllOncePrefixAux(done))*/

    /* ... */

    override def construct(r: Role, com: Map[Mid, Set[Op]], recvStars: Map[Mid, (GTVRecv, GTVState)],
                           c: Mid, s: GTVState, end: GTVState): EFSM =
        throw new RuntimeException(s"Unsupported: $this")

    /* ... */

    override def getActions(subj: Role, env: Path, q: Sigma): Set[LAction] =
        this.right.getActions(subj, env :+ pR, q)

    override def step(com: Map[Mid, Set[Op]], env: Path, a: LAction, q: Sigma):
            Either[String, (Path, LType, Sigma)] =
        val err = s"Cannot step $a in: ($env, $this, $q)"
        for {
            right <- this.right.step(com, env :+ pR, a, q)
            (pi1, _L1, q1) = right  // q1 == a.pi
        } yield (pi1, LActiveRight(this.id, _L1), q1)

    override def isEnded: Boolean = this.right.isEnded

    /* ... */

    override def toString: String =
        s"[${ConsoleColours.BULLET} ${ConsoleColours.BLACK_TRIANGLE}${id} ${this.right}]"
}

case class LRec(rvar: RecVar, body: LType) extends LType {

    /* ... */

    override def subs(x: Map[RecVar, LType]): LType =
        if (x.contains(this.rvar)) this else LRec(this.rvar, this.body.subs(x))

    override def unfold: LType = this.body.subs(Map(this.rvar -> this))

    /*override protected[local] def unfoldAllOncePrefixAux(done: Set[RecVar]): LType =
        if (done.contains(this.rvar)) {
            LEnd
        } else {
            unfold |> (_.unfoldAllOncePrefixAux(done + this.rvar))
        }*/

    /* ... */

    override def construct(r: Role, com: Map[Mid, Set[Op]], recvStars: Map[Mid, (GTVRecv, GTVState)],
                           c: Mid, s: GTVState, end: GTVState): EFSM =
        val recvars = s.recvars.asScala + LType.convertRecVar(this.rvar)
        val s1 = new GTVState(s.isEntry, c, recvars.asJava)
        EFSM(scala.collection.mutable.LinkedHashSet(s1), s1, scala.collection.mutable.LinkedHashSet.empty, scala.collection.mutable.LinkedHashSet.empty, scala.collection.mutable.LinkedHashMap.empty)

    /* ... */

    override def getActions(subj: Role, pi: Path, q: Sigma): Set[LAction] =
        unfold |> (_.getActions(subj, pi, q))

    override def step(com: Map[Mid, Set[Op]], pi: Path, a: LAction, q: Sigma):
            Either[String, (Path, LType, Sigma)] = unfold.step(com, pi, a, q)

    override def isEnded: Boolean = false

    /* ... */

    override def toString: String = s"rec ${this.rvar} . ${this.body}"
}

case class LRecVar(rvar: RecVar) extends LType {

    /* ... */

    override def subs(x: Map[RecVar, LType]): LType = x.getOrElse(this.rvar, this)

    /*override protected[local] def unfoldAllOncePrefixAux(done: Set[RecVar]): LType =
        throw new RuntimeException(s"Shouldn't get here: $this")*/

    /* ... */

    override def construct(r: Role, com: Map[Mid, Set[Op]], recvStars: Map[Mid, (GTVRecv, GTVState)],
                           c: Mid, s: GTVState, end: GTVState): EFSM =
        val s1 = new GTVRecVar(c, LType.convertRecVar(this.rvar))
        EFSM(scala.collection.mutable.LinkedHashSet(s1), s1, scala.collection.mutable.LinkedHashSet.empty, scala.collection.mutable.LinkedHashSet.empty, scala.collection.mutable.LinkedHashMap.empty)

    /* ... */

    override def getActions(subj: Role, env: Path, q: Sigma): Set[LAction] =
        throw new RuntimeException(s"Shouldn't get here: $this")

    override def step(com: Map[Mid, Set[Op]], env: Path, a: LAction, q: Sigma):
            Either[String, (Path, LType, Sigma)] =
        Left(s"Cannot step $a in: ($env, $this, $q)")

    override def isEnded: Boolean = false

    /* ... */

    override def toString: String = rvar.toString
}

object LEnd extends LType {

    /* ... */

    override def subs(x: Map[RecVar, LType]): LEnd.type = this

    //override protected[local] def unfoldAllOncePrefixAux(done: Set[RecVar]): LEnd.type = this

    /* ... */

    override def construct(r: Role, com: Map[Mid, Set[Op]], recvStars: Map[Mid, (GTVRecv, GTVState)],
                  c: Mid, s: GTVState, end: GTVState): EFSM =
        EFSM(scala.collection.mutable.LinkedHashSet(end), end, scala.collection.mutable.LinkedHashSet.empty, scala.collection.mutable.LinkedHashSet.empty, scala.collection.mutable.LinkedHashMap.empty)

    /* ... */

    override def getActions(subj: Role, env: Path, q: Sigma): Set[LAction] = Set()

    override def step(com: Map[Mid, Set[Op]], env: Path, a: LAction, q: Sigma):
            Either[String, (Path, LType, Sigma)] =
        Left(s"Cannot step $a in: ($env, $this, $q)")

    override def isEnded: Boolean = true

    /* ... */

    override def toString: String = "end"
}


