package com.github.rhu1.gt.test.oopsla25

import com.github.rhu1.gt.main.Main
import org.scalatest.funsuite.AnyFunSuite;

object TestUtil extends AnyFunSuite {

    //public static final String BASE_PATH = ".\\src\\test\\java\\oopsla25";
    val BASE_PATH = "src\\test\\scala\\com\\github\\rhu1\\gt\\test\\oopsla25"

    def testGood(scribFile: String): Unit =
        //GTCommandLine2.main(new String[]{scribFile});
        Main.main(Array(scribFile))

    def testBad(scribFile: String): Unit =
        //GTCommandLine2.main(new String[]{scribFile});
        assertThrows[Exception](Main.main(Array(scribFile)))

    /*// TODO GTException
    public static void testBad(String scribFile) {
        // cf. Assertion.assertThrows
        try {
            GTCommandLine2.main(new String[]{scribFile});
        } catch (RuntimeException x) {
            return;
        }
        Assert.fail("Expected exception.");
    }*/
}
