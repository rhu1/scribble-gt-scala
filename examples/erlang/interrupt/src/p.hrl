
-ifndef(P_HRL).
-define(P_HRL, true).

-record(state_data, {mc_path = [] :: [atom()], q_pid :: pid() | undefined}).

-endif.
