
-ifndef(CAROL_HRL).
-define(CAROL_HRL, true).

-record(state_data, {mc_path = [] :: [atom()], srv_pid :: pid() | undefined, alice_pid :: pid() | undefined}).

-endif.
