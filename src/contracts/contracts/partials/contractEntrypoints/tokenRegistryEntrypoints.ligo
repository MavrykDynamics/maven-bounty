// ------------------------------------------------------------------------------
//
// Entrypoints Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Admin Entrypoints Begin
// ------------------------------------------------------------------------------

(*  setSuperAdmin entrypoint *)
function setSuperAdmin(const newAdminAddress : address; var s : tokenRegistryStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetSuperAdmin", s.lambdaLedger);

    // init tokenRegistry lambda action
    const tokenRegistryLambdaAction : tokenRegistryLambdaActionType = LambdaSetSuperAdmin(newAdminAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, tokenRegistryLambdaAction, s);  
    
} with response



(*  claimSuperAdmin entrypoint *)
function claimSuperAdmin(var s : tokenRegistryStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaClaimSuperAdmin", s.lambdaLedger);

    // init tokenRegistry lambda action
    const tokenRegistryLambdaAction : tokenRegistryLambdaActionType = LambdaClaimSuperAdmin(unit);

    // init response
    const response : return = unpackLambda(lambdaBytes, tokenRegistryLambdaAction, s);  
    
} with response



(*  setAdmin entrypoint *)
function setAdmin(const newAdminAddress : address; var s : tokenRegistryStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetAdmin", s.lambdaLedger);

    // init tokenRegistry lambda action
    const tokenRegistryLambdaAction : tokenRegistryLambdaActionType = LambdaSetAdmin(newAdminAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, tokenRegistryLambdaAction, s);  
    
} with response



(*  removeAdmin entrypoint *)
function removeAdmin(const adminAddress : address; var s : tokenRegistryStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaRemoveAdmin", s.lambdaLedger);

    // init tokenRegistry lambda action
    const tokenRegistryLambdaAction : tokenRegistryLambdaActionType = LambdaRemoveAdmin(adminAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, tokenRegistryLambdaAction, s);  
    
} with response

// ------------------------------------------------------------------------------
// Admin Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Housekeeping Entrypoints Begin
// ------------------------------------------------------------------------------


(*  updateMetadata entrypoint: update the metadata at a given key *)
function updateMetadata(const updateMetadataParams : updateMetadataType; var s : tokenRegistryStorageType) : return is
block {
    
    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateMetadata", s.lambdaLedger);

    // init tokenRegistry lambda action
    const tokenRegistryLambdaAction : tokenRegistryLambdaActionType = LambdaUpdateMetadata(updateMetadataParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, tokenRegistryLambdaAction, s);  

} with response



(*  updateWhitelistContracts entrypoint *)
function updateWhitelistContracts(const updateWhitelistContractsParams : updateWhitelistContractsType; var s : tokenRegistryStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateWhitelistContracts", s.lambdaLedger);

    // init tokenRegistry lambda action
    const tokenRegistryLambdaAction : tokenRegistryLambdaActionType = LambdaUpdateWhitelistContracts(updateWhitelistContractsParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, tokenRegistryLambdaAction, s);  

} with response



(*  updateGeneralContracts entrypoint *)
function updateGeneralContracts(const updateGeneralContractsParams : updateGeneralContractsType; var s : tokenRegistryStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateGeneralContracts", s.lambdaLedger);

    // init tokenRegistry lambda action
    const tokenRegistryLambdaAction : tokenRegistryLambdaActionType = LambdaUpdateGeneralContracts(updateGeneralContractsParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, tokenRegistryLambdaAction, s);  

} with response



(*  mistakenTransfer entrypoint *)
function mistakenTransfer(const destinationParams : transferActionType; var s : tokenRegistryStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaMistakenTransfer", s.lambdaLedger);

    // init tokenRegistry lambda action
    const tokenRegistryLambdaAction : tokenRegistryLambdaActionType = LambdaMistakenTransfer(destinationParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, tokenRegistryLambdaAction, s);  

} with response

// ------------------------------------------------------------------------------
// Housekeeping Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Pause / Break Glass Entrypoints Begin
// ------------------------------------------------------------------------------

(*  pauseAll entrypoint *)
function pauseAll(var s : tokenRegistryStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaPauseAll", s.lambdaLedger);

    // init tokenRegistry lambda action
    const tokenRegistryLambdaAction : tokenRegistryLambdaActionType = LambdaPauseAll(unit);

    // init response
    const response : return = unpackLambda(lambdaBytes, tokenRegistryLambdaAction, s);  
    
} with response



(*  unpauseAll entrypoint *)
function unpauseAll(var s : tokenRegistryStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUnpauseAll", s.lambdaLedger);

    // init tokenRegistry lambda action
    const tokenRegistryLambdaAction : tokenRegistryLambdaActionType = LambdaUnpauseAll(unit);

    // init response
    const response : return = unpackLambda(lambdaBytes, tokenRegistryLambdaAction, s);  

} with response



(*  togglePauseEntrypoint entrypoint  *)
function togglePauseEntrypoint(const targetEntrypoint : tokenRegistryTogglePauseEntrypointType; const s : tokenRegistryStorageType) : return is
block{

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaTogglePauseEntrypoint", s.lambdaLedger);

    // init tokenRegistry lambda action
    const tokenRegistryLambdaAction : tokenRegistryLambdaActionType = LambdaTogglePauseEntrypoint(targetEntrypoint);

    // init response
    const response : return = unpackLambda(lambdaBytes, tokenRegistryLambdaAction, s);

} with response

// ------------------------------------------------------------------------------
// Pause / Break Glass Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Token Registry Entrypoints Begin
// ------------------------------------------------------------------------------

(*  setToken entrypoint *)
function setToken(const setTokenParams : setTokenActionType; var s : tokenRegistryStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetToken", s.lambdaLedger);

    // init tokenRegistry lambda action
    const tokenRegistryLambdaAction : tokenRegistryLambdaActionType = LambdaSetToken(setTokenParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, tokenRegistryLambdaAction, s);  

} with response



(*  removeToken entrypoint *)
function removeToken(const removeTokenParams : removeTokenActionType; var s : tokenRegistryStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaRemoveToken", s.lambdaLedger);

    // init tokenRegistry lambda action
    const tokenRegistryLambdaAction : tokenRegistryLambdaActionType = LambdaRemoveToken(removeTokenParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, tokenRegistryLambdaAction, s);  

} with response

// ------------------------------------------------------------------------------
// Token Registry Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Lambda Entrypoints Begin
// ------------------------------------------------------------------------------

(* setLambda entrypoint *)
function setLambda(const setLambdaParams : setLambdaType; var s : tokenRegistryStorageType) : return is
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