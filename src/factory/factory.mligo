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

[@inline] let create_contract =
  [%Michelson ({|{ UNPAIR 3;
                   CREATE_CONTRACT
#include "./child.tz";
                   PAIR
                   }|} : create_contract_args -> create_contract_result)]

let main (_ : unit * unit) : operation list * unit =
  let {operation; address = _} =
    create_contract { delegate = (None : key_hash option);
                      balance = Tezos.get_amount ();
                      storage = () } in
  ([operation], ())
