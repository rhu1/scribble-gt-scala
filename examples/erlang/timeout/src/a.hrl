
-ifndef(A_HRL).
-define(A_HRL, true).

-record(state_data, {mc_path = [] :: [atom()], b_pid :: pid() | undefined, c_pid :: pid() | undefined}).

-endif.
