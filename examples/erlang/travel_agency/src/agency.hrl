
-ifndef(AGENCY_HRL).
-define(AGENCY_HRL, true).

-record(state_data, {mc_path = [] :: [atom()], client_pid :: pid() | undefined, supplier_pid :: pid() | undefined}).

-endif.
