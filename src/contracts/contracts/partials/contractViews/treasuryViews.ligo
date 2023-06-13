// ------------------------------------------------------------------------------
//
// Views Begin
//
// ------------------------------------------------------------------------------

(* View: get super admin variable *)
[@view] function getSuperAdmin(const _ : unit; const s : treasuryStorageType) : address is
    s.superAdmin



(* View: get admins *)
[@view] function getAdmins(const _ : unit; const s : treasuryStorageType) : set(address) is
    s.admins



(* View: get whitelist contracts *)
[@view] function getWhitelistContracts(const _ : unit; const s : treasuryStorageType) : whitelistContractsType is
    s.whitelistContracts



(* View: get whitelist token contracts *)
[@view] function getWhitelistTokenContracts(const _ : unit; const s : treasuryStorageType) : whitelistTokenContractsType is
    s.whitelistTokenContracts



(* View: get general contracts *)
[@view] function getGeneralContracts(const _ : unit; const s : treasuryStorageType) : generalContractsType is
    s.generalContracts



(* View: get a lambda *)
[@view] function getLambdaOpt(const lambdaName: string; const s : treasuryStorageType) : option(bytes) is
    Map.find_opt(lambdaName, s.lambdaLedger)



(* View: get the lambda ledger *)
[@view] function getLambdaLedger(const _ : unit; const s : treasuryStorageType) : lambdaLedgerType is
    s.lambdaLedger

// ------------------------------------------------------------------------------
//
// Views End
//
// ------------------------------------------------------------------------------