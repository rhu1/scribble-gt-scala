# interleave_condition (Erlang)

A tiny example that demonstrates ulti-session program, the user generates the (separate) RM and CM modules
for the relevant roles of each protocol, and implements the necessary callbacks of each CM. Inter-
session dependencies are expressed as deferring the handling of an incoming event in one session until 
a local condition becomes true. In this case the local condition is Alice’s completion, which is used to 
coordinate the two concurrent sessions.

## What it shows
- Two concurrent sessions running in the same node:
  - Session A: Alice and Carol (pong -> ping)
  - Session B: Bob and Alice2 (request -> response)
- Alice2 will not consume Bob’s request until Alice has finished her own session. This creates the interleaving 
constraint: “Alice first, then Alice2.”
- The deferral is implemented by re-enqueuing the incoming request locally with a small delay (50 ms) until the local 
condition is satisfied.

## How it works (at a glance)
- `alice` (Session A)
  - State s5: handles `{pong}` from Carol.
  - State s7: sends `{ping}` to Carol and then terminates (`{stop, normal, Data}`). When Alice terminates, the 
registered name `alice` disappears.
- `alice2` (Session B)
  - State s5: receives `{request}` from Bob but checks a local condition before handling it:
    - If `whereis(alice)` is still a pid (Alice is still running), then `alice2` re-queues the `{request}` to itself 
    with `erlang:send_after(50, self(), {'$gen_cast', {BobPid, {request}}})` and keeps the current state.
    - If `whereis(alice)` is `undefined` (Alice finished), `alice2` proceeds to s7 and replies `{response}` to Bob.

This design purposefully avoids adding new state handlers; it treats “Alice has finished” 
as the local readiness condition observed by `alice2`. This local condition may be set by some arbitrary local 
computation or a local event triggered by (e.g.) the pong handler in the other session.

Notes:
- We use timed re-enqueueing instead of `postpone` because postponed events in gen_statem are typically retried when you 
transition out of the current state. Here we intentionally remain in s5 and retry later, so we re-enqueue explicitly.

## Layout
- `src/alice.erl`: Session A actor; finishes after sending `ping`.
- `src/alice2.erl`: Session B actor; waits until Alice is finished before replying to Bob.
- `src/bob.erl`, `src/carol.erl`: Peer actors for the two sessions.
- `src/gen_*.erl`: Generated gen_statem wrapper modules for each actor.
- `src/interleaving_app.erl`, `src/interleaving_sup.erl`: Application entrypoint and supervisor.

## Build
Requires Erlang/OTP 25+ and rebar3.

```sh
cd examples/erlang/interleave_condition
rebar3 compile
```

## Run
Start the application in a shell:

```sh
rebar3 shell
```

Then in the Erlang shell:

```erlang
application:ensure_all_started(interleaving).
```

Or in one command:

```sh
rebar3 shell --eval "application:ensure_all_started(interleaving)." --eval "timer:sleep(50)." --eval "halt()."
```

## Expected behavior (short)
- Carol sends `{pong}` to Alice; Alice replies `{ping}` and terminates.
- Bob sends `{request}` to Alice2; Alice2 stashes the request until `whereis(alice)` is undefined, then responds `{response}` to Bob.
- All actors terminate cleanly.
