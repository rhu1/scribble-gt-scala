
-ifndef(LOGS_HRL).
-define(LOGS_HRL, true).

-record(state_data, {mc_path = [] :: [atom()], controller_pid :: pid() | undefined}).

-endif.
