package com.github.rhu1.gt.test.oopsla25

import com.github.rhu1.gt.main.Main
import org.scalatest.funsuite.AnyFunSuite;

object TestUtil extends AnyFunSuite {

    val BASE_PATH = "src/test/scala/com/github/rhu1/gt/test/oopsla25"

    def testGood(scribFile: String): Unit =
        Main.main(Array(scribFile, "-gt-check-fidelity", "-gt-check-completeness"))

    def testBad(scribFile: String): Unit =
        assertThrows[Exception](Main.main(Array(scribFile, "-gt-check-fidelity", "-gt-check-completeness")))
}
