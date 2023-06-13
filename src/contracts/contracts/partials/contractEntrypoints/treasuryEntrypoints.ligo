// ------------------------------------------------------------------------------
//
// Entrypoints Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Admin Entrypoints Begin
// ------------------------------------------------------------------------------

(*  setSuperAdmin entrypoint *)
function setSuperAdmin(const newAdminAddress : address; var s : treasuryStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetSuperAdmin", s.lambdaLedger);

    // init treasury lambda action
    const treasuryLambdaAction : treasuryLambdaActionType = LambdaSetSuperAdmin(newAdminAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, treasuryLambdaAction, s);  
    
} with response



(*  claimSuperAdmin entrypoint *)
function claimSuperAdmin(var s : treasuryStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaClaimSuperAdmin", s.lambdaLedger);

    // init treasury lambda action
    const treasuryLambdaAction : treasuryLambdaActionType = LambdaClaimSuperAdmin(unit);

    // init response
    const response : return = unpackLambda(lambdaBytes, treasuryLambdaAction, s);  
    
} with response



(*  setAdmin entrypoint *)
function setAdmin(const newAdminAddress : address; var s : treasuryStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetAdmin", s.lambdaLedger);

    // init treasury lambda action
    const treasuryLambdaAction : treasuryLambdaActionType = LambdaSetAdmin(newAdminAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, treasuryLambdaAction, s);  
    
} with response



(*  removeAdmin entrypoint *)
function removeAdmin(const adminAddress : address; var s : treasuryStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaRemoveAdmin", s.lambdaLedger);

    // init treasury lambda action
    const treasuryLambdaAction : treasuryLambdaActionType = LambdaRemoveAdmin(adminAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, treasuryLambdaAction, s);  
    
} with response

// ------------------------------------------------------------------------------
// Admin Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Housekeeping Entrypoints Begin
// ------------------------------------------------------------------------------

(* setBaker entrypoint *)
function setBaker(const keyHash : option(key_hash); var s : treasuryStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetBaker", s.lambdaLedger);

    // init treasury lambda action
    const treasuryLambdaAction : treasuryLambdaActionType = LambdaSetBaker(keyHash);

    // init response
    const response : return = unpackLambda(lambdaBytes, treasuryLambdaAction, s);  

} with response



(* updateMetadata entrypoint - update the metadata at a given key *)
function updateMetadata(const updateMetadataParams : updateMetadataType; var s : treasuryStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateMetadata", s.lambdaLedger);

    // init treasury lambda action
    const treasuryLambdaAction : treasuryLambdaActionType = LambdaUpdateMetadata(updateMetadataParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, treasuryLambdaAction, s);  

} with response



(* updateWhitelistContracts entrypoint *)
function updateWhitelistContracts(const updateWhitelistContractsParams : updateWhitelistContractsType; var s : treasuryStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateWhitelistContracts", s.lambdaLedger);

    // init treasury lambda action
    const treasuryLambdaAction : treasuryLambdaActionType = LambdaUpdateWhitelistContracts(updateWhitelistContractsParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, treasuryLambdaAction, s);  

} with response



(* updateGeneralContracts entrypoint *)
function updateGeneralContracts(const updateGeneralContractsParams : updateGeneralContractsType; var s : treasuryStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateGeneralContracts", s.lambdaLedger);

    // init treasury lambda action
    const treasuryLambdaAction : treasuryLambdaActionType = LambdaUpdateGeneralContracts(updateGeneralContractsParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, treasuryLambdaAction, s);  

} with response



(* updateWhitelistTokenContracts entrypoint *)
function updateWhitelistTokenContracts(const updateWhitelistTokenContractsParams : updateWhitelistTokenContractsType; var s : treasuryStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateWhitelistTokenContracts", s.lambdaLedger);

    // init treasury lambda action
    const treasuryLambdaAction : treasuryLambdaActionType = LambdaUpdateWhitelistTokens(updateWhitelistTokenContractsParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, treasuryLambdaAction, s);  

} with response

// ------------------------------------------------------------------------------
// Housekeeping Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Treasury Entrypoints Begin
// ------------------------------------------------------------------------------

(* transfer entrypoint *)
function transfer(const transferTokenParams : transferActionType; var s : treasuryStorageType) : return is 
block {
    
    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaTransfer", s.lambdaLedger);

    // init treasury lambda action
    const treasuryLambdaAction : treasuryLambdaActionType = LambdaTransfer(transferTokenParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, treasuryLambdaAction, s);  

} with response



(* updateMvkOperators entrypoint *)
function updateMvkOperators(const updateOperatorsParams : updateOperatorsType ; var s : treasuryStorageType) : return is 
block {
    
    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateMvkOperators", s.lambdaLedger);

    // init treasury lambda action
    const treasuryLambdaAction : treasuryLambdaActionType = LambdaUpdateMvkOperators(updateOperatorsParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, treasuryLambdaAction, s);  

} with response



(* stakeMvk entrypoint *)
function stakeMvk(const stakeAmount : nat ; var s : treasuryStorageType) : return is 
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaStakeMvk", s.lambdaLedger);

    // init treasury lambda action
    const treasuryLambdaAction : treasuryLambdaActionType = LambdaStakeMvk(stakeAmount);

    // init response
    const response : return = unpackLambda(lambdaBytes, treasuryLambdaAction, s);  

} with response



(* unstakeMvk entrypoint *)
function unstakeMvk(const unstakeAmount : nat ; var s : treasuryStorageType) : return is 
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUnstakeMvk", s.lambdaLedger);

    // init treasury lambda action
    const treasuryLambdaAction : treasuryLambdaActionType = LambdaUnstakeMvk(unstakeAmount);

    // init response
    const response : return = unpackLambda(lambdaBytes, treasuryLambdaAction, s);  

} with response

// ------------------------------------------------------------------------------
// Treasury Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Lambda Entrypoints Begin
// ------------------------------------------------------------------------------

(* setLambda entrypoint *)
function setLambda(const setLambdaParams : setLambdaType; var s : treasuryStorageType) : return is
block{
    
    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 
    
    // assign params to constants for better code readability
    const lambdaName    = setLambdaParams.name;
    const lambdaBytes   = setLambdaParams.func_bytes;
    s.lambdaLedger[lambdaName] := lambdaBytes;

} with (noOperations, s)

// ------------------------------------------------------------------------------
// Lambda Entrypoints End
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
//
// Entrypoints End
//
// ------------------------------------------------------------------------------