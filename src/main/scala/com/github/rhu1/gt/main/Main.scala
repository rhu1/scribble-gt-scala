package com.github.rhu1.gt.main

import com.github.rhu1.gt.*
import com.github.rhu1.gt.`type`.session.*
import com.github.rhu1.gt.`type`.session.global.{ComSim, FidSim, GSystem, GType, Scrib2GT}
import com.github.rhu1.gt.`type`.session.local.*
import org.scribble.ast.Module
import org.scribble.core.`type`.name.{GProtoName, ModuleName}
import org.scribble.ext.gt.cli.GTCommandLine2
import org.scribble.ext.gt.codegen.erlang.{GTCallbackModule, GTGenericBehaviour, GTGenRoleGen, GTRoleGen}
import org.scribble.ext.gt.core.model.efsm.{GTEFSM, GTVState}

import java.io.File
import java.nio.charset.StandardCharsets
import java.nio.file.Files

import scala.jdk.CollectionConverters.*

// TODO
// - (Option =>) Either[Exception, ..]
// - balanced up-to

trait CLArg {}

// Analysis
object CheckFidelity extends CLArg {
    def unapply(x: CLArg): Boolean = x == this //x.isInstanceOf[CheckFidelity.type]
}

object CheckCompleteness extends CLArg {
    def unapply(x: CLArg): Boolean = x == this
}

object PrintEFSMAll extends CLArg {
    def unapply(x: CLArg): Boolean = x == this
}

object GenerateCallbackAll extends CLArg {
    def unapply(x: CLArg): Boolean = x == this
}

object GenerateBehaviourAll extends CLArg {
    def unapply(x: CLArg): Boolean = x == this
}

object GenerateAllModulesAll extends CLArg {
    def unapply(x: CLArg): Boolean = x == this
}

// Code generation (Erlang runtime + role implementation)
object GenerateErlangFSMsAll extends CLArg {
    def unapply(x: CLArg): Boolean = x == this
}

case class GenerateErlangFSMs(
    simple: GProtoName,
    roles: Seq[Role] = Seq.empty,
    outDir: String = "./generated",
    emitGC: Boolean = false
) extends CLArg {}

// simple name (not fully qualified); r is GT Role
case class PrintEFSM(simple: GProtoName, r: Role) extends CLArg {}
case class PrintRM(simple: GProtoName, r: Role) extends CLArg {}
case class PrintCM(simple: GProtoName, r: Role) extends CLArg {}
case class GenerateCallback(simple: GProtoName, r: Role) extends CLArg {}
case class GenerateBehaviour(simple: GProtoName, r: Role) extends CLArg {}
case class GenerateAllModules(simple: GProtoName, r: Role) extends CLArg {}


object Main {

    // Returns: (unparsed, parsed)  -- order preserved within each side
    private def parseArgs(args: List[String]): (List[String], List[CLArg]) =
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
            case "-gt-generate-callback-all" :: tail => cs(GenerateCallbackAll, parseArgs(tail))
            case "-gt-generate-callback" :: n :: r :: tail => cs(GenerateCallback(new GProtoName(n), Role(r)), parseArgs(tail))
            case "-gt-generate-behaviour-all" :: tail => cs(GenerateBehaviourAll, parseArgs(tail))
            case "-gt-generate-behaviour" :: n :: r :: tail => cs(GenerateBehaviour(new GProtoName(n), Role(r)), parseArgs(tail))
            case "-gt-generate-erlang-all" :: tail => cs(GenerateAllModulesAll, parseArgs(tail))
            case "-gt-generate-erlang" :: n :: r :: tail => cs(GenerateAllModules(new GProtoName(n), Role(r)), parseArgs(tail))

            // New: generate FSM-based Erlang modules (gen_role + role.erl + role.hrl)
            case "-gt-generate-fsms-all" :: tail => cs(GenerateErlangFSMsAll, parseArgs(tail))
            case "-gt-generate-fsms" :: n :: tail =>
                // Parse optional flags: -roles ... -out DIR -gc
                val (roles, outDir, emitGC, rest) = parseCodegenTail(Seq.empty, "./generated", true, tail)
                cs(GenerateErlangFSMs(new GProtoName(n), roles.map(Role.apply), outDir, emitGC), parseArgs(rest))

