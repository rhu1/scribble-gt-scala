%%-------------------------------------------------------------------
%% @doc State record for role `bob` (interleave_condition).
%%-------------------------------------------------------------------

-ifndef(BOB_HRL).
-define(BOB_HRL, true).

-record(state_data, {alice_pid :: pid() | undefined, bob_pid :: pid() | undefined}).

-endif.
