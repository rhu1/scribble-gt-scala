%%-------------------------------------------------------------------
%% @doc State record for role `alice2` (interleave_condition).
%%-------------------------------------------------------------------

-ifndef(ALICE2_HRL).
-define(ALICE2_HRL, true).

-record(state_data, {alice_pid :: pid() | undefined, bob_pid :: pid() | undefined}).

-endif.
