
-ifndef(CLIENT_HRL).
-define(CLIENT_HRL, true).

-record(state_data, {agency_pid :: pid() | undefined, supplier_pid :: pid() | undefined}).

-endif.
