# Erlang `interleave_condition_ets` OTP app

This directory contains a runnable Erlang/OTP application demonstrating *inter-session dependencies* (Section B of the paper). It is a variant of `interleave_condition` that stores the readiness condition in ETS.

## Directory layout

- `src/gen_*.erl`: generated protocol-enforcing `gen_statem` wrappers (don’t edit).
- `src/*.erl`: hand-edited callback implementations for the demo roles.
- `src/*_app.erl`, `src/*_sup.erl`: OTP application + supervision tree.

## What it shows

- Two concurrent sessions on the same node:
  - Session A: Alice and Carol (pong → ping)
  - Session B: Bob and Alice2 (request → response)
- Alice2 will not consume Bob’s request until Alice has finished Session A.
- The readiness condition is maintained via ETS (rather than, e.g., using `whereis/1`).

## Build & run (rebar3)

From this directory:

```sh
rebar3 clean
rebar3 compile
rebar3 eunit
rebar3 shell
```

In the Erlang shell:

```erlang
application:ensure_all_started(interleaving).
```

Stop it with:

```erlang
application:stop(interleaving).
```

## Run via mMST (recommended)

From the project root:

```sh
./mMST.sh -run-erlang-examples
```

## Features demonstrated

- Inter-session dependency

## Tracing/logs

The generated `gen_*` modules enable `gen_statem` debug tracing and write `*_debug.log` files into this directory.
