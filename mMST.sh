#!/usr/bin/env bash
#
# Copyright 2008 The Scribble Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


##
# Config:
#
# $SCRIBBLE_GT_HOME
#   Set this to the `scribble-gt-scala` root directory.
#   If not set, defaults to the directory containing this script.
##

if [ -z "${SCRIBBLE_GT_HOME}" ]; then
    SCRIBHOME=$(dirname "$0")
else
    SCRIBHOME=${SCRIBBLE_GT_HOME}
fi

usage() {
  echo Usage:  'mMST.sh [option]... <PathToScribbleFile.scr> [option]...'
  cat <<EOF

 <PathToScribbleFile.scr>  Source Scribble module containing global protocol(s).

 mMST.sh uses the Scala Main entry point to generate Erlang code.
 By default, for each protocol and role found in <SCRFILE>:
   - Global-local checks are performed.
   - Erlang modules (gen_<role>.erl and <role>.erl) and <role>.hrl are generated.
   - Output is placed in ./generated/<ProtocolName>/

 Options:
  -h, --help                Show this info and exit
  -v, --verbose             Verbose shell output (does not affect Scala CLI)

  Codegen flags (passed to Main):
  -proto Name               Generate only for the named protocol inside the .scr
  -all                      Generate for all roles (default if -roles is omitted)
  -roles R1 R2 ...          Generate only for the listed roles (space-separated)
  -out DIR                  Output base directory (default: ./generated)
  -gc                       Enable idle GC support

  Extras:
   -run-scribble-examples    Run generation for all .scr files under examples/scribble/
   -run-erlang-examples      Compile, start, and stop all Erlang OTP app examples
   -quiet-erlang-examples    With -run-erlang-examples, suppress per-app output (summary only)
   -clean-erlang-examples    Clean only Erlang OTP app examples
  -clean-all                sbt clean, remove ./generated, and rebar3 clean on examples
  -copy-erlang-demos <ProtocolName>
                            Copy generated gen_*.erl into examples/erlang/<protocol_name>/src
  -copy-all-erlang-demos    Copy gen_*.erl for all generated protocols into demos

EOF
}

usage=0
verbose=0
CLI_ARGS=""        # Args to pass to Main (excluding the .scr path)
SCRFILE=""         # The .scr path captured from the command line
run_scribble_examples=0 # Flag for the new option
run_erlang_examples=0  # Flag for running and stopping Erlang OTP apps
quiet_erlang_examples=0  # Flag for suppressing per-app rebar3 output
run_clean_all=0 # Flag for cleaning entire workspace
run_clean_erlang=0 # Flag for cleaning Erlang examples only
run_copy_erlang=0 # Flag for copying generated Erlang modules to demos
run_copy_all_erlang=0 # Flag for copying all protocols to Erlang demos

while true; do
    case "$1" in
        "")
            break
            ;;
        -h|--help)
            usage=1
            break
            ;;
        --verbose|-v)
            verbose=1
            shift
            ;;
        -run-scribble-examples)
            run_scribble_examples=1
            shift
            ;;
        -run-erlang-examples)
            run_erlang_examples=1
            shift
            ;;
        -quiet-erlang-examples)
            quiet_erlang_examples=1
            shift
            ;;
        -clean-erlang-examples)
            run_clean_erlang=1
            shift
            ;;
        -copy-erlang-demos)
            run_copy_erlang=1
            PROTOCOL_NAME="$2"
            shift 2
            ;;
        -copy-all-erlang-demos)
            run_copy_all_erlang=1
            shift
            ;;
        -clean-all)
            run_clean_all=1
            shift
            ;;
        # Codegen flags
        -proto)
            CLI_ARGS="${CLI_ARGS}${CLI_ARGS:+ }-proto $2"
            shift 2
            ;;
        -roles)
            shift
            # collect roles until next flag or end
            ROLE_LIST=()
            while [ -n "$1" ] && [ "${1#-}" = "$1" ]; do
              ROLE_LIST+=("$1")
              shift
            done
            if [ "${#ROLE_LIST[@]}" -gt 0 ]; then
              CLI_ARGS="${CLI_ARGS}${CLI_ARGS:+ }-roles ${ROLE_LIST[*]}"
            fi
            ;;
        -all)
            CLI_ARGS="${CLI_ARGS}${CLI_ARGS:+ }-all"
            shift
            ;;
        -out)
            CLI_ARGS="${CLI_ARGS}${CLI_ARGS:+ }-out $2"
            shift 2
            ;;
        -gc)
            CLI_ARGS="${CLI_ARGS}${CLI_ARGS:+ }-gc"
            shift
            ;;
        *)
            # First non-option token ending with .scr is treated as the Scribble file
            if [ -z "$SCRFILE" ] && [[ "$1" == *.scr ]]; then
                SCRFILE="$1"
            else
                echo "Unknown or misplaced argument: $1" >&2
                usage=1
                break
            fi
            shift
            ;;
    esac
