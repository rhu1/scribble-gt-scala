# Erlang `travel_agency` OTP app

This directory contains a runnable Erlang/OTP application generated from the Scribble specification in `examples/scribble/TravelAgency.scr`.

## Directory layout

- `src/gen_<role>.erl`: protocol-enforcing `gen_statem` wrapper (generated; don’t edit).
- `src/<role>.erl`: minimal callback/template implementation (hand-edited in this repo).
- `src/<role>.hrl`: per-role `#state_data{...}` record.
- `src/*_app.erl`, `src/*_sup.erl`: OTP application + supervision tree.

## Roles

- `client` (`gen_client.erl`)
- `agency` (`gen_agency.erl`)
- `supplier` (`gen_supplier.erl`)

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
application:start(travel_agency).
```

Stop it with:

```erlang
application:stop(travel_agency).
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
- nested MC

Source: Hu, Yoshida and Honda (2008)

## Tracing/logs

The generated `gen_*` modules enable `gen_statem` debug tracing and write `*_debug.log` files into this directory.
