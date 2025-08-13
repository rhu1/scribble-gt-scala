package com.github.rhu1.gt.main

import com.github.rhu1.gt.*
import com.github.rhu1.gt.`type`.session.*
import com.github.rhu1.gt.`type`.session.global.{ComSim, FidSim, GSystem, GType, Scrib2GT}
import com.github.rhu1.gt.`type`.session.local.*
import org.scribble.ast.Module
import org.scribble.core.`type`.name.{GProtoName, ModuleName}
import org.scribble.ext.gt.cli.GTCommandLine2
import org.scribble.ext.gt.core.model.efsm.{GTEFSM, GTVState}

import scala.jdk.CollectionConverters.*

// TODO
// - Either[Exception, ..]
// - balanced up-to

trait CLArg {}
object CheckFidelity extends CLArg {}
object CheckCompleteness extends CLArg {}
object PrintEFSMAll extends CLArg {}
case class PrintEFSM(simple: GProtoName, r: Role) extends CLArg {}  // simple name (not fully qualified); r is GT Role

object Main {

    // Returns: (unparsed, parsed)  -- order preserved within each side
    def parseArgs(args: List[String]): (List[String], List[CLArg]) =
        val cf = [A, B] => (h: A, t: (List[A], List[B])) => (h :: t._1, t._2)
        val cs = [A, B] => (h: B, t: (List[A], List[B])) => (t._1, h :: t._2)
        args match {
            case Nil => (List.empty, List.empty)
            case "-gt-check-fidelity" :: tail => cs(CheckFidelity, parseArgs(tail))
            case "-gt-check-completeness" :: tail => cs(CheckCompleteness, parseArgs(tail))
            case "-gt-print-efsm-all" :: tail => cs(PrintEFSMAll, parseArgs(tail))
            case "-gt-print-efsm" :: n :: r :: tail => cs(PrintEFSM(new GProtoName(n), Role(r)), parseArgs(tail))
            case h :: t => cf(h, parseArgs(t))
        }

