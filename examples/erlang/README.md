# Generated Erlang/OTP examples

This directory contains the runnable Erlang/OTP applications used in the artifact evaluation.

## Recommended way to run everything

From the repository root:

```sh
./mMST.sh -run-erlang-examples
```

This will:
- run the RabbitMQ selective-consumer unit tests (reported as `rabbitmq_server(amqp_client_eunit)`), and
- compile and smoke-run each OTP app under this directory.

## Apps

- `calculator/`
- `circuit_breaker/`
- `distributed_logging/`
- `failure_handling/`
- `fibonacci/`
- `interleave_chaining/`
- `interleave_condition/`
- `interleave_condition_ets/`
- `interrupt/`
- `online_wallet/`
- `rabbitmq-server/` (case study snapshot; unit tests run via `gmake`)
- `smtp/`
- `timeout/`
- `travel_agency/`
- `two_buyer/`

Each subdirectory contains its own `README.md` with details.
