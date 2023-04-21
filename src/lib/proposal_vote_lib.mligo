#include "../helper/error.mligo"

(* ============================================================================
 * Local functions and contants
 * ============================================================================ *)

(* ============================================================================
 * Entrypoints implementation
 * ============================================================================ *)
(* start *)
let start (params : proposal_vote_start_call) (store : storage) : storage =
    (* Asserts *)
    let sender = Tezos.get_sender() in
    let amount = Tezos.get_amount() in
    let () = assert_with_error (Set.mem sender store.owners) unauthorized_user in
    let () = assert_with_error (amount = 0tez) do_not_accept_tez in
    let not_exists = match Big_map.find_opt params.unique_id store.vote with
        | None -> true
        | Some _ -> false
    in
    let () = assert_with_error (not_exists) vote_already_exists in

    (* Body *)
    let total_voting_power = 
        let call_view : nat option = Tezos.call_view "get_total_voting_power" unit params.voters_contract in
        match call_view with
        | Some x -> if x > 0n then x else failwith cannot_get_total_voting_power
        | None -> failwith cannot_get_total_voting_power
    in
    let build_proposal : (nat, nat) map =
        let fold = fun (acc, item) -> Map.add item 0n acc in
        Set.fold fold params.proposals Map.empty
    in
    let vi : vote_info = {
        unique_id = params.unique_id;
        proposals = build_proposal;
        vote_state = InProgress;
        start_level = Tezos.get_level();
        end_level = Tezos.get_level() + params.period + store.governance.delay_block;
        total_voting_power = total_voting_power;
        voters_contract = params.voters_contract;
        governance = store.governance;
    } in
    {store with vote = Big_map.add params.unique_id vi store.vote; 
                vote_history = Big_map.add store.vote_history_size params.unique_id store.vote_history;
                vote_history_size = store.vote_history_size + 1n;}


(* vote *)
let vote (params : proposal_vote_call) (store : storage) : storage =
    (* Asserts *)
    let sender = Tezos.get_sender() in
    let amount = Tezos.get_amount() in
    let () = assert_with_error (amount = 0tez) do_not_accept_tez in
    let vi = match Big_map.find_opt params.unique_id store.vote with
        | Some x -> x
        | None -> failwith vote_not_found
    in
    let () = assert_with_error (vi.vote_state = InProgress) vote_not_in_progress in
    let () = assert_with_error (Tezos.get_level() < vi.end_level) vote_period_expired in
    let () = assert_with_error (Tezos.get_level() > vi.start_level + vi.governance.delay_block) vote_period_not_started in
    let proposal_exits = match Map.find_opt (params.proposal) vi.proposals with
        | Some _x -> true
        | None -> false
    in
    let () = assert_with_error (proposal_exits) proposal_not_found in
    let has_not_voted = match (Big_map.find_opt (sender, params.unique_id) store.voters_history) with
        | Some _ -> false
        | None -> true
    in
    let () = assert_with_error (has_not_voted) already_voted in

    (* Body *)
    let call_view : nat option = Tezos.call_view "get_voting_power" sender vi.voters_contract in
    let voting_power = match call_view with
        | Some x -> if x > 0n then x else failwith no_voting_power
        | None -> failwith cannot_get_voting_power
    in
    let add_vote_value = 
        let get_proposal = match Map.find_opt (params.proposal) vi.proposals with 
            | Some x -> x
            | None -> failwith proposal_not_found
        in
    {vi with proposals = Map.update params.proposal (Some(get_proposal)) vi.proposals}
    in
    {store with vote = Big_map.update params.unique_id (Some(add_vote_value)) store.vote; 
                voters_history = Big_map.add (sender, params.unique_id) (voting_power, params.proposal) store.voters_history;
}

(* stop *)
let stop (unique_id : unique_id) (store : storage) : storage =
    (* Asserts *)
    let amount = Tezos.get_amount() in
    let () = assert_with_error (amount = 0tez) do_not_accept_tez in
    let vi = match Big_map.find_opt unique_id store.vote with
        | Some x -> x
        | None -> failwith vote_not_found
    in
    let () = assert_with_error (vi.vote_state = InProgress) vote_not_in_progress in
    let () = assert_with_error (Tezos.get_level() > vi.end_level) vote_period_not_expired in

    (* Body *)
    let update_vi =
        {vi with vote_state = Done }
    in
    {store with vote = Big_map.update unique_id (Some(update_vi)) store.vote;}


(* update_governance *)
let update_governance (params : governance) (store : storage) : storage =
    (* Asserts *)
    let amount = Tezos.get_amount() in
    let sender = Tezos.get_sender() in
    let () = assert_with_error (amount = 0tez) do_not_accept_tez in
    let () = assert_with_error (Set.mem sender store.owners) unauthorized_user in

    (* Body *)
    {store with governance = params}

(* add_owner *)
let add_owner (new_owner : address) (store : storage) : storage =
    (* Asserts *)
    let amount = Tezos.get_amount() in
    let sender = Tezos.get_sender() in
    let () = assert_with_error (amount = 0tez) do_not_accept_tez in
    let () = assert_with_error (Set.mem sender store.owners) unauthorized_user in

    (* Body *)
    {store with owners = Set.add new_owner store.owners}

(* remove_owner *)
let remove_owner (owner : address) (store : storage) : storage =
    (* Asserts *)
    let amount = Tezos.get_amount() in
    let sender = Tezos.get_sender() in
    let () = assert_with_error (amount = 0tez) do_not_accept_tez in
    let () = assert_with_error (Set.mem sender store.owners) unauthorized_user in
    let () = assert_with_error (Set.mem owner store.owners) not_owner in
    let () = assert_with_error (Set.size store.owners > 1n) cannot_remove_all_owners in

    (* Body *)
    {store with owners = Set.remove owner store.owners}
