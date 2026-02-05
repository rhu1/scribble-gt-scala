%%-------------------------------------------------------------------
%% @doc State record for role `alice` (interleave_condition).
%%-------------------------------------------------------------------

-ifndef(ALICE_HRL).
-define(ALICE_HRL, true).

-record(state_data, {
                      alice_pid :: pid() | undefined,
                      carol_pid :: pid() | undefined,
                      bob_pid :: pid() | undefined,
                      turn :: boolean()
    }).

-endif.
