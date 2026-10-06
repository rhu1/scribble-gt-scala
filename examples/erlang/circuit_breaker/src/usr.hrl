
-ifndef(USR_HRL).
-define(USR_HRL, true).

-record(state_data, {controller_pid :: pid() | undefined, storage_pid :: pid() | undefined, api_pid :: pid() | undefined}).

-endif.
