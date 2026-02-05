
-ifndef(STORAGE_HRL).
-define(STORAGE_HRL, true).

-record(state_data, {mc_path = [] :: [atom()], controller_pid :: pid() | undefined, api_pid :: pid() | undefined, usr_pid :: pid() | undefined}).

-endif.
