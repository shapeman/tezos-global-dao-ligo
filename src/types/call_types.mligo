(* ============================================================================
 * Call types
 * ============================================================================ *)
 type promotion_vote_start_call =
    [@layout:comb]
    {
        unique_id : nat;
        period : nat;
        voters_contract : address;
 }

type proposal_vote_start_call =
    [@layout:comb]
    {
        unique_id : nat;
        period : nat;
        proposals : nat set;
        voters_contract : address;
 }

type proposal_vote_call =
    [@layout:comb]
    {
        unique_id : nat;
        proposal : nat;
}

type promotion_vote_value = Yay | Nay | Abstain

type promotion_vote_call =
    [@layout:comb]
    {
        unique_id : nat;
        vote_value : promotion_vote_value;
}