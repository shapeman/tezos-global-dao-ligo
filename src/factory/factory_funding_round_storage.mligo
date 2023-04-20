#include "../types/funding_round_types.mligo"

(* ============================================================================
 * Child storages
 * ============================================================================ *)
let build_storage (id : nat) (parent : address) : storage =
  { id = id;
    parent = parent;
    contract_state = 0n }