package com.github.rhu1.gt.`type`.session.global

import com.github.rhu1.gt.*
import com.github.rhu1.gt.`type`.session.*
import com.github.rhu1.gt.`type`.session.global.*
import com.github.rhu1.gt.util.*
import org.scribble.ast.global.*
import org.scribble.ast.name.simple.{OpNode, RecVarNode, RoleNode}
import org.scribble.ast.{MsgNode, SigLitNode}
import org.scribble.core.`type`.name.{DataName, PayElemType}
import org.scribble.ext.gt.ast.global.GTGMixed

import scala.collection.immutable.ListMap
import scala.jdk.CollectionConverters.*


object Scrib2GT {

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
        case x: GTGMixed => translateGMixed(x)
        case _ => throw new RuntimeException(s"TODO: $p")
    }

    def translateGMixed(x: GTGMixed): GMixed =
        val left = translateSeq(x.getLeftBlockChild.getInteractSeqChild)
            .unfoldAllImmediate.asInstanceOf[GInteraction]
        val right = translateSeq(x.getRightBlockChild.getInteractSeqChild)
            .unfoldAllImmediate.asInstanceOf[GInteraction]
        if (left.src != right.dst || left.dst != right.src) {
            throw new RuntimeException(s"Inconsistent mixed roles: \n\tleft =$left\n\tright=$right")
        }
        val oth = translateRoleNode(x.getOtherChild)
        val obs = translateRoleNode(x.getObserverChild)
        GMixed(nextMid, left, oth, obs, right)

    def translateGChoice(x: GChoice): GInteraction =
        val src = translateRoleNode(x.getSubjectChild)
        val bs = x.getBlockChildren.asScala.map(y =>
            y.getInteractSeqChild
                |> translateSeq
                |> (_.unfoldAllImmediate)
                |> (_.asInstanceOf[GInteraction]))
        val dst = bs.head.dst
        if (bs.forall(x => x.src == src && x.dst == dst)) {
            GInteraction(src, dst, ListMap(bs.flatMap(x => x.cases.toSeq).toSeq: _*))
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
            ListMap(translateMsgNode(x.getMessageNodeChild) -> y)
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
}
