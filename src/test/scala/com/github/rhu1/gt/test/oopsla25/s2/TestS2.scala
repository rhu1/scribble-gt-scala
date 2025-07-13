package com.github.rhu1.gt.test.oopsla25.s2;

import com.github.rhu1.gt.test.oopsla25.TestUtil
import org.scalatest.funsuite.AnyFunSuite;


class TestS2 extends AnyFunSuite {

    test("TwoPartyChoice") {
        TestUtil.testGood(TestUtil.BASE_PATH + "\\s2\\good\\TwoPartyChoice.scr");
    }

    test("TwoPartyChoiceNonDirected") {
        TestUtil.testBad(TestUtil.BASE_PATH + "\\s2\\bad\\TwoPartyChoiceNonDirected.scr");
    }

    test("TwoPartyMC") {
        TestUtil.testGood(TestUtil.BASE_PATH + "\\s2\\good\\TwoPartyMC.scr");
    }

    test("Timeout") {
        TestUtil.testGood(TestUtil.BASE_PATH + "\\s2\\good\\Timeout.scr");
    }
}
