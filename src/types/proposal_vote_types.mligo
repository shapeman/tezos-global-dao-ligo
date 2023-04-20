#include "types.mligo"
#include "call_types.mligo"
(* ============================================================================
 * Promotion vote types
 * ============================================================================ *)
(* storage *)
type vote_state = InProgress | Done

type governance =
    [@layout:comb]
    {
    delay_block : nat;
    supermajority_per_ten_mille : nat;
    quorum_cap_low_per_ten_mille : nat;
    quorum_cap_high_per_ten_mille : nat;
    quorum_per_ten_mille : nat;
}

type vote_info = 
    [@layout:comb]
    {
    unique_id : unique_id;
    nay : nat;
    yay : nat;
    abstain : nat;
    vote_state : vote_state;
    start_level : nat;
    end_level : nat;
    total_voting_power : nat;
    voters_contract : address;
    quorum : nat;
    governance : governance;
}

type storage = {
    (* owners *)
    owner : address;

    (* vote *)
    vote : (unique_id, vote_info) big_map;

    (* governance *)
    governance : governance;

    (* History *)
    vote_history : (nat, unique_id) big_map;
    voters_history : ((address * unique_id), (nat * vote_value)) big_map;
    vote_history_size : nat;
}