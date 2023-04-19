#include "../helper/error.mligo"

(* ============================================================================
 * Local functions
 * ============================================================================ *)
let get_nat_state_internal (store : storage) : nat = 
    match store.contract_state with
    | NotStarted -> not_started
    | Started -> started


(* ============================================================================
 * Entrypoints implementation
 * ============================================================================ *)
(* start *)
let start (store : storage) : storage =
    (* asserts *)
    let sender = Tezos.get_sender() in
    let amount = Tezos.get_amount() in
    let () = assert_with_error (amount = 0tez) do_not_accept_tez in
    let () = assert_with_error (store.parent = sender) not_parent in
    let () = assert_with_error (store.contract_state = NotStarted) wrong_state in

    (* body *)
    {store with contract_state = Started}


