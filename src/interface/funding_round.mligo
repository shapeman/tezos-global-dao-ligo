#include "../types/funding_round_types.mligo"

(* ============================================================================
 * Constants
 * ============================================================================ *)

(* ============================================================================
 * State machine
 * ============================================================================ *)
(* ============================================================================
 * Constants
 * ============================================================================ *)

(* ============================================================================
 * State machine
 * ============================================================================ *)
let not_started : state = 0n
let started : state = 1n

(* ============================================================================
 * Interface parameters for other contracts / users
 * ============================================================================ *)


(* ============================================================================
 * Type
 * ============================================================================ *)


(* ============================================================================
 * Contract parameter
 * ============================================================================ *)
type parameter = Start

(* ============================================================================
 * Entrypoints
 * ============================================================================ *)
type return_ = operation list * storage

#include "../lib/funding_round_lib.mligo"

(* ============================================================================
 * Views
 * ============================================================================ *)
[@view] let get_state ((),store : unit * storage) : nat = store.contract_state

(* ============================================================================
 * Main
 * ============================================================================ *)
let main (action : parameter) (store : storage) : return_ =
    [],
    (match action with
    | Start -> start store
    )

