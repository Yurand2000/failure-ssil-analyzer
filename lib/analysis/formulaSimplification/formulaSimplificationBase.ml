open DataStructures.Analysis
open Analysis_Utils

(** [simplify_formula formula] applies recursively a set of simplifcation functions to the
 [formula] until a fix-point is reached, i.e. the repeated simplifcation of the formula does not change the final result. *)
let simplify_formula (formula: NormalForm.t) =
  let simplification_functs = [
    UnitAnd.f;
    UnitOr.f;
    UnitAndSep.f;
    RemoveDuplicateTrueInAndSep.f;
    NoSharedIdentifierAndSep.f;
    ZeroAnd.f;
    ExpressionSimplification.f;
    RemoveIdentityComparisons.f;
    DuplicateDisjoints.f;
    BoundVariableCleanup.f;
  ] in
  let rec simplify formula =
    let simplified = List.fold_left (|>) formula simplification_functs in
    match equal_formulas simplified formula with
    | true  -> simplified
    | false -> simplify simplified
  in
  simplify formula