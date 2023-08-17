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


(*  View: get config *)
[@view] function getConfig(const _ : unit; const s : bountyStorageType) :bountyConfigType is
    s.config



(*  View: get break glass config *)
[@view] function getBreakGlassConfig(const _ : unit; const s : bountyStorageType) : bountyBreakGlassConfigType is
    s.breakGlassConfig



(* View: get whitelist contracts opt *)
[@view] function getWhitelistContractOpt(const contractAddress : address; const s : bountyStorageType) : option(unit) is 
    Big_map.find_opt(contractAddress, s.whitelistContracts)



(* View: get bounty creators opt *)
[@view] function getBountyCreatorsOpt(const userAddress : address; const s : bountyStorageType) : option(bountyCreatorRecordType) is 
    Big_map.find_opt(userAddress, s.bountyCreators)



(* get: general contracts opt *)
[@view] function getGeneralContractOpt(const contractName : string; const s : bountyStorageType) : option(address) is
    Map.find_opt(contractName, s.generalContracts)



(* View: getBountyRecordOpt *)
[@view] function getBountyRecordOpt(const bountyId : nat; const s : bountyStorageType) : option(bountyRecordType) is
    Big_map.find_opt(bountyId, s.bountyLedger)



(* View: getApplicantRecordOpt *)
[@view] function getApplicantRecordOpt(const applicantKey : (nat * address); const s : bountyStorageType) : option(applicantRecordType) is
    Big_map.find_opt(applicantKey, s.applicantLedger)



(* View: getUserRecordOpt *)
[@view] function getUserRecordOpt(const userAddress : address; const s : bountyStorageType) : option(userRecordType) is
    Big_map.find_opt(userAddress, s.userLedger)



(*  View: getNextBountyId *)
[@view] function getNextBountyId(const _ : unit; const s : bountyStorageType) : nat is
    s.nextBountyId



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