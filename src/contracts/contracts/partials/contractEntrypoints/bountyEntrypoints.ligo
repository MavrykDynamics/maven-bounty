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
// Group Entrypoints Begin
// ------------------------------------------------------------------------------

(*  formGroup entrypoint *)
function formGroup(var s : bountyStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaFormGroup", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaFormGroup(unit);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);  

} with response



(*  addGroupMember entrypoint *)
function addGroupMember(const addGroupMemberParams : addGroupMemberActionType; var s : bountyStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaAddGroupMember", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaAddGroupMember(addGroupMemberParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);  

} with response



(*  confirmGroupMembership entrypoint *)
function confirmGroupMembership(const confirmGroupMembershipParams : confirmGroupMembershipActionType; var s : bountyStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaConfirmGroupMembership", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaConfirmGroupMembership(confirmGroupMembershipParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);  

} with response



(*  leaveGroup entrypoint *)
function leaveGroup(const leaveGroupParams : leaveGroupActionType; var s : bountyStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaLeaveGroup", s.lambdaLedger);

    // init bounty lambda action
    const bountyLambdaAction : bountyLambdaActionType = LambdaLeaveGroup(leaveGroupParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, bountyLambdaAction, s);  

} with response

// ------------------------------------------------------------------------------
// Group Entrypoints End
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