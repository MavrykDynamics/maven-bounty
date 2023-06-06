// ------------------------------------------------------------------------------
//
// Entrypoints Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Housekeeping Entrypoints Begin
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Admin Entrypoints Begin
// ------------------------------------------------------------------------------

(*  setSuperAdmin entrypoint *)
function setSuperAdmin(const newAdminAddress : address; var s : launchpadStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetSuperAdmin", s.lambdaLedger);

    // init launchpad lambda action
    const launchpadLambdaAction : launchpadLambdaActionType = LambdaSetSuperAdmin(newAdminAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, launchpadLambdaAction, s);  
    
} with response



(*  claimSuperAdmin entrypoint *)
function claimSuperAdmin(var s : launchpadStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaClaimSuperAdmin", s.lambdaLedger);

    // init launchpad lambda action
    const launchpadLambdaAction : launchpadLambdaActionType = LambdaClaimSuperAdmin(unit);

    // init response
    const response : return = unpackLambda(lambdaBytes, launchpadLambdaAction, s);  
    
} with response



(*  setAdmin entrypoint *)
function setAdmin(const newAdminAddress : address; var s : launchpadStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetAdmin", s.lambdaLedger);

    // init launchpad lambda action
    const launchpadLambdaAction : launchpadLambdaActionType = LambdaSetAdmin(newAdminAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, launchpadLambdaAction, s);  
    
} with response


(*  removeAdmin entrypoint *)
function removeAdmin(const adminAddress : address; var s : launchpadStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaRemoveAdmin", s.lambdaLedger);

    // init launchpad lambda action
    const launchpadLambdaAction : launchpadLambdaActionType = LambdaRemoveAdmin(adminAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, launchpadLambdaAction, s);  
    
} with response

// ------------------------------------------------------------------------------
// Admin Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Housekeeping Entrypoints Begin
// ------------------------------------------------------------------------------

(*  updateMetadata entrypoint: update the metadata at a given key *)
function updateMetadata(const updateMetadataParams : updateMetadataType; var s : launchpadStorageType) : return is
block {
    
    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateMetadata", s.lambdaLedger);

    // init launchpad lambda action
    const launchpadLambdaAction : launchpadLambdaActionType = LambdaUpdateMetadata(updateMetadataParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, launchpadLambdaAction, s);  

} with response



(* updateConfig entrypoint *)
function updateConfig(const updateConfigParams : launchpadUpdateConfigParamsType; var s : launchpadStorageType) : return is 
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateConfig", s.lambdaLedger);

    // init delegation lambda action
    const launchpadLambdaAction : launchpadLambdaActionType = LambdaUpdateConfig(updateConfigParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, launchpadLambdaAction, s);

} with response



(*  updateWhitelistContracts entrypoint *)
function updateWhitelistContracts(const updateWhitelistContractsParams : updateWhitelistContractsType; var s : launchpadStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateWhitelistContracts", s.lambdaLedger);

    // init launchpad lambda action
    const launchpadLambdaAction : launchpadLambdaActionType = LambdaUpdateWhitelistContracts(updateWhitelistContractsParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, launchpadLambdaAction, s);  

} with response



(*  updateGeneralContracts entrypoint *)
function updateGeneralContracts(const updateGeneralContractsParams : updateGeneralContractsType; var s : launchpadStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateGeneralContracts", s.lambdaLedger);

    // init launchpad lambda action
    const launchpadLambdaAction : launchpadLambdaActionType = LambdaUpdateGeneralContracts(updateGeneralContractsParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, launchpadLambdaAction, s);  

} with response



(*  mistakenTransfer entrypoint *)
function mistakenTransfer(const destinationParams : transferActionType; var s : launchpadStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaMistakenTransfer", s.lambdaLedger);

    // init launchpad lambda action
    const launchpadLambdaAction : launchpadLambdaActionType = LambdaMistakenTransfer(destinationParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, launchpadLambdaAction, s);  

} with response

// ------------------------------------------------------------------------------
// Housekeeping Entrypoints End
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Pause / Break Glass Entrypoints Begin
// ------------------------------------------------------------------------------

(*  pauseAll entrypoint *)
function pauseAll(var s : launchpadStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaPauseAll", s.lambdaLedger);

    // init launchpad lambda action
    const launchpadLambdaAction : launchpadLambdaActionType = LambdaPauseAll(unit);

    // init response
    const response : return = unpackLambda(lambdaBytes, launchpadLambdaAction, s);  
    
} with response



