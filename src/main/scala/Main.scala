import org.scribble.ast.global.*
import org.scribble.ast.name.simple.{OpNode, RecVarNode, RoleNode}
import org.scribble.ast.{Module, MsgNode, SigLitNode}
import org.scribble.core.`type`.name.{DataName, GProtoName, ModuleName, PayElemType}
import org.scribble.ext.gt.cli.GTCommandLine2

import scala.jdk.CollectionConverters.*

object Main {

    def main(args: Array[String]): Unit = {
        println("Hello")

        // GTCommandLine2 Test4.scr (-fair -v)
        // -Dstdout.encoding=UTF-8 -Dstderr.encoding=UTF-
        // org.scribble.ext.gt.cli.GTCommandLine2
        // [-gt-explicit-observer-left-commits] -fair -v C:\Users\Raymond\winroot\home\eey335\code\java\intellij\git\github.com\rhu1-scribble-core-gt\scribble-java\scribble-test\src\test\scrib\tmp\Test4.scr
        //new GTCommandLine2()
        //GTCommandLine2.main(Array("-fair", "-v", "C:\\Users\\Raymond\\winroot\\home\\eey335\\code\\java\\intellij\\git\\github.com\\rhu1-scribble-core-gt\\scribble-java\\scribble-test\\src\\test\\scrib\\tmp\\Test4.scr"))
        //GTCommandLine2.main(Array("-fair", "-v", System.getProperty("user.dir") + "\\src\\test\\scrib\\Test.scr"))

        val parsed = collection.immutable.Map(
            new GTCommandLine2("-fair", "-v", System.getProperty("user.dir") + "\\src\\test\\scrib\\Test.scr").gtMain()
                                                                                                              .asScala.toList: _*)
        println("\n[GT] Translated:")

        val translated = getTranslatedProtocols(parsed)

        println(s"\n${translated}")
    }

    def getTranslatedProtocols(parsed: Map[ModuleName, Module]): Map[GProtoName, GType] =
        parsed.values.flatMap(m => m.getGProtoDeclChildren.asScala.map(p => (
            p.getFullMemberName(m),
            translateSeq(p.getDefChild.getBlockChild.getInteractSeqChild))
        )).toMap
}

def translateSeq(p: GInteractionSeq): GType =
    val cs = p.getInteractionChildren.asScala
    cs.slice(0, cs.size - 1).foldRight(translateNode(cs.last))((x, acc) =>
        x match {
            case x: GMsgTransfer => translateGMsgTransferPrefix(x, acc)
            case _ => throw new RuntimeException(s"Cannot translate: ${p}")
        })

def translateNode(p: GSessionNode): GType = p match {
        case x: GMsgTransfer => translateGMsgTransferPrefix(x, GEnd)
        case x: GChoice => translateGChoice(x)
        case x: GRecursion => translateGRecursion(x)
        case x: GContinue => translateGContinue(x)
        case _ => throw new RuntimeException(s"TODO: $p")
    }

def translateGChoice(x: GChoice): GInteraction =
    val src = translateRoleNode(x.getSubjectChild)
    val bs = x.getBlockChildren.asScala.map(y =>
        y.getInteractSeqChild
            |> translateSeq
            |> (_.unfoldAllImmediate)
            |> (_.asInstanceOf[GInteraction]))
    val dst = bs.head.dst
    if (bs.forall(x => x.src == src && x.dst == dst)) {
        GInteraction(src, dst, bs.flatMap(x => x.cases).toMap)
    } else {
        throw new RuntimeException("Inconsistent choice ")
    }

def translateGRecursion(x: GRecursion): GRec = GRec(
    translateRecVarNode(x.getRecVarChild), translateSeq(x.getBlockChild.getInteractSeqChild))

def translateGContinue(x: GContinue): GRecVar = GRecVar(translateRecVarNode(x.getRecVarChild))

def translateGMsgTransferPrefix(x: GMsgTransfer, y: GType): GInteraction =
    val ds = x.getDestinationChildren
    if (ds.size() > 1) throw new RuntimeException(s"TODO: ${x}")
    val dst = ds.getFirst
    GInteraction(
        translateRoleNode(x.getSourceChild),
        translateRoleNode(dst),
        Map(translateMsgNode(x.getMessageNodeChild) -> y)
    )

def translateRoleNode(x: RoleNode): Role = Role(x.toString)
def translateOpNode(x: OpNode): Op = Op(x.toString)
def translatePayload(x: org.scribble.core.`type`.session.Payload): Payload =
    Payload(x.elems.asScala.map(translatePayElemType).toList)
def translatePayElemType(x: PayElemType[?]): Data = x match {
        case x: DataName => Data(x.toString)
        case _ => throw new RuntimeException(s"TODO: ${x}")
    }
def translateMsgNode(x: MsgNode): (Op, Payload) = x match {
        case x: SigLitNode =>
            (translateOpNode(x.getOpChild), translatePayload(x.getPayloadListChild.toPayload))
        case _ => throw new RuntimeException("sTODO: s{x}")
    }
def translateRecVarNode(x: RecVarNode): RecVar = RecVar(x.toString)


/* ... */

trait Name(name: String) {
    override def toString: String = this.name
}
case class Role(name: String) extends Name(name) {}
case class Op(name: String) extends Name(name) {}
case class Data(name: String) extends Name(name) {}
case class Payload(elems: List[Data]) {
   override def toString: String = this.elems.mkString(", ")
}
case class RecVar(name: String) extends Name(name) {}

trait GType {
    def subs(x: Map[RecVar, GType]): GType
    def unfold: GType = this
    def unfoldAllImmediate: GType = this
}

object GEnd extends GType {
    override def subs(x: Map[RecVar, GType]): GType = this
    override def toString: String = "end"
}

case class GRec(rvar: RecVar, body: GType) extends GType {
    override def subs(x: Map[RecVar, GType]): GType =
        if (x.contains(this.rvar)) this else GRec(this.rvar, this.body.subs(x))
    override def unfold: GType = this.body.subs(Map(this.rvar -> this))
    override def unfoldAllImmediate: GType = unfold.unfold  // Assumes contractive...
    override def toString: String = s"rec ${this.rvar} . ${this.body}"
}

case class GRecVar(rvar: RecVar) extends GType {
    override def subs(x: Map[RecVar, GType]): GType = x.getOrElse(this.rvar, this)
    override def toString: String = rvar.toString
}

case class GInteraction(
        src: Role,
        dst: Role,
        cases: Map[(Op, Payload), GType]
    ) extends GType {

    override def subs(x: Map[RecVar, GType]): GType =
        GInteraction(this.src, this.dst, this.cases.map((k, v) => (k, v.subs(x))))

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

implicit class PipeForwards[A](a: A) extends AnyVal {
    def |>[B](f: A => B): B = f(a)
}

implicit class PipeBackwards[A, B](val f: A => B) {
    def <| (a: A): B = f(a)
}
