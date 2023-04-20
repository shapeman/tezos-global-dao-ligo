#include "../types/call_types.mligo"
#include "../types/promotion_vote_types.mligo"

(* ============================================================================
 * Constants
 * ============================================================================ *)

(* ============================================================================
 * Vote State machine
 * ============================================================================ *)

(* ============================================================================
 * Interface parameters for other contracts / users
 * ============================================================================ *)

(* ============================================================================
 * Type
 * ============================================================================ *)


(* ============================================================================
 * Contract parameter
 * ============================================================================ *)
type parameter = 
    | Start of start_call
    | Vote of vote_call
    | Stop of unique_id
    | UpdateGovernance of governance
    | RemoveOwner of address
    | AddOwner of address

type return_ = operation list * storage

#include "../lib/promotion_vote_lib.mligo"

(* ============================================================================
 * Views
 * ============================================================================ *)

(* ============================================================================
 * Main
 * ============================================================================ *)
let main (action : parameter) (store : storage) : return_ =
    [],
    (match action with
    | Start n -> start n store
    | Vote n -> vote n store
    | Stop n -> stop n store
    | UpdateGovernance n -> update_governance n store
    | RemoveOwner n -> remove_owner n store
    | AddOwner n -> add_owner n store
    )