(*  unpauseAll entrypoint *)
function unpauseAll(var s : launchpadStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUnpauseAll", s.lambdaLedger);

    // init launchpad lambda action
    const launchpadLambdaAction : launchpadLambdaActionType = LambdaUnpauseAll(unit);

    // init response
    const response : return = unpackLambda(lambdaBytes, launchpadLambdaAction, s);  

} with response



(*  togglePauseEntrypoint entrypoint  *)
function togglePauseEntrypoint(const targetEntrypoint : launchpadTogglePauseEntrypointType; const s : launchpadStorageType) : return is
block{

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaTogglePauseEntrypoint", s.lambdaLedger);

    // init launchpad lambda action
    const launchpadLambdaAction : launchpadLambdaActionType = LambdaTogglePauseEntrypoint(targetEntrypoint);

    // init response
    const response : return = unpackLambda(lambdaBytes, launchpadLambdaAction, s);

} with response

// ------------------------------------------------------------------------------
// Pause / Break Glass Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Launchpad Entrypoints Begin
// ------------------------------------------------------------------------------

(*  createTokenSale entrypoint *)
function createTokenSale(const createTokenSaleParams : createTokenSaleActionType; var s : launchpadStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaCreateTokenSale", s.lambdaLedger);

    // init launchpad lambda action
    const launchpadLambdaAction : launchpadLambdaActionType = LambdaCreateTokenSale(createTokenSaleParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, launchpadLambdaAction, s);  

} with response



(*  startSale entrypoint *)
function startSale(const startSaleParams : nat; var s : launchpadStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaStartSale", s.lambdaLedger);

    // init launchpad lambda action
    const launchpadLambdaAction : launchpadLambdaActionType = LambdaStartSale(startSaleParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, launchpadLambdaAction, s);  

} with response



(*  setSaleWhitelist entrypoint *)
function setSaleWhitelist(const setSaleWhitelistParams : setSaleWhitelistActionType; var s : launchpadStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetSaleWhitelist", s.lambdaLedger);

    // init launchpad lambda action
    const launchpadLambdaAction : launchpadLambdaActionType = LambdaSetSaleWhitelist(setSaleWhitelistParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, launchpadLambdaAction, s);  

} with response



(*  editSale entrypoint *)
function editSale(const editSaleParams : unit; var s : launchpadStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaEditSale", s.lambdaLedger);

    // init launchpad lambda action
    const launchpadLambdaAction : launchpadLambdaActionType = LambdaEditSale(editSaleParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, launchpadLambdaAction, s);  

} with response



(*  pauseSale entrypoint *)
function pauseSale(const pauseSaleParams : nat; var s : launchpadStorageType) : return is
block{
    
    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaPauseSale", s.lambdaLedger);

    // init launchpad lambda action
    const launchpadLambdaAction : launchpadLambdaActionType = LambdaPauseSale(pauseSaleParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, launchpadLambdaAction, s);  

} with response



(*  unpauseSale entrypoint *)
function unpauseSale(const unpauseSaleParams : nat; var s : launchpadStorageType) : return is
block{
    
    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUnpauseSale", s.lambdaLedger);

    // init launchpad lambda action
    const launchpadLambdaAction : launchpadLambdaActionType = LambdaUnpauseSale(unpauseSaleParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, launchpadLambdaAction, s);  

} with response



(*  closeSale entrypoint *)
function closeSale(const closeSaleParams : nat; var s : launchpadStorageType) : return is
block{
    
    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaCloseSale", s.lambdaLedger);

    // init launchpad lambda action
    const launchpadLambdaAction : launchpadLambdaActionType = LambdaCloseSale(closeSaleParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, launchpadLambdaAction, s);  

} with response



(*  distributeTokens entrypoint *)
function distributeTokens(const distributeTokensParams : nat; var s : launchpadStorageType) : return is
block{
    
    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaDistributeTokens", s.lambdaLedger);

    // init launchpad lambda action
    const launchpadLambdaAction : launchpadLambdaActionType = LambdaDistributeTokens(distributeTokensParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, launchpadLambdaAction, s);  

} with response

// ------------------------------------------------------------------------------
// Launchpad Entrypoints End
// ------------------------------------------------------------------------------



(*  purchase entrypoint *)
function purchase(const purchaseParams : purchaseActionType; var s : launchpadStorageType) : return is
block{
    
    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaPurchase", s.lambdaLedger);

    // init launchpad lambda action
    const launchpadLambdaAction : launchpadLambdaActionType = LambdaPurchase(purchaseParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, launchpadLambdaAction, s);  

} with response



// ------------------------------------------------------------------------------
// Lambda Entrypoints Begin
// ------------------------------------------------------------------------------

(* setLambda entrypoint *)
function setLambda(const setLambdaParams : setLambdaType; var s : launchpadStorageType) : return is
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