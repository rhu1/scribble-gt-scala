
-ifndef(ALICE_HRL).
-define(ALICE_HRL, true).

-record(state_data, {mc_path = [] :: [atom()], seller_pid :: pid() | undefined, bob_pid :: pid() | undefined}).

-endif.
