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
}

type vote_info = 
    [@layout:comb]
    {
    unique_id : unique_id;
    proposals : (nat, nat) map;
    vote_state : vote_state;
    start_level : nat;
    end_level : nat;
    total_voting_power : nat;
    voters_contract : address;
    governance : governance;
}

type storage = {
    (* owners *)
    owners : address set;

    (* vote *)
    vote : (unique_id, vote_info) big_map;

    (* governance *)
    governance : governance;

    (* History *)
    vote_history : (nat, unique_id) big_map;
    voters_history : ((address * unique_id), (nat * nat)) big_map;
    vote_history_size : nat;
}