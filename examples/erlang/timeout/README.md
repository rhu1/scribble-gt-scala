# Erlang `timeout` OTP app

This directory contains a runnable Erlang/OTP application generated from the Scribble specification in `examples/scribble/Timeout.scr`.

## Directory layout

- `src/gen_<role>.erl`: protocol-enforcing `gen_statem` wrapper (generated; don’t edit).
- `src/<role>.erl`: minimal callback/template implementation (hand-edited in this repo).
- `src/<role>.hrl`: per-role `#state_data{...}` record.
- `src/*_app.erl`, `src/*_sup.erl`: OTP application + supervision tree.

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
application:start(timeout).
```

Stop it with:

```erlang
application:stop(timeout).
```

## Run via mMST (recommended)

From the project root:

```sh
./mMST.sh -run-erlang-examples
```

## Features demonstrated

- Multiparty
- Branch/Select
- Mixed Choice
- stale-message purging

Source: This paper (Timeout running example)

## Tracing/logs

The generated `gen_*` modules enable `gen_statem` debug tracing and write `*_debug.log` files into this directory.
