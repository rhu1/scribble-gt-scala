%%-------------------------------------------------------------------
%% @doc State record for role `alice` (interleave_chaining).
%%-------------------------------------------------------------------

-ifndef(ALICE_HRL).
-define(ALICE_HRL, true).

-record(state_data, {alice_pid :: pid() | undefined, carol_pid :: pid() | undefined}).

-endif.
