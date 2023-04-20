(* ============================================================================
 * Call types
 * ============================================================================ *)
 type start_call =
    [@layout:comb]
    {
        unique_id : nat;
        period : nat;
        voters_contract : address;
 }

type vote_value = Yay | Nay | Abstain

 type vote_call =
    [@layout:comb]
    {
        unique_id : nat;
        vote_value : vote_value;
}