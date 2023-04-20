#include "../types/idea_types.mligo"

(* ============================================================================
 * Constants
 * ============================================================================ *)
[@inline] let spam_protection_block_number : nat = 20n

(* ============================================================================
 * State machine
 * ============================================================================ *)
let entered : state = 0n
let draft : state = 1n
let assessed : state = 2n
let approved : state = 3n
let rejected : state = 4n

(* ============================================================================
 * Interface parameters for other contracts / users
 * ============================================================================ *)
type move_to_draft_param = 
    [@layout comb] {
    draft_period : nat; 
    assess_period : nat;
}

(* ============================================================================
 * Type
 * ============================================================================ *)


(* ============================================================================
 * Contract parameter
 * ============================================================================ *)
type parameter = 
    | AddOwner of address
    | AddAssessor of address
    | RemoveAssessor of address
    | MoveToDraft of move_to_draft_param
    | SetFundRequest of tez
    | CloseIdea
    | Update of (string, bytes) map
    | Approve

type return_ = operation list * storage


#include "../lib/idea_lib.mligo"

(* ============================================================================
 * Views
 * ============================================================================ *)
[@view] let get_state ((),store : unit * storage) : nat = store.contract_state
[@view] let get_requested_fund ((),store : unit * storage) : tez = store.requested_fund

(* ============================================================================
 * Main
 * ============================================================================ *)
let main (action : parameter) (store : storage) : return_ =
    [],
    (match action with
    | AddOwner n -> add_owner n store
    | AddAssessor n -> add_assessor n store
    | RemoveAssessor n -> remove_assessor n store
    | MoveToDraft n -> move_to_draft n store
    | SetFundRequest n -> set_fund_request n store
    | CloseIdea -> close_idea store
    | Update n -> update n store
    | Approve -> approve store
    )

