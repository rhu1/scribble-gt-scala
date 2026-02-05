
-ifndef(ALICE_HRL).
-define(ALICE_HRL, true).

-record(state_data, {mc_path = [] :: [atom()], carol_pid :: pid() | undefined, srv_pid :: pid() | undefined}).

-endif.
