package com.github.rhu1.gt.main

import com.github.rhu1.gt.*
import com.github.rhu1.gt.`type`.session.global.{GType, Scrib2GT}
import org.scribble.ast.Module
import org.scribble.core.`type`.name.{GProtoName, ModuleName}
import org.scribble.ext.gt.cli.GTCommandLine2

import scala.jdk.CollectionConverters.*

object Main {

    def main(args: Array[String]): Unit = {

        // GTCommandLine2 Test4.scr (-fair -v)
        // -Dstdout.encoding=UTF-8 -Dstderr.encoding=UTF-
        // org.scribble.ext.gt.cli.GTCommandLine2
        // [-gt-explicit-observer-left-commits] -fair -v C:\Users\Raymond\winroot\home\eey335\code\java\intellij\git\github.com\rhu1-scribble-core-gt\scribble-java\scribble-test\src\test\scrib\tmp\Test4.scr
        //new GTCommandLine2()
        //GTCommandLine2.main(Array("-fair", "-v", "C:\\Users\\Raymond\\winroot\\home\\eey335\\code\\java\\intellij\\git\\github.com\\rhu1-scribble-core-gt\\scribble-java\\scribble-test\\src\\test\\scrib\\tmp\\Test4.scr"))
        //GTCommandLine2.main(Array("-fair", "-v", System.getProperty("user.dir") + "\\src\\test\\scrib\\Test.scr"))

        val fileName = if (args.nonEmpty) args(0) else System.getProperty("user.dir") + "\\src\\test\\scrib\\Test.scr"
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
                println(s"WF=${p.isWellFormed}")
                println(s"SD=${p.isSingleDecision}")
                println(s"CT=${p.isClearTermination}")
                println(s"BA=${p.isBalanced}")
                throw new RuntimeException(s"Invalid: ${n}")
            }
        })

    }

    def getTranslatedProtocols(parsed: Map[ModuleName, Module]): Map[GProtoName, GType] =
        parsed.values.flatMap(m => m.getGProtoDeclChildren.asScala.map(p => (
            p.getFullMemberName(m),
            Scrib2GT.translateSeq(p.getDefChild.getBlockChild.getInteractSeqChild))
        )).toMap
}