    def main(args: Array[String]): Unit = {

        // GTCommandLine2 Test4.scr (-fair -v)
        // -Dstdout.encoding=UTF-8 -Dstderr.encoding=UTF-
        // org.scribble.ext.gt.cli.GTCommandLine2
        // [-gt-explicit-observer-left-commits] -fair -v C:\Users\Raymond\winroot\home\eey335\code\java\intellij\git\github.com\rhu1-scribble-core-gt\scribble-java\scribble-test\src\test\scrib\tmp\Test4.scr
        //new GTCommandLine2()
        //GTCommandLine2.main(Array("-fair", "-v", "C:\\Users\\Raymond\\winroot\\home\\eey335\\code\\java\\intellij\\git\\github.com\\rhu1-scribble-core-gt\\scribble-java\\scribble-test\\src\\test\\scrib\\tmp\\Test4.scr"))
        //GTCommandLine2.main(Array("-fair", "-v", System.getProperty("user.dir") + "\\src\\test\\scrib\\Test.scr"))

        val (baseargs, gtargs) = parseArgs(args.toList)
        val fileName = if (baseargs.nonEmpty) {
            baseargs.head
        } else {
            System.getProperty("user.dir") + "/src/test/scrib/Test.scr"
        }

        val parsed = collection.immutable.Map(
            new GTCommandLine2("-fair", "-v", fileName).gtMain().asScala.toList: _*)

        println("\n[GT] Translating:")
        val translated = getTranslatedProtocols(parsed)
        println(s"\n${translated}")

        println("\n[GT] Unfolding all once:\n")
        translated.foreach((n, p) => println(s"$n: ${p.unfoldAllOnce}"))

        println("\n[GT] Validating:\n")
        translated.foreach((n, p) => {
            val valid = p.isValid
            println(s"$n: ${if (valid) "OK" else "FAIL"}")
            if (!valid) {
                println(s"\nWF=${p.isWellFormed}")
                println(s"SD=${p.isSingleDecision}")
                println(s"CT=${p.isClearTermination}")
                println(s"BA=${p.isBalanced}")
                throw new RuntimeException(s"Invalid: ${n}")
            }
        })

        /*println("\n[GT] Stepping global:\n")
        for ((n, _G) <- translated) {
            val Gsys = GSystem(_G.getRoleCommitting, _G)
            Gsys.run()
        }*/

        println("\n[GT] Projecting:\n")
        val projected = translated.map((n, G) => (
            n,
            G.getLiveRoles.map(r => r -> G.project(r).getOrElse(
                    throw new RuntimeException(s"Couldn't project to $r: $G"))
            ).toMap
        ))
        projected.foreach((n, rL) => rL.foreach((r, L) => println(s"$n@$r: ${L}")))

        /*println("\n[GT] Stepping local:\n")
        for ((n, _) <- projected) {
            val Y = toLSystem(n, translated(n), projected(n))
            //println(Y)
            Y.run()
        }*/

        if (gtargs.contains(CheckFidelity)) {
            println("\n[GT] Stepping fidelity:\n")
            for ((n, _G) <- translated) {
                val sim = FidSim(toGSystem(_G), toLSystem(n, _G, projected(n)))
                sim.run()
            }
        }

        if (gtargs.contains(CheckCompleteness)) {
            println("\n[GT] Stepping completeness:\n")
            for ((n, _G) <- translated) {
                val sim = ComSim(toGSystem(_G), toLSystem(n, _G, projected(n)))
                sim.run()
            }
        }

        val efsms = projected.map((n, rL) => {
            val rcom = translated(n).getRoleCommitting
            (n, rL.map((r, _L) => {
                val s_init = new GTVState(GTVState.TOP_SCOPE)
                val end = new GTVState(GTVState.TOP_SCOPE)
                (r, _L.construct(r, rcom(r), Map.empty, GTVState.TOP_SCOPE, s_init, end).toGTEFSM)
            }))
        })

        if (gtargs.contains(PrintEFSMAll)) {
            println("\n[GT] Printing all EFSMs:\n")
            for ((n, rM) <- efsms) {
                for ((r, _M) <- rM) {
                    println(s"$n@$r:\n${_M.toDot}")
                }
            }
        }

        gtargs.foreach {
            case x: PrintEFSM => println("\n[GT] Printing EFSM:\n" +
                s"${x.simple}@${x.r}:\n${genEFSM(translated, projected, x.simple, x.r).toDot}")
            case _ =>
        }
    }

    // Pre: n is simple name
    private def genEFSM(translated: Map[GProtoName, GType], projected: Map[GProtoName, Map[Role, LType]],
            simple: GProtoName, r: Role): GTEFSM =
        val full = translated.find((x, _) => x.getLastElement == simple.toString).get._1
        val rcom = translated(full).getRoleCommitting
        val s_init = new GTVState(GTVState.TOP_SCOPE)
        val end = new GTVState(GTVState.TOP_SCOPE)
        val efsm = projected(full)(r).construct(r, rcom(r), Map.empty, GTVState.TOP_SCOPE, s_init, end)
        efsm.toGTEFSM


    private def toGSystem(G: GType): GSystem = GSystem(G.getRoleCommitting, G)

    private def toLSystem(n: GProtoName, G: GType, rL: Map[Role, LType]): LSystem =
        val R = G.getLiveRoles
        //val com = G.getCommitting
        val rcom = G.getRoleCommitting
        println(s"$n:\nCommitting: $rcom")
        val ps = rL.map((r, L) => r -> Participant(r, rcom(r), L, Sigma(R) - r))
        LSystem(ps)

    def getTranslatedProtocols(parsed: Map[ModuleName, Module]): Map[GProtoName, GType] =
        parsed.values.flatMap(m => m.getGProtoDeclChildren.asScala.map(p => (
            p.getFullMemberName(m),
            Scrib2GT.translateSeq(p.getDefChild.getBlockChild.getInteractSeqChild))
        )).toMap
}


