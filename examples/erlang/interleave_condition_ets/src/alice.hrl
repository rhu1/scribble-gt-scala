-record(state_data, {alice_pid :: pid() | undefined,
                     carol_pid :: pid() | undefined,
                     bob_pid :: pid() | undefined,
                     turn :: boolean() % true if it's alice2's turn
                     }).
