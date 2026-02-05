
-ifndef(Q_HRL).
-define(Q_HRL, true).

-record(state_data, {mc_path = [] :: [atom()], p_pid :: pid() | undefined}).

-endif.
