# Erlang `fibonacci` OTP app

This directory contains a runnable Erlang/OTP application generated from the Scribble specification in `examples/scribble/Fibonacci.scr`.

## Directory layout

- `src/gen_<role>.erl`: protocol-enforcing `gen_statem` wrapper (generated; don’t edit).
- `src/<role>.erl`: minimal callback/template implementation (hand-edited in this repo).
- `src/<role>.hrl`: per-role `#state_data{...}` record.
- `src/*_app.erl`, `src/*_sup.erl`: OTP application + supervision tree.

## Roles

- `a` (`gen_a.erl`)
- `b` (`gen_b.erl`)

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
application:start(fibonacci).
```

Stop it with:

```erlang
application:stop(fibonacci).
```

## Run via mMST (recommended)

From the project root:

```sh
./mMST.sh -run-erlang-examples
```

## Features demonstrated

- Multiparty
- Branch/Select
- Recursion
- Mixed Choice

Source: Hu and Yoshida (2016)

## Tracing/logs

The generated `gen_*` modules enable `gen_statem` debug tracing and write `*_debug.log` files into this directory.
