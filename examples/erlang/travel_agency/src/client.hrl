
-ifndef(CLIENT_HRL).
-define(CLIENT_HRL, true).

-record(state_data, {mc_path = [] :: [atom()], agency_pid :: pid() | undefined, supplier_pid :: pid() | undefined}).

-endif.
