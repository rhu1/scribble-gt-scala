package com.github.rhu1.gt.codegen

import com.github.rhu1.gt.main.Main
import org.scalatest.funsuite.AnyFunSuite

import java.nio.file.{Files, Path}
import scala.jdk.CollectionConverters.*

class RuntimeModuleGeneratorTest extends AnyFunSuite {

    test("same outgoing and committing-receive labels still generate") {
        val out = Files.createTempDirectory("fibonacci-same-label-codegen-")
        try {
            Main.main(Array(
                "src/test/scala/com/github/rhu1/gt/test/oopsla25/s5/good/table1/Fibonacci.scr",
                "-gt-generate-efsms",
                "Fibonacci",
                "-out",
                out.toString
            ))

            val generated = out.resolve("Fibonacci")
            assert(Files.exists(generated.resolve("gen_a.erl")))
            assert(Files.exists(generated.resolve("gen_b.erl")))
        } finally {
            deleteRecursively(out)
        }
    }

    test("Fibonacci generates structural mixed-choice paths and stale-message handling") {
        val out = Files.createTempDirectory("fibonacci-codegen-")
        try {
            Main.main(Array(
                "examples/scribble/Fibonacci.scr",
                "-gt-generate-efsms",
                "Fibonacci",
                "-out",
                out.toString
            ))

            val generated = out.resolve("Fibonacci")
            val genA = Files.readString(generated.resolve("gen_a.erl"))
            val genB = Files.readString(generated.resolve("gen_b.erl"))
            val aCallback = Files.readString(generated.resolve("a.erl"))
            val aHeader = Files.readString(generated.resolve("a.hrl"))
            val mcId = """enter_mc\((mc\d+)\)""".r.findFirstMatchIn(genA).map(_.group(1)).get

            assert(!aCallback.contains("mc_path"))
            assert(!aHeader.contains("mc_path"))
            assert(aHeader.contains("-record(state_data, {b_pid :: pid() | undefined})."))
            assert(genA.contains("get(mc_path)"))
            assert(genA.contains("commit_if_taken(Next, McId, Side) ->"))
            assert(genB.contains("commit_if_taken(Next, McId, Side) ->"))

            assert(genA.contains(s"init_context(),\n    enter_mc(${mcId}),"))
            assert((
                "(?s)send_s\\d+_fibonacci_1\\(BPid, Num, _Data\\) ->\\R" +
                    s"    Path = branch_path\\(${mcId}, left\\),\\R" +
                    "    set_current_path\\(Path\\),"
            ).r.findFirstIn(genA).nonEmpty)
            assert(!genA.contains("PreviousCommit"))
            assert(!genA.contains("commit_entry"))

            assert((
                "(?s)send_s\\d+_error\\(APid, _Data\\) ->\\R" +
                    s"    Path = branch_path\\(${mcId}, right\\),\\R" +
                    s"    commit_current\\(${mcId}, right\\),"
            ).r.findFirstIn(genB).nonEmpty)
            assert((
                "(?s)s\\d+\\(cast, \\{BPid, \\{error\\}, Path\\}, Data\\) ->.*" +
                    "Next = try CallbackModule:s\\d+\\(cast, \\{BPid, \\{error\\}\\}, Data\\)"
            ).r.findFirstIn(genA).nonEmpty)
            assert(genA.contains(
                s"{stop, _, _} -> after_transition(commit_if_taken(Next, ${mcId}, right));"
            ))
            assert((
                "(?s)s\\d+\\(cast, \\{BPid, \\{fibonacci_2, \\{Num\\}\\}, Path\\}, Data\\) ->\\R" +
                    "    case message_status\\(Path, current_path\\(\\)\\) of"
            ).r.findFirstIn(genA).nonEmpty)
            assert((
                "(?s)s\\d+\\(cast, \\{APid, \\{fibonacci_1, \\{Num\\}\\}, Path\\}, Data\\) ->\\R" +
                    s"    case message_status\\(Path, branch_path\\(${mcId}, left\\)\\) of"
            ).r.findFirstIn(genB).nonEmpty)

            assert(genA.contains("-spec current_path() -> [left | right]."))
            assert(genA.contains("set_commit(maps:put(Prefix, {McId, none}, get_commit()))"))
            assert((
                s"after_transition\\(\\{next_state, s\\d+, _\\} = Next\\) -> enter_mc\\(${mcId}\\), Next"
            ).r.findFirstIn(genA).nonEmpty)
            assert(genA.contains("stale([Side | Rest], Prefix, Frames) ->"))
            assert(genA.contains("Commit =/= none, Commit =/= Side -> true"))
        } finally {
            deleteRecursively(out)
        }
    }

