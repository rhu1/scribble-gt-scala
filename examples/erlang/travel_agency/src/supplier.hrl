
-ifndef(SUPPLIER_HRL).
-define(SUPPLIER_HRL, true).

-record(state_data, {client_pid :: pid() | undefined, agency_pid :: pid() | undefined}).

-endif.
