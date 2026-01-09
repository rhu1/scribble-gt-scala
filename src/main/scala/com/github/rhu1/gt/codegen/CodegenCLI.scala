package com.github.rhu1.gt.codegen

import com.github.rhu1.gt.`type`.session.Role
import com.github.rhu1.gt.`type`.session.global.GType
import com.github.rhu1.gt.`type`.session.local.LType
import com.github.rhu1.gt.main.Main as GTMain
import org.scribble.core.`type`.name.GProtoName
import org.scribble.ext.gt.cli.GTCommandLine2
import org.scribble.ext.gt.core.model.efsm.{GTEFSM, GTVState}

import java.io.File
import java.nio.charset.StandardCharsets
import java.nio.file.{Files, Path}
import scala.jdk.CollectionConverters.*

/**
 * Minimal CLI to generate Erlang modules using CallbackModuleGenerator and RuntimeModuleGenerator.
 */
object CodegenCLI {

  private case class Args(
      scribblePath: String = "",
      protoFilter: Option[String] = None,
      roles: Seq[String] = Seq.empty,
      outBase: File = new File("./generated"),
      emitGC: Boolean = false
  )

  def main(argv: Array[String]): Unit = {
    val args = parseArgs(argv.toList)
    require(args.scribblePath.nonEmpty, "First argument must be a path to a .scr file")

    val parsed = collection.immutable.Map(
      new GTCommandLine2("-fair", "-v", args.scribblePath).gtMain().asScala.toList: _*
    )

    val translated: Map[GProtoName, GType] = GTMain.getTranslatedProtocols(parsed)
    if (translated.isEmpty) sys.error(s"No global protocols found in ${args.scribblePath}")

    // Select protocols to process
    val selected = args.protoFilter match {
      case Some(simple) =>
        translated.filter((n, _) => n.getLastElement == simple)
          .ensuring(_.nonEmpty, s"Protocol '$simple' not found in ${args.scribblePath}")
      case None => translated
    }

    selected.foreach { case (fullName, gtype) =>
      // Project and build EFSMs per role
      val projected: Map[Role, LType] = gtype.getLiveRoles.map { r =>
        r -> gtype.project(r).getOrElse(throw new RuntimeException(s"Couldn't project to $r: $gtype"))
      }.toMap

      val rcom = gtype.getRoleCommitting
      val efsms: Map[Role, GTEFSM] = projected.map { case (r, ltype) =>
        // Reset global state counter so IDs restart per role
        GTVState.resetCounter()
        val sInit = new GTVState(GTVState.TOP_SCOPE)
        val end = new GTVState(GTVState.TOP_SCOPE)
        val efsm = ltype.construct(r, rcom(r), Map.empty, GTVState.TOP_SCOPE, sInit, end).toGTEFSM
        r -> efsm
      }

      val simpleName = fullName.getLastElement
      val outDir = new File(args.outBase, simpleName)
      outDir.mkdirs()

      val targetRoles: Seq[Role] =
        if (args.roles.nonEmpty) {
          val wanted = args.roles.map(_.trim)
          efsms.keys.filter(r => wanted.contains(r.toString)).toSeq
        } else efsms.keys.toSeq

      val allRoles = gtype.getLiveRoles
      println(s"[Codegen] Generating for protocol $simpleName: roles=${targetRoles.mkString(", ")}, outDir=${outDir.getPath}, gc=${args.emitGC}")

      targetRoles.foreach { r =>
        val roleAtom = r.toString.toLowerCase
        val efsm = efsms(r)
        val rolesLower = allRoles.toSeq.map(_.toString.toLowerCase)
        writeHrl(outDir.toPath, roleAtom, rolesLower)
        RuntimeModuleGenerator.generate(simpleName, roleAtom, efsm, outDir, emitGC = args.emitGC)
        CallbackModuleGenerator.generateCallback(simpleName, roleAtom, efsm, outDir, rolesLower, emitGC = args.emitGC)
        println(s"[Codegen] Wrote gen_${roleAtom}.erl and ${roleAtom}.erl")
      }
    }

    println("[Codegen] Done.")
  }

  private def parseArgs(args: List[String]): Args = args match {
    case path :: tail if path.endsWith(".scr") =>
      parseFlags(Args(scribblePath = path), tail)
    case _ =>
      usage()
      sys.error("Invalid arguments")
  }

  private def parseFlags(acc: Args, rest: List[String]): Args = rest match {
    case Nil => acc
    case "-proto" :: name :: tail => parseFlags(acc.copy(protoFilter = Some(name)), tail)
    case "-all" :: tail => parseFlags(acc.copy(roles = Seq.empty), tail)
    case "-roles" :: tail =>
      val (roleNames, remaining) = tail.span(s => !s.startsWith("-"))
      parseFlags(acc.copy(roles = roleNames), remaining)
    case "-out" :: dir :: tail => parseFlags(acc.copy(outBase = new File(dir)), tail)
    case "-gc" :: tail => parseFlags(acc.copy(emitGC = true), tail)
    case other :: _ =>
      usage()
      sys.error(s"Unknown flag: $other")
  }

  private def writeHrl(dir: Path, roleAtom: String, rolesLower: Seq[String]): Unit = {
    val hrlPath = dir.resolve(s"${roleAtom}.hrl")
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
    println(s"[Codegen] (Re)wrote ${hrlPath.getFileName}")
  }

  private def usage(): Unit = {
    println(
      s"""
         |Usage:
         |  runMain com.github.rhu1.gt.codegen.CodegenCLI <path/to/file.scr> [-proto Name] (-all | -roles R1 R2 ...) [-out ./generated] [-gc]
         |
         |Flags:
         |  -proto Name   Generate only for the named protocol inside the .scr
         |  -all          Generate for all roles (default if -roles is omitted)
         |  -roles ...    Generate only for the listed roles (space-separated)
         |  -out DIR      Output base directory (default: ./generated)
         |  -gc           Enable idle GC support (gc_timeout/0, on_gc/2 hooks and runtime scheduling)
         |""".stripMargin)
  }
}
