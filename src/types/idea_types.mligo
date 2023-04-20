#include "types.mligo"
(* ============================================================================
 * Idea contract Types
 * ============================================================================ *)
type history_map_value = 
    [@layout comb]{
    new : string set;
    level : nat;
    data : (string, bytes) map;
}

(* storage *)
type storage = {
    id : nat;
    parent : address;
    contract_state : state;
    owners : address set;
    assessors :  (address, bool) map;

    start_draft : nat;
    draft_period : nat;
    assess_period : nat;

    current_data : (string, bytes) map;
    new_entries_tag : string set;

    history : (nat, history_map_value) big_map;
    history_size : nat;

    last_update_level : nat option;

    requested_fund : tez;
}