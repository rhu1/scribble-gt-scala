%%-------------------------------------------------------------------
%% @doc State record for role `carol` (interleave_condition).
%%-------------------------------------------------------------------

-ifndef(CAROL_HRL).
-define(CAROL_HRL, true).

-record(state_data, {alice_pid :: pid() | undefined, carol_pid :: pid() | undefined}).

-endif.
