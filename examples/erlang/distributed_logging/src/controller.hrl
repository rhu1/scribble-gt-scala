
-ifndef(CONTROLLER_HRL).
-define(CONTROLLER_HRL, true).

-record(state_data, {message_id = 0 :: non_neg_integer(), logs_pid :: pid() | undefined}).

-endif.
