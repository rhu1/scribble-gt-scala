
-ifndef(S_HRL).
-define(S_HRL, true).

-record(state_data, {mc_path = [] :: [atom()], c_pid :: pid() | undefined, a_pid :: pid() | undefined}).

-endif.
