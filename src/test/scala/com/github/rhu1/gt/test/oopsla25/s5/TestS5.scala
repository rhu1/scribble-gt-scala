package com.github.rhu1.gt.test.oopsla25.s5;

import com.github.rhu1.gt.test.oopsla25.TestUtil
import org.scalatest.funsuite.AnyFunSuite;


class TestS5 extends AnyFunSuite {

    test("Failure") {
        TestUtil.testGood(TestUtil.BASE_PATH + "\\s5\\good\\Failure.scr");
    }

    test("Interr") {
        TestUtil.testGood(TestUtil.BASE_PATH + "\\s5\\good\\Interr.scr");
    }

    test("AMQP") {
        TestUtil.testGood(TestUtil.BASE_PATH + "\\s5\\good\\AMQP.scr");
    }

    test("AMQP_long") {
        TestUtil.testGood(TestUtil.BASE_PATH + "\\s5\\good\\AMQP_long.scr");
    }


    /* Table 1 */

    test("Calculator") {
        TestUtil.testGood(TestUtil.BASE_PATH + "\\s5\\good\\table1\\Calculator.scr");
    }

    test("CircuitBreaker") {
        TestUtil.testGood(TestUtil.BASE_PATH + "\\s5\\good\\table1\\CircuitBreaker.scr");
    }

    test("DistibutedLogging") {
        TestUtil.testGood(TestUtil.BASE_PATH + "\\s5\\good\\table1\\DistributedLogging.scr");
    }

    test("Fibonacci") {
        TestUtil.testGood(TestUtil.BASE_PATH + "\\s5\\good\\table1\\Fibonacci.scr");
    }

    test("SMTP") {
        TestUtil.testGood(TestUtil.BASE_PATH + "\\s5\\good\\table1\\SMTP.scr");
    }

    test("TwoBuyer") {
        TestUtil.testGood(TestUtil.BASE_PATH + "\\s5\\good\\table1\\TwoBuyer.scr");
    }

    test("TravelAgency") {
        TestUtil.testGood(TestUtil.BASE_PATH + "\\s5\\good\\table1\\TravelAgency.scr");
    }

    test("OnlineWallet") {
        TestUtil.testGood(TestUtil.BASE_PATH + "\\s5\\good\\table1\\OnlineWallet.scr");
    }
}
