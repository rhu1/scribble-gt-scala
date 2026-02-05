
-ifndef(SUPPLIER_HRL).
-define(SUPPLIER_HRL, true).

-record(state_data, {mc_path = [] :: [atom()], client_pid :: pid() | undefined, agency_pid :: pid() | undefined}).

-endif.
