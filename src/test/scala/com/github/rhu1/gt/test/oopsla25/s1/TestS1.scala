package com.github.rhu1.gt.test.oopsla25.s1

import com.github.rhu1.gt.test.oopsla25.TestUtil
import org.scalatest.funsuite.AnyFunSuite;

//import oopsla25.TestUtil;
//import org.junit.Test;
//import org.scribble.ext.gt.cli.GTCommandLine2;


class TestS1 extends AnyFunSuite {

    test("mytest") {
        //assert(M)
        TestUtil.testGood(TestUtil.BASE_PATH + "/s1/good/Intro.scr")
    }

}

/*class TestS1 {

    @Test
    public void testIntro() {
        //GTCommandLine2.main(new String[]{TestUtil.BASE_PATH + "/s1/good/Intro.scr"});
        TestUtil.testGood(TestUtil.BASE_PATH + "/s1/good/Intro.scr");
    }
}*/