    test("ordinary continuation receives use the current mixed-choice path without recommitting") {
        val out = Files.createTempDirectory("continuation-codegen-")
        try {
            Main.main(Array(
                "examples/scribble/DistributedLogging.scr",
                "-gt-generate-efsms",
                "DistributedLogging",
                "-out",
                out.toString
            ))
            Main.main(Array(
                "examples/scribble/TravelAgency.scr",
                "-gt-generate-efsms",
                "TravelAgency",
                "-out",
                out.toString
            ))

            val controller = Files.readString(out.resolve("DistributedLogging/gen_controller.erl"))
            val agency = Files.readString(out.resolve("TravelAgency/gen_agency.erl"))

            val ackClause = (
                "(?s)(s\\d+\\(cast, \\{LogsPid, \\{ack\\}, Path\\}, Data\\) ->.*?" +
                    "not_ready ->.*?\\n    end)"
            ).r.findFirstIn(controller).get
            assert(ackClause.contains("message_status(Path, current_path())"))
            assert(!ackClause.contains("commit_if_taken"))
            assert(!ackClause.contains("commit_current"))

            val cancelClause = (
                "(?s)(s\\d+\\(cast, \\{ClientPid, \\{cancel_agency\\}, Path\\}, Data\\) ->.*?" +
                    "not_ready ->.*?\\n    end)"
            ).r.findFirstIn(agency).get
            assert(cancelClause.contains("message_status(Path, current_path())"))
            assert(!cancelClause.contains("commit_if_taken"))
            assert(!cancelClause.contains("commit_current"))
        } finally {
            deleteRecursively(out)
        }
    }

    test("loop-prefix states stay outside a later mixed-choice frame") {
        val out = Files.createTempDirectory("circuit-breaker-codegen-")
        try {
            Main.main(Array(
                "examples/scribble/CircuitBreaker.scr",
                "-gt-generate-efsms",
                "CircuitBreaker",
                "-out",
                out.toString
            ))

            val generated = out.resolve("CircuitBreaker")
            val genApi = Files.readString(generated.resolve("gen_api.erl"))
            val genController = Files.readString(generated.resolve("gen_controller.erl"))
            val genUsr = Files.readString(generated.resolve("gen_usr.erl"))

            assert(
                """s\d+\(cast, \{UsrPid, \{request\}\}, Data\) ->""".r
                    .findFirstIn(genApi)
                    .nonEmpty
            )
            assert(
                """s\d+\(cast, \{UsrPid, \{request\}, Path\}, Data\) ->""".r
                    .findFirstIn(genApi)
                    .isEmpty
            )
            assert((
                "(?s)send_s\\d+_request\\(APIPid, _Data\\) ->\\R" +
                    "    gen_statem:cast\\(APIPid, \\{self\\(\\), \\{request\\}\\}\\)\\."
            ).r.findFirstIn(genUsr).nonEmpty)
            assert(
                """after_transition\(\{next_state, s\d+, _\} = Next\) -> enter_mc\(mc\d+\), Next""".r
                    .findFirstIn(genApi)
                    .nonEmpty
            )
            assert(genController.contains("after_transition(commit_if_taken("))
            assert(genController.contains("commit_if_taken(Next, McId, Side) ->"))
            assert(genApi.contains("commit_if_taken(Next, McId, Side) ->"))
        } finally {
            deleteRecursively(out)
        }
    }

    private def deleteRecursively(path: Path): Unit = {
        if (Files.exists(path)) {
            val paths = Files.walk(path)
            try paths.iterator().asScala.toList.reverse.foreach(Files.delete)
            finally paths.close()
        }
    }
}
