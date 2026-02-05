
-ifndef(API_HRL).
-define(API_HRL, true).

-record(state_data, {mc_path = [] :: [atom()], controller_pid :: pid() | undefined, storage_pid :: pid() | undefined, usr_pid :: pid() | undefined}).

-endif.
