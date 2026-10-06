
-ifndef(SELLER_HRL).
-define(SELLER_HRL, true).

-record(state_data, {alice_pid :: pid() | undefined, bob_pid :: pid() | undefined}).

-endif.