            case "-gt-help" :: tail => cs(Help, parseArgs(tail))
            case "-h" :: tail => cs(Help, parseArgs(tail))

            case h :: t => cf(h, parseArgs(t))
        }

    private object Help extends CLArg {
        def unapply(x: CLArg): Boolean = x == this
    }

    private def usage(): Unit = {
        println(
            s"""
               |Usage:
               |  sbt "runMain com.github.rhu1.gt.main.Main <path/to/file.scr> [GT options]"
               |
               |FSM-based Erlang generation:
               |  -gt-generate-fsms <ProtoSimpleName> [-all | -roles R1 R2 ...] [-out DIR] [-gc]
               |  -gt-generate-fsms-all
               |
               |Flags:
               |  -roles ...    Generate only for the listed roles (space-separated)
               |  -all          Generate for all roles (default if -roles is omitted)
               |  -out DIR      Output base directory (default: ./generated)
               |  -gc           Enable idle GC support (gc_timeout/0, on_gc/2 hooks and runtime scheduling)
               |""".stripMargin
        )
    }

    // Parse generator flags after -gt-generate-fsms <Proto>
    private def parseCodegenTail(
        roles: Seq[String],
        outDir: String,
        emitGC: Boolean,
        args: List[String]
    ): (Seq[String], String, Boolean, List[String]) = args match {
        case Nil => (roles, outDir, emitGC, Nil)
        case "-roles" :: tail =>
            val (rs, rest) = tail.span(s => !s.startsWith("-"))
            parseCodegenTail(roles ++ rs, outDir, emitGC, rest)
        case "-all" :: tail =>
            // Explicitly clear any previously-set roles
            parseCodegenTail(Seq.empty, outDir, emitGC, tail)
        case "-out" :: dir :: tail =>
            parseCodegenTail(roles, dir, emitGC, tail)
        case "-gc" :: tail =>
            parseCodegenTail(roles, outDir, true, tail)
        case "-proto" :: _ :: _ =>
            // -proto is handled at the top-level (selecting which protocol to generate)
            // so stop consuming flags here.
            (roles, outDir, emitGC, args)
        case other :: _ =>
            // Stop parsing when we hit something we don't recognise; let outer parseArgs handle it.
            (roles, outDir, emitGC, args)
    }

    def main(args: Array[String]): Unit = {
        val (baseargs, gtargs) = parseArgs(args.toList)
        val fileName = if (baseargs.nonEmpty) baseargs.head else System.getProperty("user.dir") + "/src/test/scrib/Test.scr"

        if (gtargs.exists(_.isInstanceOf[Help.type])) {
            usage()
            return
        }

        val parsed = collection.immutable.Map(
            new GTCommandLine2("-fair", "-v", fileName).gtMain().asScala.toList: _*)

        println("\n[GT] Translating:")
        val translated = getTranslatedProtocols(parsed)
        def findFullName(simple: GProtoName): GProtoName =
            translated.keySet.find(x => x.getLastElement == simple.toString).get
        println(s"\n$translated")

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
                throw new RuntimeException(s"Invalid: $n")
            }
        })

        println("\n[GT] Projecting:\n")
        val projected = translated.map((n, G) => (
            n,
            G.getLiveRoles.map(r => r -> G.project(r).getOrElse(
                    throw new RuntimeException(s"Couldn't project to $r: $G"))
            ).toMap
        ))
        projected.foreach((n, rL) => rL.foreach((r, L) => println(s"$n@$r: $L")))

        // map key is full name -- cf. findFullName (from simple name) above
        val efsms = projected.map((n, rL) => {
            val rcom = translated(n).getRoleCommitting
            (n, rL.map((r, _L) => {
                // Reset state numbering per (protocol, role) generation run.
                // (Previously done in CodegenCLI; needed because GTVState uses a global counter.)
                GTVState.resetCounter()
                val s_init = new GTVState(GTVState.TOP_SCOPE)
                val end = new GTVState(GTVState.TOP_SCOPE)
                (r, _L.construct(r, rcom(r), Map.empty, GTVState.TOP_SCOPE, s_init, end).toGTEFSM)
            }))
        })

        // Helper function to generate callback modules with access to translated protocols
        def generateCallbackModule(n: GProtoName, r: Role, efsm: GTEFSM): Unit = {
            try {
                val protocolName = n.getLastElement
                val javaRole = LType.convertRole(r)
                val sigmaRoles = translated.get(n) match {
                    case Some(gtype) => gtype.getLiveRoles.map(LType.convertRole).asJava
                    case None => throw new RuntimeException(s"Could not find protocol $n")
                }

                val callbackModule = new GTCallbackModule()
                callbackModule.generate(protocolName, javaRole, efsm, sigmaRoles)
                println(s"\n[GT] Generated Callback Module for $n@$r in ./generated/$protocolName/")
            } catch {
                case e: java.io.IOException =>
                    println(s"\n[GT] Error generating Callback Module for $n@$r: ${e.getMessage}")
                case e: Exception =>
                    println(s"\n[GT] Unexpected error generating Callback Module for $n@$r: ${e.getMessage}")
            }
        }

        // Helper function to generate behaviour modules with access to translated protocols
        def generateBehaviourModule(n: GProtoName, r: Role, efsm: GTEFSM): Unit = {
            try {
                val protocolName = n.getLastElement
                val javaRole = LType.convertRole(r)
                val gtype = translated.get(n) match {
                    case Some(gtype) => gtype
                    case None => throw new RuntimeException(s"Could not find protocol $n")
                }
                val sigmaRoles = gtype.getLiveRoles.map(LType.convertRole).asJava

                // Convert role committing information to explicit committing format
                val roleCommitting = gtype.getRoleCommitting.get(r) match {
                    case Some(roleComMap) => roleComMap
                    case None => Map.empty[Mid, Set[Op]]
                }

                val explicitCommiting: java.util.Map[Integer, java.util.Set[org.scribble.core.`type`.name.Op]] =
                    roleCommitting.map { case (mid, ops) =>
                        val javaOps = ops.map(op => new org.scribble.core.`type`.name.Op(op.toString)).asJava
                        (mid.asInstanceOf[Integer], javaOps)
                    }.asJava

                val behaviourModule = new GTGenericBehaviour()
                println("==============" + efsm)
                behaviourModule.generateCode(protocolName, javaRole, efsm, explicitCommiting, sigmaRoles)
                println(s"\n[GT] Generated Behaviour Module for $n@$r in ./generated/$protocolName/")
            } catch {
                case e: java.io.IOException =>
                    println(s"\n[GT] Error generating Behaviour Module for $n@$r: ${e.getMessage}")
                case e: Exception =>
                    println(s"\n[GT] Unexpected error generating Behaviour Module for $n@$r: ${e.getMessage}")
            }
        }

        // Helper: generate the FSM-based Erlang modules (gen_role + role.erl + role.hrl)
        def generateFSMModules(
            protoSimple: String,
            r: Role,
            efsm: GTEFSM,
            allRolesLower: Seq[String],
            outBase: String,
            emitGC: Boolean
        ): Unit = {
            val roleAtom = r.toString.toLowerCase
            val outDir = new File(outBase, protoSimple)
            outDir.mkdirs()

            writeHrl(outDir, roleAtom, allRolesLower)

            com.github.rhu1.gt.codegen.RuntimeModuleGenerator.generate(protoSimple, roleAtom, efsm, outDir, emitGC = emitGC)
            com.github.rhu1.gt.codegen.CallbackModuleGenerator.generateCallback(protoSimple, roleAtom, efsm, outDir, allRolesLower, emitGC = emitGC)

            println(s"\n[GT] Wrote gen_${roleAtom}.erl / ${roleAtom}.erl / ${roleAtom}.hrl to ${outDir.getPath} (gc=$emitGC)")
        }

        def writeHrl(outDir: File, roleAtom: String, rolesLower: Seq[String]): Unit = {
            val hrlPath = outDir.toPath.resolve(s"${roleAtom}.hrl")
            val peerRoles = rolesLower.filterNot(_ == roleAtom)
            val mcPathField = "mc_path = [] :: [atom()]"
            val peerFields = if (peerRoles.nonEmpty) peerRoles.map(r => s"${r}_pid :: pid() | undefined").mkString(", ") else ""
            val allFields = List(Some(mcPathField), if (peerFields.nonEmpty) Some(peerFields) else None).flatten.mkString(", ")
            val record = s"-record(state_data, {${allFields}})."
            val content =
                s"""
                   |-ifndef(${roleAtom.toUpperCase}_HRL).
                   |-define(${roleAtom.toUpperCase}_HRL, true).
                   |
                   |${record}
                   |
                   |-endif.
                   |""".stripMargin
            Files.write(hrlPath, content.getBytes(StandardCharsets.UTF_8))
        }

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
            case GenerateCallbackAll() =>
                for ((n, rM) <- efsms) {
                    for ((r, _M) <- rM) {
                        generateCallbackModule(n, r, _M)
                    }
                }
            case GenerateCallback(simple, r) =>
                val full = findFullName(simple)
                generateCallbackModule(full, r, efsms(full)(r))
            case GenerateBehaviourAll() =>
                for ((n, rM) <- efsms) {
                    for ((r, _M) <- rM) {
                        generateBehaviourModule(n, r, _M)
                    }
                }
            case GenerateBehaviour(simple, r) =>
                val full = findFullName(simple)
                generateBehaviourModule(full, r, efsms(full)(r))
            case GenerateAllModulesAll() =>
                for ((n, rM) <- efsms) {
                    for ((r, _M) <- rM) {
                        generateCallbackModule(n, r, _M)
                        generateBehaviourModule(n, r, _M)
                    }
                }
            case GenerateAllModules(simple, r) =>
                val full = findFullName(simple)
                generateCallbackModule(full, r, efsms(full)(r))
                generateBehaviourModule(full, r, efsms(full)(r))

            // New: generate FSM-based Erlang modules (gen_role + role.erl + role.hrl)
            case GenerateErlangFSMsAll() =>
                for ((n, rM) <- efsms) {
                    val protoSimple = n.getLastElement
                    val allRolesLower = translated(n).getLiveRoles.toSeq.map(_.toString.toLowerCase)
                    for ((r, _M) <- rM) {
                        generateFSMModules(protoSimple, r, _M, allRolesLower, "./generated", emitGC = false)
                    }
                }

            case GenerateErlangFSMs(simple, roles, outDir, emitGC) =>
                val full = findFullName(simple)
                val protoSimple = full.getLastElement
                val gtype = translated(full)

                val roleSet: Seq[Role] =
                    if (roles.nonEmpty) roles
                    else efsms(full).keys.toSeq

                val allRolesLower = gtype.getLiveRoles.toSeq.map(_.toString.toLowerCase)
                roleSet.foreach { r =>
                    val efsm = efsms(full)(r)
                    generateFSMModules(protoSimple, r, efsm, allRolesLower, outDir, emitGC)
                }

            case x => throw new RuntimeException(s"Unknown arg: $x")
        }

        /*// Debug output for API gen
        for ((n, rM) <- efsms) {
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
        val rcom = G.getRoleCommitting
        println(s"$n:\nCommitting: $rcom")
        val ps = rL.map((r, L) => r -> Participant(r, rcom(r), L, Sigma(R) - r))
        LSystem(ps)

    /**
     * Translate parsed Scribble modules into GT global protocol types.
     *
     * Exposed for other entrypoints (e.g. code generators) that need access
     * to the same translation logic as the main CLI.
     */
    def getTranslatedProtocols(parsed: Map[ModuleName, Module]): Map[GProtoName, GType] =
        parsed.values.flatMap(m => m.getGProtoDeclChildren.asScala.map(p => (
            p.getFullMemberName(m),
            Scrib2GT.translateSeq(p.getDefChild.getBlockChild.getInteractSeqChild))
        )).toMap
}