done

if [ "$usage" = 1 ]; then
    usage
    exit 0
elif [ "$run_clean_all" = 1 ]; then
    echo "Cleaning sbt build..."
    (cd "$SCRIBHOME" && sbt clean)
    echo "Removing generated/ directory..."
    rm -rf "$SCRIBHOME/generated"
    echo "Cleaning Erlang example builds..."
    for dir in "$SCRIBHOME/examples/erlang"/*/; do
        [ -d "$dir" ] || continue
        echo "Rebar3 clean: $dir"
        (cd "$dir" && rebar3 clean)
    done
    exit 0
elif [ "$run_clean_erlang" = 1 ]; then
    ERL_DIR="$SCRIBHOME/examples/erlang"
    echo "Cleaning Erlang example builds in: $ERL_DIR"
    for dir in "$ERL_DIR"/*/; do
        [ -d "$dir" ] || continue
        echo "Rebar3 clean: $(basename "$dir")"
        (cd "$dir" && rebar3 clean)
    done
    exit 0
elif [ "$run_copy_erlang" = 1 ]; then
    SRC_DIR="$SCRIBHOME/generated/$PROTOCOL_NAME"
    # Convert protocol name to lowercase (portable) to match demo folder
    # Convert CamelCase ProtocolName to snake_case demo folder
    DEMO_NAME=$(printf "%s" "$PROTOCOL_NAME" \
        | sed -E 's/([a-z0-9])([A-Z])/\1_\2/g' \
        | tr '[:upper:]' '[:lower:]')
    DEST_DIR="$SCRIBHOME/examples/erlang/$DEMO_NAME/src"
    echo "Copying gen_*.erl from $SRC_DIR to $DEST_DIR"
    mkdir -p "$DEST_DIR"
    for file in "$SRC_DIR"/gen_*.erl; do
        [ -f "$file" ] || continue
        echo "Copying $(basename "${file}") from $SRC_DIR to $DEST_DIR"
        cp "$file" "$DEST_DIR"/
    done
    exit 0
