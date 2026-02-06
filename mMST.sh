#!/usr/bin/env bash

if [ -z "${SCRIBBLE_GT_HOME}" ]; then
    SCRIBHOME=$(dirname "$0")
else
    SCRIBHOME=${SCRIBBLE_GT_HOME}
fi

usage() {
  echo Usage:  'mMST.sh [option]... <PathToScribbleFile.scr>'
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
  -no-gc                    Disable idle GC support (enabled by default)

 GT checking flags (passed to Main):
  -gt-check-fidelity        Check protocol(s) in the .scr via fidelity (operational correspondence)
  -gt-check-completeness    Check protocol(s) in the .scr via completeness

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
CLI_ARGS=""        # Args to pass to Main after the -gt-* flag(s)
SCRFILE=""         # The .scr path captured from the command line
PROTO_SIMPLE=""    # If set, generate only this proto via -gt-generate-efsms <ProtoSimple>
GT_MODE=""         # If set, one of: check_fidelity | check_completeness | gen_efsms | gen_efsms_all
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

        # GT checking flags
        -gt-check-fidelity)
            GT_MODE="check_fidelity"
            shift
            ;;
        -gt-check-completeness)
            GT_MODE="check_completeness"
            shift
            ;;

        # Explicit generation flags
        -gt-generate-efsms-all)
            GT_MODE="gen_efsms_all"
            shift
            ;;
        -gt-generate-efsms)
            # expects proto simple name immediately after
            GT_MODE="gen_efsms"
            PROTO_SIMPLE="$2"
            shift 2
            ;;

        # Options
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
            PROTO_SIMPLE="$2"
            shift 2
            ;;
        -roles)
            shift
            # collect roles until next flag or end
            ROLE_LIST=()
            # Stop when we hit another flag *or* the Scribble file path (*.scr)
            while [ -n "$1" ] && [ "${1#-}" = "$1" ] && [[ "$1" != *.scr ]]; do
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
        -no-gc)
            # Disable GC (enabled by default)
            CLI_ARGS="${CLI_ARGS}${CLI_ARGS:+ }-no-gc"
            shift
            ;;
        *)
            # First non-option token ending with .scr is treated as the Scribble file
            if [ -z "$SCRFILE" ] && [[ "$1" == *.scr ]]; then
                SCRFILE="$1"
                shift
            else
                echo "Unknown or misplaced argument: $1" >&2
                usage=1
                break
            fi
            ;;
    esac
done

if [ "$usage" = 0 ] && [ -z "$SCRFILE" ] && [ "$run_scribble_examples" = 0 ] && [ "$run_erlang_examples" = 0 ] && [ "$run_clean_all" = 0 ] && [ "$run_clean_erlang" = 0 ] && [ "$run_copy_erlang" = 0 ] && [ "$run_copy_all_erlang" = 0 ]; then
  echo "Error: Missing <PathToScribbleFile.scr>" >&2
  usage
  exit 1
fi

# Track if a main-mode action already ran (so we don't fall through to default Main invocation)
DID_RUN=0

run_main() {
  local scrfile="$1"; shift
  local args=("$scrfile" "$@")
  cd "$SCRIBHOME" || exit 1
  sbt "runMain com.github.rhu1.gt.main.Main ${args[*]}"
}

run_check_file() {
  local scrfile="$1"
  # Validation only (fidelity by default)
  run_main "$scrfile" -gt-check-fidelity
}

run_generate_all_for_file() {
  local scrfile="$1"
  # Projection + generation for all protocols/roles in the file.
  # We rely on Main's default behaviour when no -proto is provided.
  run_main "$scrfile"
}

# Run checks for all Scribble examples
if [ "$run_scribble_examples" = 1 ]; then
  FAILURES=0

  while IFS= read -r -d '' f; do
    echo "============================================================"
    echo "==> Validating (fidelity): $f"
    if ! run_check_file "$f"; then
      echo "FAIL (validate): $f" >&2
      FAILURES=$((FAILURES+1))
      continue
    fi
    echo "PASS (validate): $f"

    echo "==> Projecting + generating: $f"
    if ! run_generate_all_for_file "$f"; then
      echo "FAIL (generate): $f" >&2
      FAILURES=$((FAILURES+1))
      continue
    fi
    echo "PASS (generate): $f"
  done < <(find "$SCRIBHOME/examples/scribble" -type f -name '*.scr' -print0 | sort -z)

  if [ "$FAILURES" -ne 0 ]; then
    echo "FAILURES ($FAILURES)" >&2
    exit 1
  fi
  DID_RUN=1
fi

# Compile, start, stop all OTP examples
if [ "$run_erlang_examples" = 1 ]; then
  # Reuse the existing scripts if present
  if [ -x "$SCRIBHOME/scripts/test_generated_otp_apps.sh" ]; then
    if [ "$quiet_erlang_examples" = 1 ]; then
      "$SCRIBHOME/scripts/test_generated_otp_apps.sh" -q "$SCRIBHOME/examples/erlang"
    else
      "$SCRIBHOME/scripts/test_generated_otp_apps.sh" "$SCRIBHOME/examples/erlang"
    fi
    DID_RUN=1
  else
    echo "Error: scripts/test_generated_otp_apps.sh not found or not executable" >&2
    exit 1
  fi
fi

# Default path: run Scala Main on one SCRFILE
if [ "$DID_RUN" = 0 ]; then
  if [ "$verbose" = 1 ]; then
    set -x
  fi

  # Default mode selection:
  #  - If any explicit -gt-* mode is chosen, use it.
  #  - Else if -proto is provided (optionally with -roles/-out/-no-gc), run code generation for that protocol.
  #  - Else default to checking the file via fidelity.
  if [ -z "$GT_MODE" ]; then
    if [ -n "$PROTO_SIMPLE" ]; then
      GT_MODE="gen_efsms"
    else
      GT_MODE="check_fidelity"
    fi
  fi

  # Build the Main invocation
  MAIN_ARGS=()
  MAIN_ARGS+=("$SCRFILE")

  case "$GT_MODE" in
    check_fidelity)
      MAIN_ARGS+=("-gt-check-fidelity")
      ;;
    check_completeness)
      MAIN_ARGS+=("-gt-check-completeness")
      ;;
    gen_efsms_all)
      MAIN_ARGS+=("-gt-generate-efsms-all")
      ;;
    gen_efsms)
      if [ -z "$PROTO_SIMPLE" ]; then
        echo "Error: -proto <ProtocolName> is required for code generation" >&2
        usage
        exit 1
      fi
      MAIN_ARGS+=("-gt-generate-efsms" "$PROTO_SIMPLE")
      ;;
    *)
      echo "Error: unknown GT_MODE=$GT_MODE" >&2
      exit 1
      ;;
  esac

  # Append any additional CLI args intended for generation (roles/out/no-gc)
  if [ -n "$CLI_ARGS" ]; then
    # shellcheck disable=SC2206
    EXTRA_ARGS=($CLI_ARGS)
    MAIN_ARGS+=("${EXTRA_ARGS[@]}")
  fi

  cd "$SCRIBHOME" || exit 1
  sbt "runMain com.github.rhu1.gt.main.Main ${MAIN_ARGS[*]}"
fi
