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
[@view] function getConfig(const _ : unit; const s : bountyStorageType) : bountyConfigType is
    s.config



(* View: get bounty creators opt *)
[@view] function getBountyCreatorsOpt(const userAddress : address; const s : bountyStorageType) : option(bountyCreatorRecordType) is 
    Big_map.find_opt(userAddress, s.bountyCreators)



(* View: getBountyRecordOpt *)
[@view] function getBountyRecordOpt(const bountyId : nat; const s : bountyStorageType) : option(bountyRecordType) is
    Big_map.find_opt(bountyId, s.bountyLedger)



(* View: getApplicationRecordOpt *)
[@view] function getApplicationRecordOpt(const applicationKey : (nat * applicantType); const s : bountyStorageType) : option(applicationRecordType) is
    Big_map.find_opt(applicationKey, s.applicationLedger)



(* View: getUserRecordOpt *)
[@view] function getUserRecordOpt(const userAddress : address; const s : bountyStorageType) : option(userRecordType) is
    Big_map.find_opt(userAddress, s.userLedger)



(*  View: getNextBountyId *)
[@view] function getNextBountyId(const _ : unit; const s : bountyStorageType) : nat is
    s.nextBountyId



(* View: get a lambda *)
[@view] function getLambdaOpt(const lambdaName: string; const s : bountyStorageType) : option(bytes) is
    Big_map.find_opt(lambdaName, s.lambdaLedger)

// ------------------------------------------------------------------------------
//
// Views End
//
// ------------------------------------------------------------------------------