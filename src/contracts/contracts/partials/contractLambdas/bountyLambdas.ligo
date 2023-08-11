// ------------------------------------------------------------------------------
//
// Bounty Lambdas Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Admin Lambdas Begin
// ------------------------------------------------------------------------------

(*  setSuperAdmin lambda *)
function lambdaSetSuperAdmin(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 
    
    case bountyLambdaAction of [
        |   LambdaSetSuperAdmin(newAdminAddress) -> {
                s.newSuperAdmin := Some(newAdminAddress);
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  claimSuperAdmin lambda *)
function lambdaClaimSuperAdmin(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 
    
    case bountyLambdaAction of [
        |   LambdaClaimSuperAdmin(_params) -> {
                
                // get sender and new super admin address 
                const sender : address = Tezos.get_sender();
                const newSuperAdmin : address = case s.newSuperAdmin of [
                        Some(_address) -> _address
                    |   None           -> failwith(error_NO_NEW_SUPER_ADMIN_FOUND)
                ];

                // check if sender is not new super admin 
                if sender =/= newSuperAdmin then failwith(error_SENDER_IS_NOT_NEW_SUPER_ADMIN) else skip;
                s.superAdmin := newSuperAdmin;

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  setAdmin lambda *)
function lambdaSetAdmin(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 
    
    case bountyLambdaAction of [
        |   LambdaSetAdmin(newAdminAddress) -> {
                s.admins := Set.add(newAdminAddress, s.admins);
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  removeAdmin lambda *)
function lambdaRemoveAdmin(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 
    
    case bountyLambdaAction of [
        |   LambdaRemoveAdmin(adminAddress) -> {
                s.admins := Set.remove(adminAddress, s.admins);
            }
        |   _ -> skip
    ];

} with (noOperations, s)

// ------------------------------------------------------------------------------
// Admin Lambdas End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Housekeeping Lambdas Begin
// ------------------------------------------------------------------------------

(*  updateMetadata lambda - update the metadata at a given key *)
function lambdaUpdateMetadata(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {
    
    // verify that sender is admin (i.e. Governance Proxy Contract address)
    verifySenderIsAdmin(s.admins); 

    case bountyLambdaAction of [
        |   LambdaUpdateMetadata(updateMetadataParams) -> {
                
                const metadataKey   : string = updateMetadataParams.metadataKey;
                const metadataHash  : bytes  = updateMetadataParams.metadataHash;
                
                s.metadata[metadataKey] := metadataHash;
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* updateConfig lambda *)
function lambdaUpdateConfig(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is 
block {

    // verify that sender is admin (i.e. Governance Proxy Contract address)
    verifySenderIsAdmin(s.admins); 

    case bountyLambdaAction of [
        |   LambdaUpdateConfig(updateConfigParams) -> {
                
                const updateConfigAction    : marketplaceUpdateConfigActionType   = updateConfigParams.updateConfigAction;
                const updateConfigNewValue  : marketplaceUpdateConfigNewValueType = updateConfigParams.updateConfigNewValue;

                case updateConfigAction of [
                    |   ConfigMinOfferAmount (_v)  -> s.config.minOfferAmount         := updateConfigNewValue
                    |   ConfigRoyalty (_v)         -> s.config.royalty                := updateConfigNewValue
                    |   ConfigMarketplaceFee (_v)  -> s.config.marketplaceFee         := updateConfigNewValue
                ];
            }
        |   _ -> skip
    ];
  
} with (noOperations, s)



(*  updateWhitelistContracts lambda *)
function lambdaUpdateWhitelistContracts(const bountyLambdaAction : bountyLambdaActionType; var s: bountyStorageType) : return is
block {

    // verify that sender is admin
    verifySenderIsAdmin(s.admins); 

    case bountyLambdaAction of [
        |   LambdaUpdateWhitelistContracts(updateWhitelistContractsParams) -> {
                s.whitelistContracts := updateWhitelistContractsMap(updateWhitelistContractsParams, s.whitelistContracts);
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  updateGeneralContracts lambda *)
function lambdaUpdateGeneralContracts(const bountyLambdaAction : bountyLambdaActionType; var s: bountyStorageType) : return is
block {

    // verify that sender is admin (i.e. Governance Proxy Contract address)
    verifySenderIsAdmin(s.admins); 

    case bountyLambdaAction of [
        |   LambdaUpdateGeneralContracts(updateGeneralContractsParams) -> {
                s.generalContracts := updateGeneralContractsMap(updateGeneralContractsParams, s.generalContracts);
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  mistaken lambda *)
function lambdaMistakenTransfer(const bountyLambdaAction : bountyLambdaActionType; var s: bountyStorageType) : return is
block {

    var operations : list(operation) := nil;

    case bountyLambdaAction of [
        |   LambdaMistakenTransfer(destinationParams) -> {

                verifySenderIsAdmin(s.admins); // check that sender is admin 

                // Create transfer operations (transferOperationFold in transferHelpers)
                operations := List.fold_right(transferOperationFold, destinationParams, operations)
                
            }
        |   _ -> skip
    ];

} with (operations, s)

// ------------------------------------------------------------------------------
// Housekeeping Lambdas End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Pause / Break Glass Lambdas Begin
// ------------------------------------------------------------------------------

(*  pauseAll lambda *)
function lambdaPauseAll(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 

    case bountyLambdaAction of [
        |   LambdaPauseAll(_parameters) -> {
              
                // set all pause configs to True
                s := pauseAllBountyEntrypoints(s);
              
            }
        |   _ -> skip
    ];  

} with (noOperations, s)



(*  unpauseAll lambda *)
function lambdaUnpauseAll(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 

    case bountyLambdaAction of [
        |   LambdaUnpauseAll(_parameters) -> {
                
                // set all pause configs to False
                s := unpauseAllBountyEntrypoints(s);
              
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  togglePauseEntrypoint lambda *)
function lambdaTogglePauseEntrypoint(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    verifyNoAmountSent(Unit);     // entrypoint should not receive any tez amount  
    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 

    case bountyLambdaAction of [
        |   LambdaTogglePauseEntrypoint(params) -> {

                case params.targetEntrypoint of [
                        SetBounty (_v)              -> s.breakGlassConfig.setBountyIsPaused             := _v
                    |   TogglePause (_v)            -> s.breakGlassConfig.togglePauseIsPaused           := _v
                    |   ApproveOrReject (_v)        -> s.breakGlassConfig.approveOrRejectIsPaused       := _v
                    |   ReviewBounty (_v)           -> s.breakGlassConfig.reviewBountyIsPaused          := _v
                    |   SendBountyReward (_v)       -> s.breakGlassConfig.sendBountyRewardIsPaused      := _v
                    |   ApplyForBounty (_v)         -> s.breakGlassConfig.applyForBountyIsPaused        := _v
                    |   CancelApplication (_v)      -> s.breakGlassConfig.cancelApplicationIsPaused     := _v
                    |   CompleteBounty (_v)         -> s.breakGlassConfig.completeBountyIsPaused        := _v
                    |   StopBounty (_v)             -> s.breakGlassConfig.stopBountyIsPaused            := _v
                ]
                
            }
        |   _ -> skip
    ];

} with (noOperations, s)

// ------------------------------------------------------------------------------
// Pause / Break Glass Lambdas End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Bounty Admin Lambdas Begin
// ------------------------------------------------------------------------------

(*  setBountyCreator lambda *)
function lambdaSetBountyCreator(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    case bountyLambdaAction of [
        |   LambdaSetBountyCreator(setBountyCreatorParams) -> {

                verifySenderIsAdmin(s.admins); // check that sender is admin 
                s.bountyCreators := updateWhitelistContractsMap(setBountyCreatorParams, s.bountyCreators);

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  setBounty lambda *)
function lambdaSetBounty(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.setBountyIsPaused, error_SET_BOUNTY_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED);

    var operations : list(operation) := nil;

    case bountyLambdaAction of [
        |   LambdaSetBounty(setBountyParams) -> {

                verifySenderIsAdminOrBountyCreator(s);

                case setBountyParams of [
                    |   CreateBounty(createBountyParams) -> {

                            const bountyContractAddress  : address          = Tezos.get_self_address();
                            const sender                 : address          = Tezos.get_sender();

                            const bountyId               : nat              = s.nextBountyId;
                            const bountyRecord           : bountyRecordType = createNewBountyRecord(createBountyParams);

                            // transfer rewards from creator of bounty to contract
                            const maxApprovedApplicants : nat = createBountyParams.maxApprovedApplicants;
                            for _tokenName -> reward in map createBountyParams.totalRewards block {
                                const totalRewardAmount : nat = maxApprovedApplicants * reward.rewardAmount;
                                operations := case reward.rewardTokenType of [
                                        Tez                     -> transferTez((Tezos.get_contract_with_error(bountyContractAddress, "Error. Contract not found at given address") : contract(unit)), totalRewardAmount * 1mutez) # operations
                                    |   Fa12(fa12TokenAddress)  -> transferFa12Token(sender, bountyContractAddress, totalRewardAmount, fa12TokenAddress) # operations
                                    |   Fa2(fa2Token)           -> transferFa2Token(sender, bountyContractAddress, totalRewardAmount, fa2Token.tokenId, fa2Token.tokenContractAddress) # operations
                                ];
                            };

                            // update storage
                            s.bountyLedger[bountyId]   := bountyRecord;
                            s.nextBountyId             := bountyId + 1n; 

                        } 
                    |   UpdateBounty(updateBountyParams) -> {

                            skip

                        }
                    |   UpdateWhitelist(updateBountyWhitelistParams) -> {

                            const bountyId    : nat               = updateBountyWhitelistParams.bountyId;
                            const addresses   : set(address)      = updateBountyWhitelistParams.addresses;
                            const updateType  : updateType        = updateBountyWhitelistParams.updateType;

                            // get bounty record
                            var bountyRecord : bountyRecordType  := getBountyRecord(bountyId, s);

                            // permissions check
                            verifySenderIsAdminOrBountyCreator(bountyRecord.creator, bountyRecord.whitelisted);

                            // update whitelisted addresses
                            case updateType of [
                                    Update(_) -> block {
                                        for address in set addresses block {
                                            bountyRecord.whitelisted := Set.add(address, bountyRecord.whitelisted);
                                        };
                                    }
                                |   Remove(_) -> block {
                                        for address in set addresses block {
                                            bountyRecord.whitelisted := Set.remove(address, bountyRecord.whitelisted);
                                        };
                                    }
                            ];

                            // update storage
                            s.bountyLedger[bountyId] := bountyRecord;

                        }   
                    |   UpdateMilestone(updateMilestoneParams) -> {

                            const bountyId      : nat               = updateMilestoneParams.bountyId;
                            const milestoneId   : nat               = updateMilestoneParams.milestoneId;
                            
                            // get bounty record
                            var bountyRecord    : bountyRecordType  = getBountyRecord(bountyId, s);

                            // permissions check
                            verifySenderIsAdminOrBountyCreator(bountyRecord.creator, bountyRecord.whitelisted);


                        }
                ];

            }
        |   _ -> skip
    ];

} with (operations, s)



(*  togglePauseBounty lambda *)
function lambdaTogglePauseBounty(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.togglePauseBountyIsPaused, error_TOGGLE_PAUSE_BOUNTY_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED);

    case bountyLambdaAction of [
        |   LambdaTogglePauseBounty(bountyId) -> {

                // get bounty record
                var bountyRecord : bountyRecordType := getBountyRecord(bountyId, s);

                // permissions check
                verifySenderIsAdminOrBountyCreator(bountyRecord.creator, bountyRecord.whitelisted);

                if bountyRecord.isPaused = True then bountyRecord.isPaused := False else bountyRecord.isPaused := True;

                // update storage
                s.bountyLedger[bountyId] := bountyRecord;

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  approveOrReject lambda *)
function lambdaApproveOrReject(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.approveOrRejectIsPaused, error_APPROVE_OR_REJECT_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED);

    case bountyLambdaAction of [
        |   LambdaApproveOrReject(approveOrRejectParams) -> {

                // get bounty record
                var bountyRecord : bountyRecordType := getBountyRecord(bountyId, s);

                // permissions check
                verifySenderIsAdminOrBountyCreator(bountyRecord.creator, bountyRecord.whitelisted);


            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  reviewBounty lambda *)
function lambdaReviewBounty(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.reviewBountyIsPaused, error_REVIEW_BOUNTY_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED);

    case bountyLambdaAction of [
        |   LambdaReviewBounty(reviewBountyParams) -> {

                // get bounty record
                var bountyRecord : bountyRecordType := getBountyRecord(bountyId, s);

                // permissions check
                verifySenderIsAdminOrBountyCreator(bountyRecord.creator, bountyRecord.whitelisted);


            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  sendBountyReward lambda *)
function lambdaSendBountyReward(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.sendBountyRewardIsPaused, error_SEND_BOUNTY_REWARD_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED);

    case bountyLambdaAction of [
        |   LambdaSendBountyReward(sendBountyRewardParams) -> {

                // get bounty record
                var bountyRecord : bountyRecordType := getBountyRecord(bountyId, s);

                // permissions check
                verifySenderIsAdminOrBountyCreator(bountyRecord.creator, bountyRecord.whitelisted);


            }
        |   _ -> skip
    ];

} with (noOperations, s)

// ------------------------------------------------------------------------------
// Bounty Admin Lambdas End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Bounty Lambdas Begin
// ------------------------------------------------------------------------------

(*  applyForBounty lambda *)
function lambdaApplyForBounty(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.applyForBountyIsPaused, error_APPLY_FOR_BOUNTY_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED);

    case bountyLambdaAction of [
        |   LambdaApplyForBounty(bountyId) -> {

                const sender : address = Tezos.get_sender();

                // get bounty and user record
                const bountyRecord : bountyRecordType = getBountyRecord(bountyId, s);
                var userRecord : userRecordType      := getUserRecord(sender, s);
                
                // ---------------------------------------------
                // verification checks
                // ---------------------------------------------

                verifyBountyIsActive(bountyRecord.status);

                verifyBountyIsNotPaused(bountyRecord.isPaused);

                verifyBountyHasSpaceForNewApplicants(bountyRecord.maxApprovedApplicants, bountyRecord.currentApprovedApplicants);
                
                verifyUserCanApplyForNewBounties(userRecord.currentApplicationCount, s.config.maxApplications);

                verifyUserHasSpaceForNewBounties(userRecord.activeBountyCount, s.config.maxActiveBounties);

                // ---------------------------------------------

                const applicantRecord : applicantRecordType = createNewApplicantRecord(unit);

                // update applicant storage
                s.applicantLedger[(bountyId, sender)] := applicantRecord;

                // update user storage
                userRecord.currentApplicationCount    := userRecord.currentApplicationCount + 1n;
                userRecord.appliedBounties            := Set.add(bountyId, userRecord.appliedBounties);
                s.userLedger[sender]                  := userRecord;

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  cancelApplication lambda *)
function lambdaCancelApplication(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.cancelApplicationIsPaused, error_CANCEL_APPLICATION_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED);

    case bountyLambdaAction of [
        |   LambdaCancelApplication(bountyId) -> {

                const sender : address = Tezos.get_sender();

                // get user and applicant record
                var applicantRecord  : applicantRecordType  := getApplicantRecord(bountyId, sender, s);
                var userRecord       : userRecordType       := getUserRecord(sender, s);

                // ---------------------------------------------
                // verification checks
                // ---------------------------------------------

                verifyApplicationIsPending(applicantRecord.status);

                // ---------------------------------------------

                // update applicant storage
                applicantRecord.status                := "WITHDRAWN";
                s.applicantLedger[(bountyId, sender)] := applicantRecord;

                // check final current application count cannot be less than 0
                const finalCurrentApplicationCount  : nat = if abs(userRecord.currentApplicationCount - 1n) < 0n then 0n else abs(userRecord.currentApplicationCount - 1n);

                // update user storage
                userRecord.currentApplicationCount    := finalCurrentApplicationCount;
                userRecord.appliedBounties            := Set.remove(bountyId, userRecord.appliedBounties);
                s.userLedger[sender]                  := userRecord;

            }
        |   _ -> skip
    ];

} with (noOperations, s)


(*  completeBounty lambda *)
function lambdaCompleteBounty(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.completeBountyIsPaused, error_COMPLETE_BOUNTY_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED);

    case bountyLambdaAction of [
        |   LambdaCompleteBounty(bountyId) -> {

                const sender : address = Tezos.get_sender();

                // get bounty and applicant record
                const bountyRecord : bountyRecordType       = getBountyRecord(bountyId, s);
                var applicantRecord : applicantRecordType  := getApplicantRecord(bountyId, sender, s);

                // ---------------------------------------------
                // verification checks
                // ---------------------------------------------

                verifyBountyIsActive(bountyRecord.status);

                verifyBountyIsNotPaused(bountyRecord.isPaused);

                verifyUserCanCompleteBounty(applicantRecord.status);

                // ---------------------------------------------

                if bountyRecord.hasMilestones then {

                    const currentMilestone : nat = case applicantRecord.currentMilestone of [
                            Some(_v) -> _v
                        |   None     -> 1n // first milestone
                    ]; 

                    var milestoneLog : milestoneLogRecordType := case applicantRecord.milestoneLog[currentMilestone] of [
                            Some(_log) -> _log
                        |   None -> [
                                status          = "PENDING_REVIEW";
                                completed       = True;
                                reviewed        = False;
                                review          = (None : option(string));
                                rewarded        = False;
                                rewardTimestamp = (None : option(timestamp));
                            ]
                    ];

                    milestoneLog.status     := "PENDING_REVIEW";
                    milestoneLog.completed  := True;
                    milestoneLog.reviewed   := False;

                    applicantRecord.milestoneLog[currentMilestone] := milestoneLog;

                } else {

                    // bounty has no milestones
                    applicantRecord.status      := "PENDING_REVIEW";
                    applicantRecord.completed   := True;
                    applicantRecord.reviewed       := False;

                }

                // update storage
                s.applicantLedger[(bountyId, sender)] := applicantRecord;

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  stopBounty lambda *)
function lambdaStopBounty(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.stopBountyIsPaused, error_STOP_BOUNTY_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED);

    case bountyLambdaAction of [
        |   LambdaStopBounty(bountyId) -> {

                const sender : address = Tezos.get_sender();

                // get user and applicant record
                var bountyRecord     : bountyRecordType     := getBountyRecord(bountyId, s);
                var applicantRecord  : applicantRecordType  := getApplicantRecord(bountyId, sender, s);
                var userRecord       : userRecordType       := getUserRecord(sender, s);

                // ---------------------------------------------
                // verification checks
                // ---------------------------------------------

                verifyUserCanStopBounty(applicantRecord.status);

                // ---------------------------------------------

                // update applicant storage
                applicantRecord.status                := "STOPPED";
                s.applicantLedger[(bountyId, sender)] := applicantRecord;

                // check final active bounty count cannot be less than 0
                const finalActiveBountyCount  : nat = if abs(userRecord.activeBountyCount - 1n) < 0n then 0n else abs(userRecord.activeBountyCount - 1n);

                // update user storage
                userRecord.activeBountyCount  := finalActiveBountyCount;
                userRecord.activeBounties     := Set.remove(bountyId, userRecord.activeBounties);
                s.userLedger[sender]          := userRecord;

                // check final active bounty count cannot be less than 0
                const finalCurrentApprovedApplicants  : nat = if abs(bountyRecord.currentApprovedApplicants - 1n) < 0n then 0n else abs(bountyRecord.currentApprovedApplicants - 1n);

                // update bounty storage
                bountyRecord.currentApprovedApplicants  := finalCurrentApprovedApplicants;
                s.bountyLedger[bountyId]                := bountyRecord;

            }
        |   _ -> skip
    ];

} with (noOperations, s)

// ------------------------------------------------------------------------------
//
// Bounty Lambdas End
//
// ------------------------------------------------------------------------------