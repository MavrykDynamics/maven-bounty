// ------------------------------------------------------------------------------
//
// Entrypoints Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Admin Entrypoints Begin
// ------------------------------------------------------------------------------

(*  setSuperAdmin entrypoint *)
function setSuperAdmin(const newAdminAddress : address; var s : marketplaceStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetSuperAdmin", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaSetSuperAdmin(newAdminAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);  
    
} with response



(*  claimSuperAdmin entrypoint *)
function claimSuperAdmin(var s : marketplaceStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaClaimSuperAdmin", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaClaimSuperAdmin(unit);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);  
    
} with response



(*  setAdmin entrypoint *)
function setAdmin(const newAdminAddress : address; var s : marketplaceStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetAdmin", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaSetAdmin(newAdminAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);  
    
} with response


(*  removeAdmin entrypoint *)
function removeAdmin(const adminAddress : address; var s : marketplaceStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaRemoveAdmin", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaRemoveAdmin(adminAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);  
    
} with response

// ------------------------------------------------------------------------------
// Admin Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Housekeping Entrypoints Begin
// ------------------------------------------------------------------------------

(*  updateMetadata entrypoint: update the metadata at a given key *)
function updateMetadata(const updateMetadataParams : updateMetadataType; var s : marketplaceStorageType) : return is
block {
    
    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateMetadata", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaUpdateMetadata(updateMetadataParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);  

} with response



(* updateConfig entrypoint *)
function updateConfig(const updateConfigParams : marketplaceUpdateConfigParamsType; var s : marketplaceStorageType) : return is 
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateConfig", s.lambdaLedger);

    // init delegation lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaUpdateConfig(updateConfigParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);

} with response



(*  updateWhitelistContracts entrypoint *)
function updateWhitelistContracts(const updateWhitelistContractsParams : updateWhitelistContractsType; var s : marketplaceStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateWhitelistContracts", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaUpdateWhitelistContracts(updateWhitelistContractsParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);  

} with response



(*  updateGeneralContracts entrypoint *)
function updateGeneralContracts(const updateGeneralContractsParams : updateGeneralContractsType; var s : marketplaceStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateGeneralContracts", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaUpdateGeneralContracts(updateGeneralContractsParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);  

} with response



(*  mistakenTransfer entrypoint *)
function mistakenTransfer(const destinationParams : transferActionType; var s : marketplaceStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaMistakenTransfer", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaMistakenTransfer(destinationParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);  

} with response

// ------------------------------------------------------------------------------
// Housekeeping Entrypoints End
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Pause / Break Glass Entrypoints Begin
// ------------------------------------------------------------------------------

(*  pauseAll entrypoint *)
function pauseAll(var s : marketplaceStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaPauseAll", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaPauseAll(unit);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);  
    
} with response



(*  unpauseAll entrypoint *)
function unpauseAll(var s : marketplaceStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUnpauseAll", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaUnpauseAll(unit);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);  

} with response



(*  togglePauseEntrypoint entrypoint  *)
function togglePauseEntrypoint(const targetEntrypoint : marketplaceTogglePauseEntrypointType; const s : marketplaceStorageType) : return is
block{

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaTogglePauseEntrypoint", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaTogglePauseEntrypoint(targetEntrypoint);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);

} with response

// ------------------------------------------------------------------------------
// Pause / Break Glass Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Marketplace Admin Entrypoints Begin
// ------------------------------------------------------------------------------

(*  setCurrency entrypoint *)
function setCurrency(const setCurrencyParams : setCurrencyActionType; var s : marketplaceStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetCurrency", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaSetCurrency(setCurrencyParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);  

} with response

// ------------------------------------------------------------------------------
// Marketplace Admin Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Marketplace Entrypoints Begin
// ------------------------------------------------------------------------------

(*  createListing entrypoint *)
function createListing(const createListingParams : createListingActionType; var s : marketplaceStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaCreateListing", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaCreateListing(createListingParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);  

} with response



(*  editListing entrypoint *)
function editListing(const editListingParams : editListingActionType; var s : marketplaceStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaEditListing", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaEditListing(editListingParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);  

} with response



(*  removelist entrypoint *)
function removeListing(const removeListingParams : removeListingActionType; var s : marketplaceStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaRemoveListing", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaRemoveListing(removeListingParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);  

} with response



(*  purchase entrypoint *)
function purchase(const purchaseParams : purchaseActionType; var s : marketplaceStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaPurchase", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaPurchase(purchaseParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);  

} with response



(*  offer entrypoint *)
function offer(const offerParams : offerActionType; var s : marketplaceStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaOffer", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaOffer(offerParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);  

} with response



(*  acceptOffer entrypoint *)
function acceptOffer(const acceptOfferParams : acceptOfferActionType; var s : marketplaceStorageType) : return is
block{
    
    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaAcceptOffer", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaAcceptOffer(acceptOfferParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);  

} with response



(*  removeOffer entrypoint *)
function removeOffer(const removeOfferParams : removeOfferActionType; var s : marketplaceStorageType) : return is
block{
    
    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaRemoveOffer", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaRemoveOffer(removeOfferParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);  

} with response

// ------------------------------------------------------------------------------
// Marketplace Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Lambda Entrypoints Begin
// ------------------------------------------------------------------------------

(* setLambda entrypoint *)
function setLambda(const setLambdaParams : setLambdaType; var s : marketplaceStorageType) : return is
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