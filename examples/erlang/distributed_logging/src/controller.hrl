
-ifndef(CONTROLLER_HRL).
-define(CONTROLLER_HRL, true).

-record(state_data, {mc_path = [] :: [atom()], logs_pid :: pid() | undefined}).

-endif.
