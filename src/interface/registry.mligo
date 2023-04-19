(* ============================================================================
 * Constants
 * ============================================================================ *)

(* ============================================================================
 * State machine
 * ============================================================================ *)
type state = Idle | OpeningFunding | FundingInProgress | StoppingFunding
[@inline] let idle : nat = 0n
[@inline] let opening_funding : nat = 1n
[@inline] let funding_in_progress : nat = 2n
[@inline] let stopping_funding : nat = 3n

(* ============================================================================
 * Errors
 * ============================================================================ *)

(* ============================================================================
 * Interface parameters for other contracts / users
 * ============================================================================ *)


(* ============================================================================
 * Type
 * ============================================================================ *)


(* ============================================================================
 * Contract parameter and storage
 * ============================================================================ *)
type parameter = 
    | SetNextAdministator of address
    | ValidateNewAdministrator
    | SetFactoryFunding of address

type storage = {
    administrator : address;
    next_administrator : address option;

    contract_state : state;

    funding_factory_contract : address option;
    current_funding_contract : address option;

    history : (nat, address) big_map;
    history_size : nat;
}
type return_ = operation list * storage


#include "../lib/registry_lib.mligo"

(* ============================================================================
 * Views
 * ============================================================================ *)
[@view] let get_state ((),store : unit * storage) : nat = get_nat_state_internal store

(* ============================================================================
 * Main
 * ============================================================================ *)
let main (action : parameter) (store : storage) : return_ =
    [],
    (match action with
    | SetNextAdministator n -> set_next_administrator n store
    | ValidateNewAdministrator -> validate_new_administrator store
    | SetFactoryFunding n -> set_factory_funding n store
    )

