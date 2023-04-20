#include "../helper/error.mligo"

(* ============================================================================
 * Local functions and contants
 * ============================================================================ *)

(* When the dynamic quorum is adjusted, 
we use 80% of the current quorum and 20% of the current participation
# to adust the quorum for the next poll *)
[@inline] let dynamic_quorum_weight_factor : nat = 8000n
[@inline] let dynamic_participation_weight_factor : nat = 2000n

(* Scale is the precision with which numbers are measured. *)
[@inline] let scale = 10000n

(* ============================================================================
 * Entrypoints implementation
 * ============================================================================ *)
(* start *)
let start (params : start_call) (store : storage) : storage =
    (* Asserts *)
    let sender = Tezos.get_sender() in
    let amount = Tezos.get_amount() in
    let () = assert_with_error (sender = store.owner) unauthorized_user in
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
    let vi : vote_info = {
        unique_id = params.unique_id;
        nay = 0n;
        yay = 0n;
        abstain = 0n;
        vote_state = InProgress;
        start_level = Tezos.get_level();
        end_level = Tezos.get_level() + params.period + store.governance.delay_block;
        total_voting_power = total_voting_power;
        voters_contract = params.voters_contract;
        quorum = (total_voting_power * store.governance.quorum_per_ten_mille) / scale;
        governance = store.governance;
    } in
    {store with vote = Big_map.add params.unique_id vi store.vote; 
                vote_history = Big_map.add store.vote_history_size params.unique_id store.vote_history;
                vote_history_size = store.vote_history_size + 1n;}


(* vote *)
let vote (params : vote_call) (store : storage) : storage =
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
    let add_vote_value = match params.vote_value with
        | Yay -> {vi with yay = vi.yay + voting_power}
        | Nay -> {vi with nay = vi.nay + voting_power}
        | Abstain -> {vi with abstain = vi.abstain + voting_power}
    in
    {store with vote = Big_map.update params.unique_id (Some(add_vote_value)) store.vote; 
                voters_history = Big_map.add (sender, params.unique_id) (voting_power, params.vote_value) store.voters_history;
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
    let total_votes = vi.yay + vi.nay + vi.abstain in
    let vote_result : vote_state = 
        let total_opiniated_votes = vi.yay + vi.nay in
        let yay_votes_supermajority = (total_opiniated_votes * vi.governance.supermajority_per_ten_mille) / scale in
        if (vi.yay >= yay_votes_supermajority) && (total_votes >= vi.quorum) then Passed else Rejected
    in
    let update_vi =
        {vi with vote_state = vote_result}
    in
    let update_quorum : nat =
        let last_weight = (vi.quorum * dynamic_quorum_weight_factor) / scale in
        let new_participation = (total_votes * dynamic_participation_weight_factor) / scale in
        let new_quorum_per_ten_mille = (last_weight + new_participation) * scale in
        if new_quorum_per_ten_mille < vi.governance.quorum_cap_low_per_ten_mille then vi.governance.quorum_cap_low_per_ten_mille
             else if new_quorum_per_ten_mille > vi.governance.quorum_cap_high_per_ten_mille then vi.governance.quorum_cap_high_per_ten_mille
                else new_quorum_per_ten_mille
    in
    {store with vote = Big_map.update unique_id (Some(update_vi)) store.vote;
                governance = {store.governance with quorum_per_ten_mille = update_quorum};}