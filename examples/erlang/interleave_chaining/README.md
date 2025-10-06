# interleave_chaining (Erlang)

A tiny example that demonstrates chaining between two sessions: the start of one
session is triggered by the completion of the other. The user generates the
(separate) RM and CM modules for the relevant roles of each protocol and
implements the necessary callbacks of each CM. The inter-session dependency is
expressed as a local, non-blocking start of the second session from the first
session’s completion callback.

Concretely, Alice begins by handling only the ping/pong session (Session A).
When Alice reaches her s7 callback (after receiving pong and sending ping), she
locally spawns the second session’s handler (Alice2) with start_link. Bob may
send his request before or after that point; even if before, the request is
only delivered once Alice2 is started (Bob waits until Alice2 is available).

## What it shows
- Two sessions on the same node, with a start chained to the completion of the other:
  - Session A: Carol and Alice (pong -> ping)
  - Session B: Bob and Alice2 (request -> response)
- Alice’s completion (s7 in Session A) triggers the start of Session B by
  calling `gen_alice2:start_link/2`, registering `alice2`.
- Bob may attempt to send `{request}` before Alice2 exists; Bob will retry until
  `whereis(alice2)` returns a pid, so the request is effectively consumed only
  after Alice has completed Session A and started Alice2.

## How it works (at a glance)
- `alice` (Session A)
  - State s5: handles `{pong}` from Carol.
  - State s7: sends `{ping}` to Carol, then starts the second session locally
    with `gen_alice2:start_link(alice2, [])` (registers `alice2`) and terminates
    (`{stop, normal, Data}`).
- `alice2` (Session B)
  - State s5: receives `{request}` from Bob and transitions to s7.
  - State s7: sends `{response}` to Bob and terminates.
- `bob` (Session B peer)
  - Starts by scheduling an internal `{request}`.
  - In `connection/1`, looks up `whereis(alice2)`; if `undefined`, sleeps briefly
    and retries until Alice2 is available, then sends `{request}`.
- `carol` (Session A peer)
  - Starts by scheduling an internal `{pong}` and sends it to Alice.

This design purposefully avoids adding new state handlers. It
uses a simple local action in Alice’s completion (s7) to spawn the second
session, ensuring the causality “finish Session A, then start Session B.”

Notes:
- The chaining is local and non-blocking: Alice’s s7 triggers `start_link` for
  Alice2 and then terminates.
- Bob’s connection retry acts as backpressure: if Alice2 isn’t up yet, Bob
  waits until it is, so the `{request}` is only delivered after the chain point.

## Layout
- `src/alice.erl`: Session A actor; on completion (s7) it starts `alice2`.
- `src/alice2.erl`: Session B actor; replies `{response}` to Bob and terminates.
- `src/bob.erl`, `src/carol.erl`: Peer actors for the two sessions.
- `src/gen_*.erl`: Generated gen_statem wrapper modules for each actor.
- `src/interleaving_app.erl`, `src/interleaving_sup.erl`: Application entrypoint and supervisor.

## Build
Requires Erlang/OTP 25+ and rebar3.

```sh
cd examples/erlang/interleave_chaining
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
rebar3 shell --eval "application:ensure_all_started(interleaving)." --eval "timer:sleep(200)." --eval "halt()."
```

## Expected behavior (short)
- Carol sends `{pong}` to Alice; Alice replies `{ping}`, starts `alice2`, and terminates.
- Bob sends `{request}` to Alice2; if `alice2` is not yet running, Bob waits/retries
  until it is. Alice2 then responds `{response}` to Bob and terminates.
- All actors terminate cleanly.

