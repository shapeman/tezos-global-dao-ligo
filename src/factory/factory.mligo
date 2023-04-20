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
 #include "./dummy_storage.tz"

(* ============================================================================
 * Child parameters
 * ============================================================================ *) 

(* ============================================================================
 * Contract parameter and storage
 * ============================================================================ *)
type parameter = nat

type factory_storage = {
    owner : address;
}
type return_ = operation list * factory_storage

(* ============================================================================
 * Contracts code
 * ============================================================================ *)
type create_contract_args =
  [@layout:comb]
  (* order matters because we will cross the Michelson boundary *)
  { delegate : key_hash option;
    balance : tez;
    storage : storage }

type create_contract_result =
  [@layout:comb]
  { operation : operation;
    address : address }

[@inline] let create_contract = [%Michelson ({|{ UNPAIR 3 ; CREATE_CONTRACT 
#include "./dummy.tz"
                  ; PAIR}|} : create_contract_args -> create_contract_result)]
(* ============================================================================
 * Main
 * ============================================================================ *)
let build (id : parameter) (store : factory_storage) : return_ =
  let {operation; address = _} =
    create_contract { delegate = (None : key_hash option);
                      balance = 0tez;
                      storage =  build_storage id (Tezos.get_self_address())} in
  ([operation], store)