(* ============================================================================
 * Child storages
 * ============================================================================ *)
type funding_storage = {
    id : nat;
    parent : address;
    contract_state : nat;
}
let build_storage (id : nat) (parent : address) : funding_storage =
  { id = id;
    parent = parent;
    contract_state = 0n }