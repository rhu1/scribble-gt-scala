
-ifndef(CONTROLLER_HRL).
-define(CONTROLLER_HRL, true).

-record(state_data, {mc_path = [] :: [atom()], storage_pid :: pid() | undefined, api_pid :: pid() | undefined, usr_pid :: pid() | undefined}).

-endif.
