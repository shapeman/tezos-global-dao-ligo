#include "error.mligo"

// Local functions
let get_nat_state_internal (store : storage) : nat = 
    match store.contract_state with
    | Entered -> state_entered
    | Draft -> state_draft
    | Assessed -> state_assessed
    | Approved -> state_approved
    | Rejected -> state_rejected

let found_assessor (a : address) (store : storage) : bool =
    let found : bool option = Map.find_opt a store.assessors in
    match found with 
    | None -> false
    | Some _x -> true

// add_owner
let add_owner (address : address) (store : storage) : storage =
    // Asserts
    let sender = Tezos.get_sender() in
    let amount = Tezos.get_amount() in
    let () = assert_with_error (amount = 0tez) do_not_accept_tez in
    let () = assert_with_error (Set.mem sender store.owners) not_owner in
    let () = assert_with_error (not Set.mem address store.owners) owner_already_exist in
    // Code
    {store with owners = Set.add address store.owners}


// add_assessor
let add_assessor (address : address) (store : storage) : storage =
    // Asserts
    let sender = Tezos.get_sender() in
    let amount = Tezos.get_amount() in
    let () = assert_with_error (found_assessor sender store) not_assessor in
    let () = assert_with_error (not (found_assessor address store)) assessor_already_exists in
    let () = assert_with_error (amount = 0tez) do_not_accept_tez in

    // Code
    {store with assessors = Map.add address false store.assessors}


// remove_assessor
let remove_assessor (address : address) (store : storage) : storage =
    // Asserts
    let sender = Tezos.get_sender() in
    let amount = Tezos.get_amount() in
    let () = assert_with_error (amount = 0tez) do_not_accept_tez in
    let () = assert_with_error (found_assessor sender store) not_assessor in
    let () = assert_with_error (store.contract_state = Assessed) wrong_state in
    let () = assert_with_error (Map.size store.assessors > 1n) cannot_remove_all_assessors in

    // Code
    {store with assessors = Map.remove address store.assessors}


// move_to_draft
let move_to_draft (params : move_to_draft_param) (store : storage) : storage =
    // Asserts
    let sender = Tezos.get_sender() in
    let amount = Tezos.get_amount() in
    let () = assert_with_error (amount = 0tez) do_not_accept_tez in
    let () = assert_with_error (store.contract_state = Entered) wrong_state in
    let () = assert_with_error (sender = store.parent) not_parent in
    // Code
    {store with contract_state = Draft; draft_period = params.draft_period; assess_period = params.assess_period; start_draft = Tezos.get_level()}


// set_request
let set_fund_request(requested_amount : tez) (store : storage) : storage =
    // Asserts
    let sender = Tezos.get_sender() in
    let amount = Tezos.get_amount() in
    let () = assert_with_error (amount = 0tez) do_not_accept_tez in
    let () = assert_with_error (store.contract_state = Draft) wrong_state in
    let () = assert_with_error (Set.mem sender store.owners) not_owner in
    // Code
    {store with requested_fund = requested_amount}


// close_idea
let close_idea (store : storage) : storage =
    // Asserts
    let sender = Tezos.get_sender() in
    let amount = Tezos.get_amount() in
    let () = assert_with_error (amount = 0tez) do_not_accept_tez in
    let () = assert_with_error ((store.parent = sender) || ((store.contract_state = Draft) && (Set.mem sender store.owners))) wrong_state in

    // Code
    let fold : bool =
        let folder = fun (i,j : bool * (address * bool)) : bool -> i && j.1
        in Map.fold folder store.assessors true
    in
    let assess : storage = 
        if store.draft_period + store.start_draft + store.assess_period < Tezos.get_level() then
            if fold then
                {store with contract_state = Approved}
            else
                {store with contract_state = Rejected}
        else
            {store with contract_state = Rejected}
    in 
    match store.contract_state with 
        | Assessed -> assess
        | Approved -> store
        | _ -> {store with contract_state = Rejected}


    // update
    let update (params : (string, bytes) map) (store : storage) : storage =
        // Asserts
        let sender = Tezos.get_sender() in
        let level = Tezos.get_level() in
        let () = assert_with_error (store.contract_state = Draft) wrong_state in
        let () = assert_with_error (Set.mem sender store.owners) not_owner in
        let ready : bool = 
            match store.last_update_level with
            | None -> true
            | Some x -> x + spam_protection_block_number < level
        in
        let () = assert_with_error ready too_early in

        // Code
        let new_history_entry : history_map_value =
            let fill_history : ((string, bytes) map) =
                let fold_data_history = fun (i, j : (string, bytes) map * (string * bytes)) -> 
                    let contains = Map.find_opt (j.0) store.current_data in
                    match contains with
                    | None -> i
                    | Some x -> Map.add (j.0) x i
                in
                Map.fold fold_data_history params Map.empty
            in
            {new = store.new_entries_tag; level = level; data = fill_history}
        in
        let fill_entries_tag : (string set) =
            let fold_entries_tag = fun (i, j : string set * (string * bytes)) -> 
                let contains = Map.find_opt (j.0) store.current_data in
                match contains with
                | None -> Set.add (j.0) i
                | Some _x -> i
            in
            Map.fold fold_entries_tag params Set.empty
        in
        let fill_data : (string, bytes) map =
            let fold_data = fun (i, j : (string, bytes) map * (string * bytes)) ->
                let contains = Map.find_opt j.0 i in
                match contains with
                | None -> Map.add (j.0) (j.1) i
                | Some _x -> Map.update (j.0) (Some(j.1)) i
            in
            Map.fold fold_data params store.current_data
        in 
        {store with last_update_level = Some(level); 
                    current_data = fill_data;  
                    history = Big_map.add store.history_size new_history_entry store.history;
                    history_size = store.history_size + 1n;
                    new_entries_tag = fill_entries_tag;}

    
    // approve
    let approve (store : storage) : storage =
        // Asserts
        let sender = Tezos.get_sender() in
        let amount = Tezos.get_amount() in
        let () = assert_with_error (amount = 0tez) do_not_accept_tez in
        let () = assert_with_error (store.contract_state = Assessed) wrong_state in
        let found_assessor : bool = 
            match Map.find_opt sender store.assessors with 
            | None -> false
            | Some _x -> true
        in
        let () = assert_with_error (found_assessor) not_owner in

        // Code
        {store with assessors = Map.update sender (Some(true)) store.assessors}


