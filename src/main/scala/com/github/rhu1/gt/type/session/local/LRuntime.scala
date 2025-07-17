package com.github.rhu1.gt.`type`.session.local

import com.github.rhu1.gt.`type`.session.*

import scala.annotation.tailrec


sealed trait YAction {
    val subj: Role
}

case class LRho(subj: Role) extends YAction {}

sealed trait LAction extends YAction { }

// !!! Same as GAction -- N.B. not using Msg, correspondence just erases pi anyway...
sealed abstract class LIO extends LAction {
    val src: Role
    val dst: Role
    val op: Op
    val pay: Payload
}

case class LSend(src: Role, dst: Role, op: Op, pay: Payload) extends LIO {
    val subj: Role = src
    override def toString: String = s"$src!$dst:$op($pay)"
}

case class LRecv(src: Role, dst: Role, op: Op, pay: Payload) extends LIO {
    val subj: Role = dst
    override def toString: String = s"$src?$dst:$op($pay)"  // pq?a -- p is sender
}

// !!! subj and c
case class LNu(subj: Role, c: Mid) extends LAction {}


/* ... */

/*// !!! using Sig (not Msg) for LAction -- correspondence just erases pi...
case class Sig(op: Op, pay: Payload) {

    //def toMsg: Msg = Msg(this.op, this.pay, EPSILON)

    override def toString: String = s"$op($pay)"
}*/

// !!! m = alpha  // Actual queue contents (cf. LAction, no pi)
case class Msg(op: Op, pay: Payload, pi: Path) {

    def isStale(L: LType): Boolean = Msg.isStaleAux(this.pi, L)

    override def toString: String =
        val pay = if (this.pay.elems.isEmpty) "" else s"$this.pay, "
        s"$op($pay$pi)"
}

object Msg {

    @tailrec
    private def isStaleAux(pi: Path, L: LType): Boolean = pi match {
        case List() => false  // EPSILON == List() == Nil
        case h :: t => h match {
            //case pL() => L match {
            case _: pL.type => L match {
                case LActiveRight(_, _) => true
                case LActiveLeft(_, x) => isStaleAux(t, x)
                case LActiveMixed(_, x, _, _) => isStaleAux(t, x)
                case _ => false
            }
            //case pL() => L match {
            case _: pR.type => L match {
                case LActiveLeft(_, _) => true
                case LActiveRight(_, x) => isStaleAux(t, x)
                case LActiveMixed(_, _, _, x) => isStaleAux(t, x)
                case _ => false
            }
        }
    }
}

// Role is src
type Sigma = Map[Role, List[Msg]]
val EMPTY_SIGMA = Map.empty[Role, List[Msg]]

object Sigma {
    def apply(rs: Set[Role]): Sigma = rs.map(r => (r, List.empty[Msg])).toMap
}

implicit class SigmaOps[A <: Sigma](a: A) {

    def circ(b: A): Option[Sigma] =
        if (a.keySet == b.keySet) {
            Some(a.map((r, ms) => (r, ms ++ b(r))))
        } else {
            None
        }

    def containsStale(L: LType): Boolean = a.values.exists(ms => ms.exists(_.isStale(L)))

    def gc(L: LType): Sigma = a.map((r, ms) => (r, ms.filter(!_.isStale(L))))
}

sealed trait pLR {}
object pL extends pLR {
    def unapply(x: pLR): Boolean = true
    override def toString: String = "l"
}
object pR extends pLR {
    def unapply(x: pLR): Boolean = true
    override def toString: String = "r"
}

type Path = List[pLR]
val EPSILON: Path = List.empty[pLR]

