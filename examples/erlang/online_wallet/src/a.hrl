
-ifndef(A_HRL).
-define(A_HRL, true).

-record(state_data, {mc_path = [] :: [atom()], c_pid :: pid() | undefined, s_pid :: pid() | undefined}).

-endif.
