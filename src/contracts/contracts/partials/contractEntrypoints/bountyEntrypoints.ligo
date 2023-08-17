// ------------------------------------------------------------------------------
//
// Entrypoints Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Admin Entrypoints Begin
// ------------------------------------------------------------------------------

(*  setSuperAdmin entrypoint *)
function setSuperAdmin(const newAdminAddress : address; var s : bountyStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetSuperAdmin", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaSetSuperAdmin(newAdminAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);  
    
} with response



(*  claimSuperAdmin entrypoint *)
function claimSuperAdmin(var s : bountyStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaClaimSuperAdmin", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaClaimSuperAdmin(unit);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);  
    
} with response



(*  setAdmin entrypoint *)
function setAdmin(const newAdminAddress : address; var s : bountyStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetAdmin", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaSetAdmin(newAdminAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);  
    
} with response


(*  removeAdmin entrypoint *)
function removeAdmin(const adminAddress : address; var s : bountyStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaRemoveAdmin", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaRemoveAdmin(adminAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);  
    
} with response

// ------------------------------------------------------------------------------
// Admin Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Housekeping Entrypoints Begin
// ------------------------------------------------------------------------------

(*  updateMetadata entrypoint: update the metadata at a given key *)
function updateMetadata(const updateMetadataParams : updateMetadataType; var s : bountyStorageType) : return is
block {
    
    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateMetadata", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaUpdateMetadata(updateMetadataParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);  

} with response



(* updateConfig entrypoint *)
function updateConfig(const updateConfigParams : bountyUpdateConfigParamsType; var s : bountyStorageType) : return is 
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateConfig", s.lambdaLedger);

    // init delegation lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaUpdateConfig(updateConfigParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);

} with response



(*  updateWhitelistContracts entrypoint *)
function updateWhitelistContracts(const updateWhitelistContractsParams : updateWhitelistContractsType; var s : bountyStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateWhitelistContracts", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaUpdateWhitelistContracts(updateWhitelistContractsParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);  

} with response



(*  updateGeneralContracts entrypoint *)
function updateGeneralContracts(const updateGeneralContractsParams : updateGeneralContractsType; var s : bountyStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateGeneralContracts", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaUpdateGeneralContracts(updateGeneralContractsParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);  

} with response



(*  mistakenTransfer entrypoint *)
function mistakenTransfer(const destinationParams : transferActionType; var s : bountyStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaMistakenTransfer", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaMistakenTransfer(destinationParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);  

} with response

// ------------------------------------------------------------------------------
// Housekeeping Entrypoints End
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Pause / Break Glass Entrypoints Begin
// ------------------------------------------------------------------------------

(*  pauseAll entrypoint *)
function pauseAll(var s : bountyStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaPauseAll", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaPauseAll(unit);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);  
    
} with response



(*  unpauseAll entrypoint *)
function unpauseAll(var s : bountyStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUnpauseAll", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaUnpauseAll(unit);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);  

} with response



(*  togglePauseEntrypoint entrypoint  *)
function togglePauseEntrypoint(const targetEntrypoint : bountyTogglePauseEntrypointType; const s : bountyStorageType) : return is
block{

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaTogglePauseEntrypoint", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaTogglePauseEntrypoint(targetEntrypoint);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);

} with response

// ------------------------------------------------------------------------------
// Pause / Break Glass Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Bounty Admin Entrypoints Begin
// ------------------------------------------------------------------------------

(*  setBountyCreator entrypoint *)
function setBountyCreator(const setBountyCreatorParams : setBountyCreatorActionType; var s : bountyStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetBountyCreator", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaSetBountyCreator(setBountyCreatorParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);  

} with response



(*  setBounty entrypoint *)
function setBounty(const setBountyParams : setBountyActionType; var s : bountyStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetBounty", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaSetBounty(setBountyParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);  

} with response



(*  togglePauseBounty entrypoint *)
function togglePauseBounty(const togglePauseBountyParams : togglePauseBountyActionType; var s : bountyStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaTogglePauseBounty", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaTogglePauseBounty(togglePauseBountyParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);  

} with response



(*  approveOrReject entrypoint *)
function approveOrReject(const approveOrRejectParams : approveOrRejectActionType; var s : bountyStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaApproveOrReject", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaApproveOrReject(approveOrRejectParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);  

} with response



(*  reviewBounty entrypoint *)
function reviewBounty(const reviewBountyParams : reviewBountyActionType; var s : bountyStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaReviewBounty", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaReviewBounty(reviewBountyParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);  

} with response



(*  sendBountyReward entrypoint *)
function sendBountyReward(const sendBountyRewardParams : sendBountyRewardActionType; var s : bountyStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSendBountyReward", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaSendBountyReward(sendBountyRewardParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);  

} with response

// ------------------------------------------------------------------------------
// Bounty Admin Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Bounty Entrypoints Begin
// ------------------------------------------------------------------------------

(*  applyForBounty entrypoint *)
function applyForBounty(const applyForBountyParams : applyForBountyActionType; var s : bountyStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaApplyForBounty", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaApplyForBounty(applyForBountyParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);  

} with response



(*  cancelApplication entrypoint *)
function cancelApplication(const cancelApplicationParams : cancelApplicationActionType; var s : bountyStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaCancelApplication", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaCancelApplication(cancelApplicationParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);  

} with response



(*  completeBounty entrypoint *)
function completeBounty(const completeBountyParams : completeBountyActionType; var s : bountyStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaCompleteBounty", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaCompleteBounty(completeBountyParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);  

} with response



(*  stopBounty entrypoint *)
function stopBounty(const stopBountyParams : stopBountyActionType; var s : bountyStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaStopBounty", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaStopBounty(stopBountyParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);  

} with response

// ------------------------------------------------------------------------------
// Bounty Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Lambda Entrypoints Begin
// ------------------------------------------------------------------------------

(* setLambda entrypoint *)
function setLambda(const setLambdaParams : setLambdaType; var s : bountyStorageType) : return is
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