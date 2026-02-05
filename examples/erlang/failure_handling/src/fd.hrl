
-ifndef(FD_HRL).
-define(FD_HRL, true).

-record(state_data, {mc_path = [] :: [atom()], m_pid :: pid() | undefined, w_pid :: pid() | undefined}).

-endif.
