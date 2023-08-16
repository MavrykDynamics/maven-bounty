// ------------------------------------------------------------------------------
//
// Views Begin
//
// ------------------------------------------------------------------------------

(* View: get super admin variable *)
[@view] function getSuperAdmin(const _ : unit; const s : bountyStorageType) : address is
    s.superAdmin



(* View: get admins *)
[@view] function getAdmins(const _ : unit; const s : bountyStorageType) : set(address) is
    s.admins


(* View: get a lambda *)
[@view] function getLambdaOpt(const lambdaName: string; const s : bountyStorageType) : option(bytes) is
    Map.find_opt(lambdaName, s.lambdaLedger)



(* View: get the lambda ledger *)
[@view] function getLambdaLedger(const _ : unit; const s : bountyStorageType) : lambdaLedgerType is
    s.lambdaLedger

// ------------------------------------------------------------------------------
//
// Views End
//
// ------------------------------------------------------------------------------