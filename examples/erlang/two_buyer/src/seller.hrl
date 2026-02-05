
-ifndef(SELLER_HRL).
-define(SELLER_HRL, true).

-record(state_data, {mc_path = [] :: [atom()], alice_pid :: pid() | undefined, bob_pid :: pid() | undefined}).

-endif.
