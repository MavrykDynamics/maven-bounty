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
// Marketplace Entrypoints Begin
// ------------------------------------------------------------------------------

(*  list entrypoint *)
function list(const listParams : nat; var s : marketplaceStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaList", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaList(listParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);  

} with response



(*  delist entrypoint *)
function delist(const delistParams : nat; var s : marketplaceStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaDelist", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaDelist(delistParams);

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
function offer(const offerParams : nat; var s : marketplaceStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaOffer", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaOffer(offerParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);  

} with response



(*  acceptOffer entrypoint *)
function acceptOffer(const acceptOfferParams : address; var s : marketplaceStorageType) : return is
block{
    
    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaAcceptOffer", s.lambdaLedger);

    // init marketplace lambda action
    const marketplaceLambdaAction : marketplaceLambdaActionType = LambdaAcceptOffer(acceptOfferParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, marketplaceLambdaAction, s);  

} with response



(*  removeOffer entrypoint *)
function removeOffer(const removeOfferParams : address; var s : marketplaceStorageType) : return is
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