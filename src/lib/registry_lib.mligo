#include "../helper/error.mligo"

(* ============================================================================
 * Local functions
 * ============================================================================ *)
let get_build_entrypoint (addr : address) = 
    match Tezos.get_entrypoint_opt "%add" addr with
    | Some contract -> contract
    | None -> failwith "The entrypoint does not exist"

(* ============================================================================
 * Entrypoints implementation
 * ============================================================================ *)
(* set_next_administrator *)
let set_next_administrator (address : address) (store : storage) : storage =
    (* Asserts *)
    let sender = Tezos.get_sender() in
    let amount = Tezos.get_amount() in
    let () = assert_with_error (sender = store.administrator) not_admin in
    let () = assert_with_error (amount = 0tez) do_not_accept_tez in
    
    (* Body *)
    {store with next_administrator = Some(address)}


(* validate_new_administrator *)
let validate_new_administrator (store : storage) : storage =
    (* Asserts *)
    let sender = Tezos.get_sender() in
    let amount = Tezos.get_amount() in
    let exists = match store.next_administrator with
        | Some(n) -> if n = sender then true else false
        | None -> false
    in
    let () = assert_with_error (exists) not_next_admin in
    let () = assert_with_error (amount = 0tez) do_not_accept_tez in
    
    (* Body *)
    {store with administrator = sender; next_administrator = None}


(* set_factory_funding *)
let set_factory_funding (address : address) (store : storage) : storage =
    (* Asserts *)
    let sender = Tezos.get_sender() in
    let amount = Tezos.get_amount() in

    (* There is an open point of discussion whether the admin actually exits 
    and can change the factories. This could be a task for the DAO. *)
    let () = assert_with_error (sender = store.administrator) not_admin in
    let () = assert_with_error (amount = 0tez) do_not_accept_tez in
    
    (* Body *)
    {store with funding_factory_contract = Some(address)}

(* start_funding *)
let start_funding (store : storage) : operation list * storage =
    (* Asserts *)
    let sender = Tezos.get_sender() in
    let amount = Tezos.get_amount() in

    (* There is an open point of discussion whether the admin actually exits 
    and can change the factories. This could be a task for the DAO. *)
    let () = assert_with_error (sender = store.administrator) not_admin in
    let funding_contract_none = match store.current_funding_contract with
        | Some(_) -> false
        | None -> true
    in
    let () = assert_with_error (funding_contract_none) funding_already_started in
    let () = assert_with_error (store.contract_state = idle) funding_already_started in
    let () = assert_with_error (amount = 0tez) do_not_accept_tez in
    
    (* Body *)
    match store.funding_factory_contract with
        | Some addr ->  
            let build : nat contract = get_build_entrypoint (addr) in
            let ops = Tezos.transaction (store.history_size) 0tez build in
            ([ops], {store with contract_state = opening_funding})
        | None -> failwith no_funding_factory



(* factory_callback *)
let factory_callback (contract_address : address) (store : storage) : storage =
    (* Asserts *)
    let sender = Tezos.get_sender() in
    let amount = Tezos.get_amount() in
    let is_factory = match store.funding_factory_contract with
        | Some(addr) -> addr = sender
        | None -> false
    in
    let () = assert_with_error (is_factory) unauthorized_user in
    let () = assert_with_error (amount = 0tez) do_not_accept_tez in
    let () = assert_with_error (store.contract_state = opening_funding) funding_already_started in
    
    (* Body *)
    {store with current_funding_contract = Some(contract_address); contract_state = funding_in_progress}

