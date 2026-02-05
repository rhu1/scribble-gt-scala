
-ifndef(M_HRL).
-define(M_HRL, true).

-record(state_data, {mc_path = [] :: [atom()], w_pid :: pid() | undefined, fd_pid :: pid() | undefined}).

-endif.
