
-ifndef(C_HRL).
-define(C_HRL, true).

-record(state_data, {mc_path = [] :: [atom()], a_pid :: pid() | undefined, s_pid :: pid() | undefined}).

-endif.
