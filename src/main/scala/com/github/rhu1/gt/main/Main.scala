package com.github.rhu1.gt.main

import com.github.rhu1.gt.*
import com.github.rhu1.gt.`type`.session.*
import com.github.rhu1.gt.`type`.session.global.{ComSim, FidSim, GSystem, GType, Scrib2GT}
import com.github.rhu1.gt.`type`.session.local.*
import org.scribble.ast.Module
import org.scribble.core.`type`.name.{GProtoName, ModuleName}
import org.scribble.ext.gt.cli.GTCommandLine2
import org.scribble.ext.gt.codegen.erlang.{GTGenRoleGen, GTRoleGen}
import org.scribble.ext.gt.core.model.efsm.{GTEFSM, GTVState}

import scala.jdk.CollectionConverters.*

// TODO
// - Either[Exception, ..]
// - balanced up-to

trait CLArg {}

object CheckFidelity extends CLArg {
    def unapply(x: CLArg): Boolean = x == this //x.isInstanceOf[CheckFidelity.type]
}

object CheckCompleteness extends CLArg {
    def unapply(x: CLArg): Boolean = x == this
}

object PrintEFSMAll extends CLArg {
    def unapply(x: CLArg): Boolean = x == this
}

// simple name (not fully qualified); r is GT Role
case class PrintEFSM(simple: GProtoName, r: Role) extends CLArg {}
case class PrintRM(simple: GProtoName, r: Role) extends CLArg {}
case class PrintCM(simple: GProtoName, r: Role) extends CLArg {}


object Main {

    // Returns: (unparsed, parsed)  -- order preserved within each side
    def parseArgs(args: List[String]): (List[String], List[CLArg]) =
        val cf = [A, B] => (h: A, t: (List[A], List[B])) => (h :: t._1, t._2)
        val cs = [A, B] => (h: B, t: (List[A], List[B])) => (t._1, h :: t._2)
        args match {
            case Nil => (List.empty, List.empty)
            //case -gt-check-progress  ...run global
            case "-gt-check-fidelity" :: tail => cs(CheckFidelity, parseArgs(tail))
            case "-gt-check-completeness" :: tail => cs(CheckCompleteness, parseArgs(tail))
            case "-gt-print-efsm-all" :: tail => cs(PrintEFSMAll, parseArgs(tail))
            case "-gt-print-efsm" :: n :: r :: tail => cs(PrintEFSM(new GProtoName(n), Role(r)), parseArgs(tail))
            case "-gt-print-rm" :: n :: r :: tail => cs(PrintRM(new GProtoName(n), Role(r)), parseArgs(tail))
            case "-gt-print-cm" :: n :: r :: tail => cs(PrintCM(new GProtoName(n), Role(r)), parseArgs(tail))
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
        def findFullName(simple: GProtoName): GProtoName =
            translated.keySet.find(x => x.getLastElement == simple.toString).get
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

        println("\n[GT] Projecting:\n")
        val projected = translated.map((n, G) => (
            n,
            G.getLiveRoles.map(r => r -> G.project(r).getOrElse(
                    throw new RuntimeException(s"Couldn't project to $r: $G"))
            ).toMap
        ))
        projected.foreach((n, rL) => rL.foreach((r, L) => println(s"$n@$r: ${L}")))

        // !!! map key is full name -- cf. findFullName (from simple name) above
        val efsms = projected.map((n, rL) => {
            val rcom = translated(n).getRoleCommitting
            (n, rL.map((r, _L) => {
                val s_init = new GTVState(GTVState.TOP_SCOPE)
                val end = new GTVState(GTVState.TOP_SCOPE)
                (r, _L.construct(r, rcom(r), Map.empty, GTVState.TOP_SCOPE, s_init, end).toGTEFSM)
            }))
        })

        gtargs.foreach {
            /* // TODO -gt-check-progress
                println("\n[GT] Stepping global:\n")
                for ((n, _G) <- translated) {
                    val Gsys = GSystem(_G.getRoleCommitting, _G)
                    Gsys.run()
                }*/
            case CheckFidelity() =>
                println("\n[GT] Stepping fidelity:\n")
                for ((n, _G) <- translated) {
                    val sim = FidSim(toGSystem(_G), toLSystem(n, _G, projected(n)))
                    sim.run()
                }
            case CheckCompleteness() =>
                println("\n[GT] Stepping completeness:\n")
                for ((n, _G) <- translated) {
                    val sim = ComSim(toGSystem(_G), toLSystem(n, _G, projected(n)))
                    sim.run()
                }
            case PrintEFSMAll() =>
                //println("\n[GT] Printing all EFSMs:\n")
                for ((n, rM) <- efsms) {
                    for ((r, _M) <- rM) {
                        printGTEFSM(n, r, _M)
                    }
                }
            case PrintEFSM(simple, r) =>
                val full = findFullName(simple)
                printGTEFSM(full, r, efsms(full)(r))
            case PrintRM(simple, r) =>
                val full = findFullName(simple)
                printRM(full, r, efsms(full)(r))
            case PrintCM(simple, r) =>
                val full = findFullName(simple)
                printCM(full, r, efsms(full)(r))
            case x => throw new RuntimeException(s"Unknown arg: $x")
        }

        /*for ((n, rM) <- efsms) {
            for ((r, _M) <- rM) {
                val r1 = LType.convertRole(r)
                println(s"\n[debug] Role gen:\n${new GTRoleGen().generate(n, r1, _M)}")
                println(s"\n[debug] Gen role gen:\n${new GTGenRoleGen().generate(n, r1, _M)}")
            }
        }*/
    }

    private def printGTEFSM(n: GProtoName, r: Role, efsm: GTEFSM): Unit =
        println(s"\n[GT] Printing GTEFSM:\n\n$n@$r:\n${efsm.toDot}")

    private def printRM(n: GProtoName, r: Role, efsm: GTEFSM): Unit =
        println(s"\n[GT] Printing RM:\n\n$n@$r:\n${new GTGenRoleGen().generate(n, LType.convertRole(r), efsm)}")

    private def printCM(n: GProtoName, r: Role, efsm: GTEFSM): Unit =
        println(s"\n[GT] Printing CM:\n\n$n@$r:\n${new GTRoleGen().generate(n, LType.convertRole(r), efsm)}")

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


