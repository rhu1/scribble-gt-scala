
-ifndef(BOB_HRL).
-define(BOB_HRL, true).

-record(state_data, {mc_path = [] :: [atom()], alice_pid :: pid() | undefined, seller_pid :: pid() | undefined}).

-endif.
