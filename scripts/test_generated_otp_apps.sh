#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APPS_DIR="$ROOT/examples/erlang"

# Apps that we know are OTP apps (rebar3.config present)
apps=(
  calculator
  circuit_breaker
  distributed_logging
  fibonacci
  interleave_chaining
  interleave_condition
  online_wallet
  rabbitmq-server
  smtp
  timeout
  timeout_gc
  travel_agency
  two_buyer
)

# Keep the smoke test short; most apps print their own logs.
SLEEP_MS=1500

failures=()

echo "============================================================"
echo "==> Testing rabbitmq-server selective consumer unit tests (amqp_client eunit)"
rabbit_dir="$APPS_DIR/rabbitmq-server"
amqp_client_dir="$rabbit_dir/deps/amqp_client"
if [[ -d "$amqp_client_dir" ]]; then
  if command -v gmake >/dev/null 2>&1; then
    pushd "$amqp_client_dir" >/dev/null
    echo "-- gmake -j1 eunit (amqp_client)"
    if ! gmake -j1 eunit; then
      failures+=("rabbitmq-server/amqp_client: gmake eunit failed")
    else
      echo "PASS: rabbitmq-server/amqp_client eunit"
    fi
    popd >/dev/null
  else
    echo "SKIP: gmake not found; rabbitmq-server uses erlang.mk which requires GNU Make 4+"
  fi
else
  echo "SKIP: missing $amqp_client_dir"
fi

for app in "${apps[@]}"; do
  app_dir="$APPS_DIR/$app"
  echo "============================================================"
  echo "==> Testing OTP app: $app"

  if [[ ! -f "$app_dir/rebar3.config" ]]; then
    echo "SKIP: missing rebar3.config: $app_dir"
    continue
  fi

  pushd "$app_dir" >/dev/null

  echo "-- rebar3 clean && rebar3 compile"
  if ! rebar3 clean >/dev/null; then
    failures+=("$app: rebar3 clean failed")
    popd >/dev/null
    continue
  fi

  if ! rebar3 compile; then
    failures+=("$app: rebar3 compile failed")
    popd >/dev/null
    continue
  fi

  echo "-- rebar3 eunit"
  if ! rebar3 eunit; then
    failures+=("$app: rebar3 eunit failed")
    popd >/dev/null
    continue
  fi

  echo "-- smoke: ensure_all_started(app), sleep, halt"
  # Use app name as the application atom.
  if ! rebar3 shell --eval "application:ensure_all_started(${app}), timer:sleep(${SLEEP_MS}), halt()."; then
    failures+=("$app: shell smoke failed")
    popd >/dev/null
    continue
  fi

  popd >/dev/null
  echo "PASS: $app"
done

echo "============================================================"
if (( ${#failures[@]} )); then
  echo "FAILURES (${#failures[@]}):"
  for f in "${failures[@]}"; do
    echo "  - $f"
  done
  exit 1
else
  echo "ALL PASS"
fi
