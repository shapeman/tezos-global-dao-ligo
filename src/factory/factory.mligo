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


(* ============================================================================
 * Contract parameter and storage
 * ============================================================================ *)
type parameter = address

type storage = {
    owner : address;
}
type return_ = operation list * storage


#include "../lib/funding_round_lib.mligo"

(* ============================================================================
 * Contracts code
 * ============================================================================ *)
[@inline] let create_contract = [%Michelson ({|{ UNPAIR 3 ; CREATE_CONTRACT ;
#include "./child.tz";
                   PAIR}|} : create_contract_args -> create_contract_result)]


(* ============================================================================
 * Main
 * ============================================================================ *)
let build (address : parameter) (store : storage) : return_ =

    

type child_storage = unit

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



let main (_ : unit * unit) : operation list * unit =
  let {operation; address = _} =
    create_contract { delegate = (None : key_hash option);
                      balance = Tezos.get_amount ();
                      storage = () } in
  ([operation], ())