case class Participant(r: Role, com: Map[Mid, Set[Op]], L: LType, q: Sigma) {

    // Only includes LRho when not a "skip"
    def getActions: Set[YAction] =
        val gc: Set[YAction] =
            if (this.q.containsStale(this.L)) Set(LRho(this.r)) else Set.empty[YAction]
        gc ++ this.L.getActions(this.r, EPSILON, q)  // cf. union

    def step(a: YAction): Either[String, (Path, Participant)] = a match {
        case a: LRho => gc(a).map(x => (EPSILON, x))  // gc top level, pi unused anyway
        case a: LAction => stepPi(a)
    }

    // Actual message communicated (if any) is LAction[Msg] version of (a, pi)
    private def stepPi(a: LAction): Either[String, (Path, Participant)] =
        this.L.step(com, EPSILON, a, this.q).map(
            (pi, L1, q1) => (pi, Participant(this.r, this.com, L1, q1)))

    def gc(a: LRho): Either[String, Participant] =
        Either.cond(a.subj == this.r,
            Participant(this.r, this.com, L, this.q.gc(this.L)),
            s"Cannot gc $a in: $this"
        )
}

case class LSystem(ps: Map[Role, Participant]) {

    // Post: Set[YAction] nonEmpty
    def getActions: Map[Role, Set[YAction]] =
        this.ps.map((r, p) => (r, p.getActions))
               .filter((r, as) => as.nonEmpty)

    def step(a: YAction): Either[String, LSystem] = a match {
        case LSend(src, dst, op, pay) =>
            val err = s"Cannot step $a in: $this"
            for {
                ps <- this.ps.get(src).toRight(err)
                pp <- ps.step(a)
                (pi, ps1) = pp
                pd <- this.ps.get(dst).toRight(err)
                qs <- pd.q.get(src).map(_.appended(Msg(op, pay, pi))).toRight(err)
                pd1 = Participant(dst, pd.com, pd.L, pd.q + (src -> qs))
            } yield LSystem(this.ps + (src -> ps1) + (dst -> pd1))
        case _ =>  // Other LActions and LRho
            for {
                p <- this.ps.get(a.subj).toRight(s"Cannot step $a in: $this")
                p1 <- p.step(a)
            } yield LSystem(this.ps + (a.subj -> p1._2))
    }

    def run(): Unit = LSystem.run(this)

    override def toString: String =
        val ps = this.ps.mkString("\n\t")
        s"LSystem(\n\t$ps)"
}

object LSystem {

    def run(Y: LSystem): Unit = {
        var n = 0
        def nextN: Int = { n += 1; n }

        val hist = collection.mutable.Map.empty[LSystem, (Integer, List[YAction])]
        val done = collection.mutable.LinkedHashSet.empty[(LSystem, (Role, YAction))]
        val todo = collection.mutable.LinkedHashSet.empty[(LSystem, (Role, YAction))]
        // Pre: ras = _Y1.getActions -- split for debugging
        def addHist(Y: LSystem, a: YAction, Y1: LSystem): Unit = {
            if (!hist.contains(Y1)) {
                hist += (Y1 -> (nextN, hist(Y)._2 :+ a))
            }
        }
        def addTodo(Y: LSystem, ras: Map[Role, Set[YAction]]): Unit = {
            for (r, as) <- ras; a <- as do // as nonEmpty
                val s = (Y, (r, a)) // r == a.subj, redundant
                if (done.contains(s)) {
                    println(s"\t$a done")
                } else {
                    todo += s
                }
        }

        hist(Y) = (nextN, List.empty)
        val ras = Y.getActions
        addTodo(Y, ras)
        println(s"$Y\n\tactions=$ras\n---")

        while (todo.nonEmpty) {
            val pop = todo.last
            todo -= pop
            done += pop
            val (_Y1, (_, a1)) = pop  // r == a1.subj, redundant
            val (i, trace) = hist(_Y1)
            println(s"$i $_Y1")
            print(s"$trace |- $a1")
            val succ = _Y1.step(a1) match {
                case Left(x) => throw new RuntimeException(x)
                case Right(x) => x
            }
            val ras1 = succ.getActions
            addHist(_Y1, a1, succ)
            addTodo(succ, ras1)
            println(s" -> ${hist(succ)._1} $succ\n\tactions=$ras1")
            n += 1
        }
    }

}

