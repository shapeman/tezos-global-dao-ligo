#include "../types/idea_types.mligo"

(* ============================================================================
 * Child storages
 * ============================================================================ *)
let build_storage (id : nat) (parent : address) : storage =
  { id = id;
    parent = parent;
    contract_state = 0n;
    owners = Set.empty;
    assessors = Map.empty;

    start_draft = 0n;
    draft_period = 0n;
    assess_period = 0n;

    current_data = Map.empty;
    new_entries_tag = Set.empty;

    history = Big_map.empty;
    history_size = 0n;

    last_update_level = None;

    requested_fund = 0tez;
    }