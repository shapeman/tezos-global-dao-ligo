(* ============================================================================
 * Constants
 * ============================================================================ *)

(* ============================================================================
 * State machine
 * ============================================================================ *)


(* ============================================================================
 * Interface parameters for other contracts / users
 * ============================================================================ *)


(* ============================================================================
 * Type
 * ============================================================================ *)

(* ============================================================================
 * Child storages
 * ============================================================================ *)
type funding_storage = {
    id : nat;
    parent : address;
    contract_state : state;
}
let build_storage (id : nat) (parent : address) : funding_storage =
  { id = id;
    parent = parent;
    contract_state = 0n }

(* ============================================================================
 * Child parameters
 * ============================================================================ *) 

(* ============================================================================
 * Contract parameter and storage
 * ============================================================================ *)
type parameter = nat

type storage = {
    owner : address;
}
type return_ = operation list * storage

(* ============================================================================
 * Contracts code
 * ============================================================================ *)
[@inline] let create_contract = [%Michelson ({|{ UNPAIR 3 ; CREATE_CONTRACT ;
#include "./dummy.tz";
                   PAIR}|} : create_contract_args -> create_contract_result)]

type create_contract_args =
  [@layout:comb]
  (* order matters because we will cross the Michelson boundary *)
  { delegate : key_hash option;
    balance : tez;
    storage : child_storage }

type create_contract_result =
  [@layout:comb]
  { operation : operation;
    address : address }

(* ============================================================================
 * Main
 * ============================================================================ *)
let build (id : parameter) (store : storage) : return_ =
  let {operation; address = _} =
    create_contract { delegate = (None : key_hash option);
                      balance = 0tez;
                      storage =  build_storage id Tezos.get_self_address()} in
  ([operation], store)