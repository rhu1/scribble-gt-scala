package com.github.rhu1.gt.test.oopsla25.s3;

import com.github.rhu1.gt.test.oopsla25.TestUtil
import org.scalatest.funsuite.AnyFunSuite;


class TestS3 extends AnyFunSuite {

    test("WFAmbiguous") {
        TestUtil.testBad(TestUtil.BASE_PATH + "/s3/bad/WFAmbiguous.scr");
    }

    test("LabelCapture") {
        TestUtil.testGood(TestUtil.BASE_PATH + "/s3/good/LabelCapture.scr");
    }

    test("RoleCapture") {
        TestUtil.testGood(TestUtil.BASE_PATH + "/s3/good/RoleCapture.scr");
    }

    /*test("Progress") {
        TestUtil.testGood(TestUtil.BASE_PATH + "/s3/good/Progress.scr");
    }*/

    test("ClearTermination1") {
        TestUtil.testBad(TestUtil.BASE_PATH + "/s3/bad/ClearTermination1.scr");
    }

    test("ClearTermination2") {
        TestUtil.testGood(TestUtil.BASE_PATH + "/s3/good/ClearTermination2.scr");
    }

    test("ClearTermination3") {
        TestUtil.testGood(TestUtil.BASE_PATH + "/s3/good/ClearTermination3.scr");
    }

    test("Balance") {
        TestUtil.testBad(TestUtil.BASE_PATH + "/s3/bad/Balance.scr");
    }
}