elif [ "$run_copy_all_erlang" = 1 ]; then
    for src in "$SCRIBHOME"/generated/*/; do
        [ -d "$src" ] || continue
        proto=${src#"$SCRIBHOME"/generated/}; proto=${proto%/}
        demo=$(printf "%s" "$proto" \
            | sed -E 's/([a-z0-9])([A-Z])/\1_\2/g' \
            | tr '[:upper:]' '[:lower:]')
#            to switch back to erlang
        DEST_DIR="$SCRIBHOME/generated_otp_app/$demo/src"
        mkdir -p "$DEST_DIR"
        for file in "$SCRIBHOME/generated/$proto"/gen_*.erl; do
            [ -f "$file" ] || continue
            echo "Copying $(basename "${file}") from $SCRIBHOME/generated/$proto to $DEST_DIR"
            cp "$file" "$DEST_DIR"/
        done
    done
    exit 0
fi

# Define the main Scala entrypoint
# Note: Main supports the former CodegenCLI flags via -gt-generate-fsms.
scribblec() {
    if [ "$verbose" = 1 ]; then
        echo "Executing: sbt \"runMain com.github.rhu1.gt.main.Main $*\""
    fi
    (cd "$SCRIBHOME" && sbt "runMain com.github.rhu1.gt.main.Main $*")
}

## When the batch flag is set, loop through all `.scr` files and process them
if [ "$run_scribble_examples" = 1 ]; then
    EXAMPLES_DIR="$SCRIBHOME/examples/scribble"
    if [ ! -d "$EXAMPLES_DIR" ]; then
        echo "Error: Examples directory not found: $EXAMPLES_DIR" >&2
        exit 1
    fi
    echo "Running all examples from: $EXAMPLES_DIR"
    if [ -z "$(find "$EXAMPLES_DIR" -type f -name '*.scr' -print -quit)" ]; then
        echo "No .scr examples found in $EXAMPLES_DIR"
    else
        find "$EXAMPLES_DIR" -type f -name '*.scr' | while IFS= read -r scr_file; do
            echo "Processing example: $scr_file"
            scribblec "$scr_file" $CLI_ARGS
        done
    fi
    exit 0
elif [ "$run_erlang_examples" = 1 ]; then
     ERL_DIR="$SCRIBHOME/generated_otp_app"
     echo "Running, starting, and stopping OTP apps in: $ERL_DIR"

     PASS_APPS=()
     FAIL_APPS=()
     SKIP_APPS=()

     # rabbitmq-server is special: it uses erlang.mk and requires GNU Make.
     # Run the amqp_client EUnit tests (covers the replaced amqp_selective_consumer).
     rmq_eunit_label="rabbitmq_server(amqp_client_eunit)"
     rmq_eunit_ran_ok=0
     if [ -d "$ERL_DIR/rabbitmq-server/deps/amqp_client" ]; then
         if command -v gmake >/dev/null 2>&1; then
             echo "---- rabbitmq-server: amqp_client eunit (selective consumer) ----"
             if (cd "$ERL_DIR/rabbitmq-server/deps/amqp_client" && gmake -j1 eunit); then
                 echo "EUNIT OK: rabbitmq-server/amqp_client"
                 PASS_APPS+=("$rmq_eunit_label")
                 rmq_eunit_ran_ok=1
             else
                 echo "EUNIT FAIL: rabbitmq-server/amqp_client"
                 FAIL_APPS+=("$rmq_eunit_label")
             fi
         else
             echo "SKIP rabbitmq-server/amqp_client-eunit (gmake not found; erlang.mk requires GNU Make 4+)"
             SKIP_APPS+=("$rmq_eunit_label")
         fi
     fi

     for dir in "$ERL_DIR"/*/; do
        [ -d "$dir" ] || continue
        app=$(basename "$dir")

        # Skip folders without a rebar3.config (not an OTP app)
        if [ ! -f "$dir/rebar3.config" ]; then
            # If we've already run the rabbitmq selective-consumer unit tests successfully,
            # suppress the rabbitmq-server SKIP line to avoid confusing output.
            if [ "$app" = "rabbitmq-server" ] && [ "$rmq_eunit_ran_ok" = 1 ]; then
                :
            else
                echo "SKIP $app (missing rebar3.config)"
            fi
            # If we've already run the rabbitmq selective-consumer unit tests successfully,
            # don't also list rabbitmq-server as skipped.
            if [ "$app" = "rabbitmq-server" ] && [ "$rmq_eunit_ran_ok" = 1 ]; then
                 :
             else
                 SKIP_APPS+=("$app")
             fi
             continue
         fi

        echo "Building: $app"
        if [ "$quiet_erlang_examples" = 1 ]; then
           if (cd "$dir" && rebar3 compile ${verbose:+-v} >/dev/null); then
               echo "COMPILE OK: $app"
           else
               echo "COMPILE FAIL: $app"
               FAIL_APPS+=("$app")
               continue
           fi
       elif (cd "$dir" && echo "---- rebar3 compile ($app) ----" && rebar3 compile ${verbose:+-v}); then
            echo "COMPILE OK: $app"
        else
            echo "COMPILE FAIL: $app"
            FAIL_APPS+=("$app")
            continue
        fi

        # Prefer running via rebar3 shell so deps and code paths match the build.
        # Some apps are named differently from their folder; fall back to scanning *.app.
        appname="$app"
        if [ -d "$dir/_build/default/lib" ]; then
            found_app=$(find "$dir/_build/default/lib" -maxdepth 2 -type f -name '*.app' 2>/dev/null | head -n 1)
            if [ -n "$found_app" ]; then
                appname=$(basename "$found_app" .app)
            fi
        fi

        echo "Running (start/stop): $appname"
        if [ "$quiet_erlang_examples" = 1 ]; then
           if (cd "$dir" && rebar3 shell --eval "application:ensure_all_started($appname), timer:sleep(2000), application:stop($appname), halt()." >/dev/null); then
               echo "RUN OK: $app"
               PASS_APPS+=("$app")
           else
               echo "RUN FAIL: $app"
               FAIL_APPS+=("$app")
           fi
        elif (cd "$dir" && echo "---- rebar3 shell ($appname) ----" && rebar3 shell --eval "application:ensure_all_started($appname), timer:sleep(2000), application:stop($appname), halt()."); then
            echo "RUN OK: $app"
            PASS_APPS+=("$app")
        else
            echo "RUN FAIL: $app"
            FAIL_APPS+=("$app")
        fi
    done

    echo
    echo "========== OTP app test summary =========="
    echo "PASS (${#PASS_APPS[@]}): ${PASS_APPS[*]}"
    echo "FAIL (${#FAIL_APPS[@]}): ${FAIL_APPS[*]}"
    echo "SKIP (${#SKIP_APPS[@]}): ${SKIP_APPS[*]}"

    if [ "${#FAIL_APPS[@]}" -gt 0 ]; then
        exit 1
    fi
    exit 0
 else
    # Single file path flow using Main
    if [ -z "$SCRFILE" ]; then
        echo "Error: Missing <PathToScribbleFile.scr>" >&2
        usage
        exit 1
    fi
    scribblec "$SCRFILE" $CLI_ARGS
fi

