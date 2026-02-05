
-ifndef(W_HRL).
-define(W_HRL, true).

-record(state_data, {mc_path = [] :: [atom()], m_pid :: pid() | undefined, fd_pid :: pid() | undefined}).

-endif.
