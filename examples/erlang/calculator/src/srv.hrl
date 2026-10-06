
-ifndef(SRV_HRL).
-define(SRV_HRL, true).

-record(state_data, {carol_pid :: pid() | undefined, alice_pid :: pid() | undefined}).

-endif.
