// ------------------------------------------------------------------------------
//
// Entrypoints Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Housekeeping Entrypoints Begin
// ------------------------------------------------------------------------------

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



(*  setGovernance entrypoint *)
function setGovernance(const newGovernanceAddress : address; var s : marketplaceStorageType) : return is
block {
    
    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetGovernance", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaSetGovernance(newGovernanceAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);

} with response



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



(*  removeCurrency entrypoint *)
function removeCurrency(const removeCurrencyParams : removeCurrencyActionType; var s : marketplaceStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaRemoveCurrency", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaRemoveCurrency(removeurrencyParams);

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



(*  removelist entrypoint *)
function removeListing(const removeListingParams : removeListingActionType; var s : marketplaceStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaRemovelisting", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaRemoveListing(removeListingParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);  

} with response



(*  purchase entrypoint *)
function purchase(const purchaseParams : nat; var s : marketplaceStorageType) : return is
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
function acceptOffer(const acceptOfferParams : nat; var s : marketplaceStorageType) : return is
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
    
    verifySenderIsAdmin(s.admin); // verify that sender is admin 
    
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