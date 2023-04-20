#include "types.mligo"
(* ============================================================================
 * Types
 * ============================================================================ *)
 (* storage *)
type storage = {
    id : nat;
    parent : address;
    contract_state : state;
}