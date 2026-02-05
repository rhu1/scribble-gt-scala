# RabbitMQ case study (artifact snapshot)

This directory is a **vendored snapshot** of the `rabbitmq-server` source tree used in our artifact.
It exists to support the paper's RabbitMQ case study, in particular a **selective consumer** implemented using the generated protocol-enforcing `gen_statem` wrappers.

## What's different from upstream

- The protocol-guided selective-consumer implementation lives under:
  - `deps/amqp_client/src/amqp_selective_consumer.erl`
  - generated wrapper used by the module:
    - `deps/amqp_client/src/gen_consumer.erl`
- We also include an **EUnit** test suite that exercises the selective consumer without requiring a running broker:
  - `deps/amqp_client/test/amqp_selective_consumer_tests.erl`

## Run the unit tests (recommended)

From the project root:

```sh
./mMST.sh -run-erlang-examples
```

You should see a PASS entry in the summary:

- `rabbitmq_server(amqp_client_eunit)`

## Run the unit tests directly

From this directory:

```sh
cd deps/amqp_client
# RabbitMQ uses erlang.mk here, so we require GNU Make ("gmake" on macOS).

gmake -j1 eunit
```

Expected output includes something like:

- `2 tests passed.`

## Notes

- This snapshot is included for *artifact evaluation* only. It is not intended to be a full RabbitMQ build-from-source workflow.
- The test suite is intentionally lightweight and does not spin up RabbitMQ; it drives the consumer callback module directly.
