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
    
    verifySenderIsAdminOrSuperAdmin(s.superAdmin, s.admins); 

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

    verifySenderIsAdminOrSuperAdmin(s.superAdmin, s.admins); 

    case bountyLambdaAction of [
        |   LambdaUpdateConfig(updateConfigParams) -> {
                
                const updateConfigAction    : bountyUpdateConfigActionType   = updateConfigParams.updateConfigAction;
                const updateConfigNewValue  : bountyUpdateConfigNewValueType = updateConfigParams.updateConfigNewValue;

                case updateConfigAction of [
                    |   ConfigMaxActiveBounties (_v)  -> s.config.maxActiveBounties         := updateConfigNewValue
                    |   ConfigMaxApplications (_v)    -> s.config.maxApplications           := updateConfigNewValue
                ];
            }
        |   _ -> skip
    ];
  
} with (noOperations, s)



(*  updateWhitelistContracts lambda *)
function lambdaUpdateWhitelistContracts(const bountyLambdaAction : bountyLambdaActionType; var s: bountyStorageType) : return is
block {

    verifySenderIsAdminOrSuperAdmin(s.superAdmin, s.admins); 

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

    verifySenderIsAdminOrSuperAdmin(s.superAdmin, s.admins); 

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

                verifySenderIsAdminOrSuperAdmin(s.superAdmin, s.admins); 

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

    verifyNoAmountSent(Unit);     
    verifySenderIsAdminOrSuperAdmin(s.superAdmin, s.admins); 

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

    verifyNoAmountSent(Unit);     
    verifySenderIsAdminOrSuperAdmin(s.superAdmin, s.admins); 

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

    verifyNoAmountSent(Unit);     
    verifySenderIsAdminOrSuperAdmin(s.superAdmin, s.admins); 

    case bountyLambdaAction of [
        |   LambdaTogglePauseEntrypoint(params) -> {

                case params.targetEntrypoint of [
                        SetBounty (_v)              -> s.breakGlassConfig.setBountyIsPaused                 := _v
                    |   TogglePauseBounty (_v)      -> s.breakGlassConfig.togglePauseBountyIsPaused         := _v
                    |   ApproveOrReject (_v)        -> s.breakGlassConfig.approveOrRejectIsPaused           := _v
                    |   ReviewBounty (_v)           -> s.breakGlassConfig.reviewBountyIsPaused              := _v
                    |   SendBountyReward (_v)       -> s.breakGlassConfig.sendBountyRewardIsPaused          := _v

                    |   FormGroup (_v)              -> s.breakGlassConfig.formGroupIsPaused                 := _v
                    |   AddGroupMember (_v)         -> s.breakGlassConfig.addGroupMemberIsPaused            := _v
                    |   ConfirmGroupMembership (_v) -> s.breakGlassConfig.confirmGroupMembershipIsPaused    := _v
                    |   LeaveGroup (_v)             -> s.breakGlassConfig.leaveGroupIsPaused                := _v

                    |   ApplyForBounty (_v)         -> s.breakGlassConfig.applyForBountyIsPaused            := _v
                    |   CancelApplication (_v)      -> s.breakGlassConfig.cancelApplicationIsPaused         := _v
                    |   CompleteBounty (_v)         -> s.breakGlassConfig.completeBountyIsPaused            := _v
                    |   StopBounty (_v)             -> s.breakGlassConfig.stopBountyIsPaused                := _v
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

                case setBountyCreatorParams of [

                    |   SetNewBountyCreator(setNewBountyCreatorParams) -> {

                            verifySenderIsAdminOrSuperAdmin(s.superAdmin, s.admins); // check that sender is admin 
                            
                            const bountyCreatorAddress : address = setNewBountyCreatorParams.creatorAddress;

                            // create new bounty creator record
                            const bountyCreatorRecord : bountyCreatorRecordType = createNewBountyCreatorRecord(
                                setNewBountyCreatorParams.name,
                                setNewBountyCreatorParams.description,
                                setNewBountyCreatorParams.website,
                                setNewBountyCreatorParams.image
                            );

                            s.bountyCreators[bountyCreatorAddress] := bountyCreatorRecord;

                        }
                    |   RemoveBountyCreator(bountyCreatorAddress) -> {

                            verifySenderIsAdminOrSuperAdmin(s.superAdmin, s.admins); // check that sender is admin 
                            remove (bountyCreatorAddress : address) from map s.bountyCreators;

                        }
                    |   UpdateBountyCreatorProfile(updateBountyCreatorProfile) -> {

                            const bountyCreatorAddress : address = Tezos.get_sender();

                            var bountyCreatorRecord : bountyCreatorRecordType := getBountyCreatorRecord(bountyCreatorAddress, s);

                            // update bounty creator record
                            bountyCreatorRecord := updateBountyCreatorRecord(
                                bountyCreatorRecord,
                                updateBountyCreatorProfile.name,
                                updateBountyCreatorProfile.description,
                                updateBountyCreatorProfile.website,
                                updateBountyCreatorProfile.image
                            );

                            // update storage
                            s.bountyCreators[bountyCreatorAddress] := bountyCreatorRecord;

                        }
                ];

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

                            const sender                 : address  = Tezos.get_sender();
                            const bountyContractAddress  : address  = Tezos.get_self_address();

                            const bountyId               : nat              = s.nextBountyId;
                            const bountyRecord           : bountyRecordType = createNewBountyRecord(createBountyParams);

                            // transfer rewards from creator of bounty to contract
                            const maxApprovedApplicants : nat = createBountyParams.maxApprovedApplicants;
                            for _tokenName -> reward in map createBountyParams.totalRewards block {

                                const totalRewardAmount : nat = maxApprovedApplicants * reward.amount;

                                operations := case reward.rewardTokenType of [
                                    |   Tez                     -> transferTez((Tezos.get_contract_with_error(bountyContractAddress, "Error. Tez could not be send to address.") : contract(unit)), totalRewardAmount * 1mutez) # operations
                                    |   Fa12(fa12TokenAddress)  -> transferFa12Token(sender, bountyContractAddress, totalRewardAmount, fa12TokenAddress) # operations
                                    |   Fa2(fa2Token)           -> transferFa2Token(sender, bountyContractAddress, totalRewardAmount, fa2Token.tokenId, fa2Token.tokenContractAddress) # operations
                                ];
                            };

                            // update storage
                            s.bountyLedger[bountyId]   := bountyRecord;
                            s.nextBountyId             := bountyId + 1n; 

                        } 
                    |   UpdateBounty(updateBountyParams) -> {

                            const sender                 : address  = Tezos.get_sender();
                            const bountyContractAddress  : address  = Tezos.get_self_address();

                            const bountyId               : nat              = updateBountyParams.bountyId;

                            // get bounty record
                            var bountyRecord : bountyRecordType  := getBountyRecord(bountyId, s);
                            
                            // get initial states
                            const initialRewards : rewardsType = bountyRecord.totalRewards;
                            const initialMaxApprovedApplicants : nat = bountyRecord.maxApprovedApplicants;

                            // ---------------------------------------------
                            // verification checks
                            // ---------------------------------------------

                            verifySenderIsAdminOrCreatorOrWhitelisted(bountyRecord.creator, bountyRecord.whitelisted, s);

                            // ---------------------------------------------

                            case updateBountyParams.name of [
                                    Some(_v) -> bountyRecord.name := _v
                                |   None     -> skip
                            ];

                            case updateBountyParams.description of [
                                    Some(_v) -> bountyRecord.description := _v
                                |   None     -> skip
                            ];

                            bountyRecord.image := updateBountyParams.image;
                            
                            case updateBountyParams.milestones of [
                                    Some(_v) -> bountyRecord.milestones := updateBountyParams.milestones
                                |   None     -> skip
                            ];

                            case updateBountyParams.rewards of [
                                    Some(_v) -> bountyRecord.totalRewards := _v
                                |   None     -> skip
                            ];

                            case updateBountyParams.maxApprovedApplicants of [
                                    Some(_v) -> bountyRecord.maxApprovedApplicants := _v
                                |   None     -> skip
                            ];

                            // check if bounty has milestones
                            const hasMilestones : bool = case bountyRecord.milestones of [
                                    Some(_v) -> True
                                |   None     -> False
                            ];

                            // verify rewards tally
                            if hasMilestones then {
                                verifyMilestoneAndTotalRewardsTally(bountyRecord.totalRewards, bountyRecord.milestones);
                            } else skip;
                            
                            // operation for adjustment of rewards 
                            const diffRewardsMap : rewardsDiffType = differenceBetweenRewards(initialRewards, initialMaxApprovedApplicants, bountyRecord.totalRewards, bountyRecord.maxApprovedApplicants);
                            for _tokenName -> rewardDiff in map diffRewardsMap block {
                                
                                const rewardAmount : nat = abs(rewardDiff.amount);

                                if rewardDiff.amount < 0 then {
                                    // send tokens from contract to sender
                                    operations := case rewardDiff.rewardTokenType of [
                                        |   Tez                     -> transferTez((Tezos.get_contract_with_error(sender, "Error. Tez could not be send to address.") : contract(unit)), rewardAmount * 1mutez) # operations
                                        |   Fa12(fa12TokenAddress)  -> transferFa12Token(bountyContractAddress, sender, rewardAmount, fa12TokenAddress) # operations
                                        |   Fa2(fa2Token)           -> transferFa2Token(bountyContractAddress, sender, rewardAmount, fa2Token.tokenId, fa2Token.tokenContractAddress) # operations
                                    ];
                                } else {
                                    // send tokens from sender to contract
                                    operations := case rewardDiff.rewardTokenType of [
                                        |   Tez                     -> transferTez((Tezos.get_contract_with_error(bountyContractAddress, "Error. Tez could not be send to address.") : contract(unit)), rewardAmount * 1mutez) # operations
                                        |   Fa12(fa12TokenAddress)  -> transferFa12Token(sender, bountyContractAddress, rewardAmount, fa12TokenAddress) # operations
                                        |   Fa2(fa2Token)           -> transferFa2Token(sender, bountyContractAddress, rewardAmount, fa2Token.tokenId, fa2Token.tokenContractAddress) # operations
                                    ];
                                };
                            };

                            // update storage
                            s.bountyLedger[bountyId] := bountyRecord;

                        }
                    |   UpdateWhitelist(updateBountyWhitelistParams) -> {

                            const bountyId    : nat               = updateBountyWhitelistParams.bountyId;
                            const addresses   : set(address)      = updateBountyWhitelistParams.addresses;
                            const updateType  : updateType        = updateBountyWhitelistParams.updateType;

                            // get bounty record
                            var bountyRecord : bountyRecordType  := getBountyRecord(bountyId, s);

                            // ---------------------------------------------
                            // verification checks
                            // ---------------------------------------------

                            verifySenderIsAdminOrCreatorOrWhitelisted(bountyRecord.creator, bountyRecord.whitelisted, s);

                            // ---------------------------------------------

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

                            const sender                 : address  = Tezos.get_sender();
                            const bountyContractAddress  : address  = Tezos.get_self_address();

                            const bountyId      : nat  = updateMilestoneParams.bountyId;
                            const milestoneId   : nat  = updateMilestoneParams.milestoneId;
                            
                            // get bounty record
                            var bountyRecord    : bountyRecordType := getBountyRecord(bountyId, s);

                            // get initial states
                            const initialRewards : rewardsType = bountyRecord.totalRewards;
                            const initialMaxApprovedApplicants : nat = bountyRecord.maxApprovedApplicants;

                            var milestones : milestonesType := case bountyRecord.milestones of [
                                    Some(_milestones) -> _milestones
                                |   None              -> (map[] : milestonesType)
                            ];

                            var milestoneRecord : milestoneRecordType := case milestones[milestoneId] of [
                                    Some(_record) -> _record
                                |   None          -> record [
                                        name        = "EMPTY";
                                        description = "EMPTY";
                                        image       = (None : option(string));
                                        rewards     = (map[] : rewardsType);
                                ]
                            ];

                            // ---------------------------------------------
                            // verification checks
                            // ---------------------------------------------
                            
                            verifySenderIsAdminOrCreatorOrWhitelisted(bountyRecord.creator, bountyRecord.whitelisted, s);

                            verifyBountyHasMilestones(bountyRecord.hasMilestones);

                            // ---------------------------------------------

                            case updateMilestoneParams.name of [
                                    Some(_v) -> milestoneRecord.name := _v
                                |   None     -> skip
                            ];

                            case updateMilestoneParams.description of [
                                    Some(_v) -> milestoneRecord.description := _v
                                |   None     -> skip
                            ];

                            milestoneRecord.image := updateMilestoneParams.image;
                            
                            case updateMilestoneParams.rewards of [
                                    Some(_v) -> {
                                        
                                        // set new rewards for milestone
                                        milestoneRecord.rewards := _v;
                                        
                                        // update bounty record milestones
                                        milestones[milestoneId] := milestoneRecord;

                                        // calculate new total rewards
                                        const newTotalRewards : rewardsType = getNewTotalRewards(milestones);

                                        // operation for adjustment of rewards 
                                        const diffRewardsMap : rewardsDiffType = differenceBetweenRewards(initialRewards, initialMaxApprovedApplicants, newTotalRewards, initialMaxApprovedApplicants);
                                        for _tokenName -> rewardDiff in map diffRewardsMap block {
                                            
                                            const rewardAmount : nat = abs(rewardDiff.amount);

                                            if rewardDiff.amount < 0 then {
                                                // send tokens from contract to sender
                                                operations := case rewardDiff.rewardTokenType of [
                                                    |   Tez                     -> transferTez((Tezos.get_contract_with_error(sender, "Error. Tez could not be send to address.") : contract(unit)), rewardAmount * 1mutez) # operations
                                                    |   Fa12(fa12TokenAddress)  -> transferFa12Token(bountyContractAddress, sender, rewardAmount, fa12TokenAddress) # operations
                                                    |   Fa2(fa2Token)           -> transferFa2Token(bountyContractAddress, sender, rewardAmount, fa2Token.tokenId, fa2Token.tokenContractAddress) # operations
                                                ];
                                            } else {
                                                // send tokens from sender to contract
                                                operations := case rewardDiff.rewardTokenType of [
                                                    |   Tez                     -> transferTez((Tezos.get_contract_with_error(bountyContractAddress, "Error. Tez could not be send to address.") : contract(unit)), rewardAmount * 1mutez) # operations
                                                    |   Fa12(fa12TokenAddress)  -> transferFa12Token(sender, bountyContractAddress, rewardAmount, fa12TokenAddress) # operations
                                                    |   Fa2(fa2Token)           -> transferFa2Token(sender, bountyContractAddress, rewardAmount, fa2Token.tokenId, fa2Token.tokenContractAddress) # operations
                                                ];
                                            };
                                        };

                                    }
                                |   None     -> skip
                            ];

                            // update storage
                            bountyRecord.milestones     := Some(milestones);
                            s.bountyLedger[bountyId]    := bountyRecord;

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

                // ---------------------------------------------
                // verification checks
                // ---------------------------------------------

                verifySenderIsAdminOrCreatorOrWhitelisted(bountyRecord.creator, bountyRecord.whitelisted, s);

                // ---------------------------------------------

                // toggle pause
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

                const bountyId   : nat            = approveOrRejectParams.bountyId;
                const applicant  : applicantType  = approveOrRejectParams.applicant;
                const approval   : approvalType   = approveOrRejectParams.approval;

                // get bounty record
                var bountyRecord : bountyRecordType := getBountyRecord(bountyId, s);

                // ---------------------------------------------
                // verification checks
                // ---------------------------------------------

                verifySenderIsAdminOrCreatorOrWhitelisted(bountyRecord.creator, bountyRecord.whitelisted, s);

                // ---------------------------------------------

                // get user and applicant record
                var applicationRecord : applicationRecordType := getApplicationRecord(bountyId, applicant, s);

                // update applicant record
                case approval of [
                        Approve(_) -> {
                            
                            applicationRecord.status := "APPROVED";
                            
                            const maxApprovedApplicants      : nat = bountyRecord.maxApprovedApplicants;
                            const currentApprovedApplicants  : nat = Map.size(bountyRecord.currentApprovedApplicants);

                            // check if bounty can approve new applicants
                            if currentApprovedApplicants >= maxApprovedApplicants 
                            then failwith(error_BOUNTY_HAS_REACHED_MAX_APPROVED_APPLICANTS) 
                            else skip;

                            // update bounty record
                            if bountyRecord.hasMilestones then {
                                const bountyProgress : bountyProgressType = Milestone(0n);
                                bountyRecord.currentApprovedApplicants[applicant] := bountyProgress;
                            } else {
                                const bountyProgress : bountyProgressType = NoMilestone;
                                bountyRecord.currentApprovedApplicants[applicant] := bountyProgress;
                            };

                            // update storage
                            s.bountyLedger[bountyId]  := bountyRecord;

                        }
                    |   Reject(_) -> {
                            applicationRecord.status := "REJECTED";
                        }
                ];

                
                // update applicant record (user or group)
                case applicant of [
                    |   User(_address)  -> {
                            
                            var applicantRecord : userRecordType := getUserRecord(_address, s);

                            case approval of [
                                    Approve(_) -> {
                                        applicantRecord.activeBountyCount := applicantRecord.activeBountyCount + 1n;
                                        applicantRecord.activeBounties    := Set.add(bountyId, applicantRecord.activeBounties);   
                                    }
                                |   _ -> skip
                            ];
                            
                            // remove application from user record
                            const finalCurrentApplicationCount  : nat = if abs(applicantRecord.currentApplicationCount - 1n) < 0n then 0n else abs(applicantRecord.currentApplicationCount - 1n);
                            applicantRecord.currentApplicationCount  := finalCurrentApplicationCount;
                            applicantRecord.appliedBounties          := Set.remove(bountyId, applicantRecord.appliedBounties);
                            
                            s.userLedger[_address] := applicantRecord;
                    
                        }
                    |   Group(_groupId) -> { 
                            
                            var applicantRecord : groupRecordType := getGroupRecord(_groupId, s);

                            case approval of [
                                    Approve(_) -> {
                                        applicantRecord.activeBountyCount := applicantRecord.activeBountyCount + 1n;
                                        applicantRecord.activeBounties    := Set.add(bountyId, applicantRecord.activeBounties);
                                        
                                    }
                                |   _ -> skip
                            ];

                            // remove application from user record
                            const finalCurrentApplicationCount  : nat = if abs(applicantRecord.currentApplicationCount - 1n) < 0n then 0n else abs(applicantRecord.currentApplicationCount - 1n);
                            applicantRecord.currentApplicationCount  := finalCurrentApplicationCount;
                            applicantRecord.appliedBounties          := Set.remove(bountyId, applicantRecord.appliedBounties);

                            s.groupLedger[_groupId] := applicantRecord;
                            
                        }
                ];

                // update storage
                s.applicationLedger[(bountyId, applicant)] := applicationRecord;

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

                const bountyId   : nat            = reviewBountyParams.bountyId;
                const applicant  : applicantType  = reviewBountyParams.applicant;
                const status     : string         = reviewBountyParams.status;

                // get bounty record
                var bountyRecord        : bountyRecordType       := getBountyRecord(bountyId, s);
                var applicationRecord   : applicationRecordType  := getApplicationRecord(bountyId, applicant, s);
                
                // ---------------------------------------------
                // verification checks
                // ---------------------------------------------

                // permissions check
                verifySenderIsAdminOrCreatorOrWhitelisted(bountyRecord.creator, bountyRecord.whitelisted, s);

                verifyValidBountyReviewStatus(status);

                // ---------------------------------------------

                if bountyRecord.hasMilestones then {
                    
                    // bounty has milestones
                    const currentMilestone : nat = case applicationRecord.currentMilestone of [
                            Some(_v) -> _v
                        |   None     -> failwith(error_CURRENT_MILESTONE_NOT_FOUND)
                    ];

                    // get milestone log
                    var milestoneLog : milestoneLogType := case applicationRecord.milestoneLog of [
                            Some(_log) -> _log 
                        |   None       -> failwith(error_MILESTONE_LOG_NOT_FOUND_IN_APPLICANT_RECORD)
                    ];

                    var milestoneLogRecord : milestoneLogRecordType := case milestoneLog[currentMilestone] of [
                            Some(_record) -> _record
                        |   None          -> failwith(error_MILESTONE_LOG_RECORD_NOT_FOUND_IN_APPLICANT_RECORD)
                    ];

                    milestoneLogRecord.status := status;
                    milestoneLogRecord.reviewed := True;  
            
                    case reviewBountyParams.milestoneReview of [
                            Some(_review) -> milestoneLogRecord.review := Some(_review)
                        |   None          -> skip
                    ];

                    // update milestone log in applicant record
                    const bountyMilestones : milestonesType = case bountyRecord.milestones of [
                            Some(_milestones) -> _milestones
                        |   None              -> failwith(error_BOUNTY_HAS_NO_MILESTONES)
                    ];
                    const numberOfMilestones : nat = Map.size(bountyMilestones);
                    
                    // update milestone log
                    milestoneLog[currentMilestone] := milestoneLogRecord;
                    applicationRecord.milestoneLog   := Some(milestoneLog);

                    // check if all milestones completed in bounty
                    if currentMilestone = numberOfMilestones then {

                        // if final status is approved, set applicant record status to approved as well
                        if status = "REVIEW_APPROVED" then {
                            
                            applicationRecord.status := status;
                            applicationRecord.reviewed := True;

                            case applicant of [
                                |   User(_address)  -> {
                                        
                                        var applicantRecord : userRecordType := getUserRecord(_address, s);

                                        // check final active bounty count cannot be less than 0
                                        const finalActiveBountyCount  : nat = if abs(applicantRecord.activeBountyCount - 1n) < 0n then 0n else abs(applicantRecord.activeBountyCount - 1n);

                                        applicantRecord.activeBountyCount := finalActiveBountyCount;
                                        applicantRecord.activeBounties    := Set.remove(bountyId, applicantRecord.activeBounties);

                                        s.userLedger[_address] := applicantRecord;
                                
                                    }
                                |   Group(_groupId) -> { 
                                        
                                        var applicantRecord : groupRecordType := getGroupRecord(_groupId, s);

                                        // check final active bounty count cannot be less than 0
                                        const finalActiveBountyCount  : nat = if abs(applicantRecord.activeBountyCount - 1n) < 0n then 0n else abs(applicantRecord.activeBountyCount - 1n);

                                        applicantRecord.activeBountyCount := finalActiveBountyCount;
                                        applicantRecord.activeBounties    := Set.remove(bountyId, applicantRecord.activeBounties);

                                        s.groupLedger[_groupId] := applicantRecord;
                                        
                                    }
                            ];

                            // update bounty record with progress and completed applicants
                            const bountyProgress : bountyProgressType = Completed;
                            bountyRecord.currentApprovedApplicants[applicant] := bountyProgress;

                            bountyRecord.completedApplicants := Set.add(applicant, bountyRecord.completedApplicants);

                        } else skip;

                    } else skip;

                } else {
                    
                    // bounty has no milestones
                    applicationRecord.status := status;
                    applicationRecord.reviewed := True;

                    if status = "REVIEW_APPROVED" then {

                        case applicant of [
                            |   User(_address)  -> {
                                    
                                    var applicantRecord : userRecordType := getUserRecord(_address, s);

                                    // check final active bounty count cannot be less than 0
                                    const finalActiveBountyCount  : nat = if abs(applicantRecord.activeBountyCount - 1n) < 0n then 0n else abs(applicantRecord.activeBountyCount - 1n);

                                    applicantRecord.activeBountyCount := finalActiveBountyCount;
                                    applicantRecord.activeBounties    := Set.remove(bountyId, applicantRecord.activeBounties);

                                    s.userLedger[_address] := applicantRecord;
                            
                                }
                            |   Group(_groupId) -> { 
                                    
                                    var applicantRecord : groupRecordType := getGroupRecord(_groupId, s);
                                    
                                    // check final active bounty count cannot be less than 0
                                    const finalActiveBountyCount  : nat = if abs(applicantRecord.activeBountyCount - 1n) < 0n then 0n else abs(applicantRecord.activeBountyCount - 1n);

                                    applicantRecord.activeBountyCount := finalActiveBountyCount;
                                    applicantRecord.activeBounties    := Set.remove(bountyId, applicantRecord.activeBounties);

                                    s.groupLedger[_groupId] := applicantRecord;
                                    
                                }
                        ];
                        
                        // update bounty record with progress and completed applicants
                        const bountyProgress : bountyProgressType = Completed;
                        bountyRecord.currentApprovedApplicants[applicant] := bountyProgress;
                        
                        bountyRecord.completedApplicants := Set.add(applicant, bountyRecord.completedApplicants);

                    } else skip;

                };

                // set bounty review text if exists
                case reviewBountyParams.bountyReview of [
                        Some(_review) -> applicationRecord.review := Some(_review)
                    |   None          -> skip
                ];

                // update storage
                s.applicationLedger[(bountyId, applicant)] := applicationRecord;
                s.bountyLedger[bountyId]                 := bountyRecord;

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  sendBountyReward lambda *)
function lambdaSendBountyReward(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    var operations : list(operation) := nil;

    verifyEntrypointIsNotPaused(s.breakGlassConfig.sendBountyRewardIsPaused, error_SEND_BOUNTY_REWARD_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED);

    case bountyLambdaAction of [
        |   LambdaSendBountyReward(sendBountyRewardParams) -> {

                const bountyId   : nat                  = sendBountyRewardParams.bountyId;
                const applicants : set(applicantType)   = sendBountyRewardParams.applicants;
                const bountyContractAddress : address   = Tezos.get_self_address();

                // get bounty record
                var bountyRecord : bountyRecordType := getBountyRecord(bountyId, s);

                // permissions check
                verifySenderIsAdminOrCreatorOrWhitelisted(bountyRecord.creator, bountyRecord.whitelisted, s);

                if bountyRecord.hasMilestones then block {

                    // get milestone id
                    const milestoneId : nat = case sendBountyRewardParams.milestoneId of [
                            Some(_v) -> _v
                        |   None     -> failwith(error_MILESTONE_NEEDS_TO_BE_SPECIFIED_TO_SEND_BOUNTY_REWARD)
                    ];

                    // get number of bounty milestones
                    const bountyMilestones : milestonesType = case bountyRecord.milestones of [
                            Some(_milestones) -> _milestones
                        |   None              -> failwith(error_BOUNTY_HAS_NO_MILESTONES)
                    ];
                    const numberOfMilestones : nat = Map.size(bountyMilestones);

                    // get bounty milestone and rewards
                    const bountyMilestone : milestoneRecordType = getBountyMilestoneRecord(bountyRecord, milestoneId);
                    const milestoneRewards : rewardsType = bountyMilestone.rewards;

                    // send rewards for applicants; loop through applicants in set
                    for applicant in set applicants block {

                        var applicationRecord : applicationRecordType := getApplicationRecord(bountyId, applicant, s);
                        var applicantMilestoneRecord : milestoneLogRecordType := getApplicantMilestoneRecord(applicationRecord, milestoneId);

                        if applicantMilestoneRecord.status = "REVIEW_APPROVED" 
                        and applicantMilestoneRecord.completed = True 
                        and applicantMilestoneRecord.reviewed = True
                        and applicantMilestoneRecord.rewarded = False then {

                            // update applicant milestone record
                            applicantMilestoneRecord.rewarded           := True;
                            applicantMilestoneRecord.rewardTimestamp    := Some(Tezos.get_now());
                            applicantMilestoneRecord.status             := "REWARDED";

                            // check if last milestone of bounty
                            if milestoneId = numberOfMilestones then {
                                // update applicant milestone record
                                applicationRecord.fullyRewarded := True;
                            } else skip;

                            applicationRecord.lastRewardTimestamp         := Some(Tezos.get_now());

                            // update storage
                            var milestoneLog : milestoneLogType := case applicationRecord.milestoneLog of [
                                    Some(_log) -> _log
                                |   None       -> failwith(error_MILESTONE_LOG_RECORD_NOT_FOUND_IN_APPLICANT_RECORD)
                            ];

                            milestoneLog[milestoneId]                   := applicantMilestoneRecord;
                            applicationRecord.milestoneLog                := Some(milestoneLog);
                            s.applicationLedger[(bountyId, applicant)]    := applicationRecord;
                            
                            // loop through milestone rewards and create operations to send rewards
                            case applicant of [
                                |   User(_address) -> {

                                        for _tokenName -> reward in map milestoneRewards block {
                                            operations := case reward.rewardTokenType of [
                                                |   Tez                     -> transferTez((Tezos.get_contract_with_error(_address, "Error. Tez could not be send to address.") : contract(unit)), reward.amount * 1mutez) # operations
                                                |   Fa12(fa12TokenAddress)  -> transferFa12Token(bountyContractAddress, _address, reward.amount, fa12TokenAddress) # operations
                                                |   Fa2(fa2Token)           -> transferFa2Token(bountyContractAddress, _address, reward.amount, fa2Token.tokenId, fa2Token.tokenContractAddress) # operations
                                            ];
                                        };

                                    }
                                |   Group(_groupId) -> {

                                        const groupRecord : groupRecordType = getGroupRecord(_groupId, s);
                                        const groupCreator : address = groupRecord.creator;

                                        for _tokenName -> reward in map milestoneRewards block {
                                            operations := case reward.rewardTokenType of [
                                                |   Tez                     -> transferTez((Tezos.get_contract_with_error(groupCreator, "Error. Tez could not be send to address.") : contract(unit)), reward.amount * 1mutez) # operations
                                                |   Fa12(fa12TokenAddress)  -> transferFa12Token(bountyContractAddress, groupCreator, reward.amount, fa12TokenAddress) # operations
                                                |   Fa2(fa2Token)           -> transferFa2Token(bountyContractAddress, groupCreator, reward.amount, fa2Token.tokenId, fa2Token.tokenContractAddress) # operations
                                            ];
                                        };

                                    }
                            ]

                            
                        } else skip
                    };

                } else block {

                    // bounty has no milestones; send rewards for applicants 
                    for applicant in set applicants block {

                        var applicationRecord : applicationRecordType := getApplicationRecord(bountyId, applicant, s);

                        if applicationRecord.status = "REVIEW_APPROVED" 
                        and applicationRecord.completed = True 
                        and applicationRecord.reviewed = True
                        and applicationRecord.fullyRewarded = False then {

                            // update applicant milestone record
                            applicationRecord.status                 := "REWARDED";
                            applicationRecord.fullyRewarded          := True;
                            applicationRecord.lastRewardTimestamp    := Some(Tezos.get_now());

                            // update storage
                            s.applicationLedger[(bountyId, applicant)]    := applicationRecord;

                            // loop through bounty rewards
                            case applicant of [
                                |   User(_address) -> {
                                        for _tokenName -> reward in map bountyRecord.totalRewards block {
                                            operations := case reward.rewardTokenType of [
                                                |   Tez                     -> transferTez((Tezos.get_contract_with_error(_address, "Error. Tez could not be send to address.") : contract(unit)), reward.amount * 1mutez) # operations
                                                |   Fa12(fa12TokenAddress)  -> transferFa12Token(bountyContractAddress, _address, reward.amount, fa12TokenAddress) # operations
                                                |   Fa2(fa2Token)           -> transferFa2Token(bountyContractAddress, _address, reward.amount, fa2Token.tokenId, fa2Token.tokenContractAddress) # operations
                                            ];
                                        };
                                    }
                                |   Group(_groupId) -> {

                                        const groupRecord : groupRecordType = getGroupRecord(_groupId, s);
                                        const groupCreator : address = groupRecord.creator;

                                        for _tokenName -> reward in map bountyRecord.totalRewards block {
                                            operations := case reward.rewardTokenType of [
                                                |   Tez                     -> transferTez((Tezos.get_contract_with_error(groupCreator, "Error. Tez could not be send to address.") : contract(unit)), reward.amount * 1mutez) # operations
                                                |   Fa12(fa12TokenAddress)  -> transferFa12Token(bountyContractAddress, groupCreator, reward.amount, fa12TokenAddress) # operations
                                                |   Fa2(fa2Token)           -> transferFa2Token(bountyContractAddress, groupCreator, reward.amount, fa2Token.tokenId, fa2Token.tokenContractAddress) # operations
                                            ];
                                        };

                                    }
                            ];
                            
                        } else skip

                    };

                }

            }
        |   _ -> skip
    ];

} with (noOperations, s)

// ------------------------------------------------------------------------------
// Bounty Admin Lambdas End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Group Lambdas Begin
// ------------------------------------------------------------------------------

(*  formGroup lambda *)
function lambdaFormGroup(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.formGroupIsPaused, error_FORM_GROUP_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED);

    case bountyLambdaAction of [
        |   LambdaFormGroup(_params) -> {

                const creator : address = Tezos.get_sender();

                var userRecord       : userRecordType       := getUserRecord(creator, s);

                // ---------------------------------------------
                // verification checks
                // ---------------------------------------------

                verifyMaxGroupsCreatedPerUserNotReached(userRecord.groupsCreated, s.config.maxGroupsCreatedPerUser);

                // ---------------------------------------------

                // create new group
                const groupId   : nat             = s.nextGroupId;
                const newGroup  : groupRecordType = createGroupRecord(creator);
                
                // update user record
                userRecord.groups := Set.add(groupId, userRecord.groups);

                // update storage
                s.nextGroupId          := groupId + 1n;
                s.groupLedger[groupId] := newGroup;
                s.userLedger[creator]  := userRecord;

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  addGroupMember lambda *)
function lambdaAddGroupMember(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.addGroupMemberIsPaused, error_ADD_GROUP_MEMBER_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED);

    case bountyLambdaAction of [
        |   LambdaAddGroupMember(addGroupMemberParams) -> {

                const creator   : address = Tezos.get_sender();
                const groupId   : nat     = addGroupMemberParams.groupId;
                const member    : address = addGroupMemberParams.member;
                
                const groupRecord : groupRecordType = getGroupRecord(groupId, s);

                // ---------------------------------------------
                // verification checks
                // ---------------------------------------------

                verifySenderIsGroupCreator(groupRecord.creator, creator);

                // ---------------------------------------------

                var memberRecord  : userRecordType := getUserRecord(member, s);
                memberRecord.groupInvites := Set.add(groupId, memberRecord.groupInvites);

                // update storage
                s.userLedger[member]  := memberRecord;

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  confirmGroupMembership lambda *)
function lambdaConfirmGroupMembership(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.confirmGroupMembershipIsPaused, error_CONFIRM_GROUP_MEMBERSHIP_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED);

    case bountyLambdaAction of [
        |   LambdaConfirmGroupMembership(groupId) -> {

                const sender    : address           = Tezos.get_sender();
                var userRecord  : userRecordType   := getUserRecord(sender, s);
                var group       : groupRecordType  := getGroupRecord(groupId, s);

                // ---------------------------------------------
                // verification checks
                // ---------------------------------------------

                verifyUserIsInvitedToGroup(userRecord.groupInvites, groupId);

                verifyMaxMembersPerGroupNotReached(group.members, s.config.maxMembersPerGroup);

                // ---------------------------------------------

                // add user to group members
                group.members            := Set.add(sender, group.members);
                
                // update user record
                userRecord.groupInvites  := Set.remove(groupId, userRecord.groupInvites);
                userRecord.groups        := Set.add(groupId, userRecord.groups);

                // update storage
                s.groupLedger[groupId]   := group;
                s.userLedger[sender]     := userRecord;

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  leaveGroup lambda *)
function lambdaLeaveGroup(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.leaveGroupIsPaused, error_LEAVE_GROUP_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED);

    case bountyLambdaAction of [
        |   LambdaLeaveGroup(groupId) -> {

                const sender    : address          = Tezos.get_sender();

                var userRecord  : userRecordType  := getUserRecord(sender, s);
                var group       : groupRecordType := getGroupRecord(groupId, s);

                // ---------------------------------------------
                // verification checks
                // ---------------------------------------------

                verifyUserIsInGroup(sender, group.members);

                // ---------------------------------------------

                // set group to inactive if creator leaves the group
                const groupCreator : address = group.creator; 
                if sender = groupCreator then {
                    group.status := "INACTIVE";
                } else skip;

                // remove sender from group members
                group.members := Set.remove(sender, group.members);
            
                // update user record
                userRecord.groups := Set.remove(groupId, userRecord.groups);

                // update storage
                s.groupLedger[groupId] := group;
                s.userLedger[sender]   := userRecord;

            }
        |   _ -> skip
    ];

} with (noOperations, s)

// ------------------------------------------------------------------------------
// Group Lambdas End
// ------------------------------------------------------------------------------




// ------------------------------------------------------------------------------
// Bounty Lambdas Begin
// ------------------------------------------------------------------------------

(*  applyForBounty lambda *)
function lambdaApplyForBounty(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.applyForBountyIsPaused, error_APPLY_FOR_BOUNTY_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED);

    case bountyLambdaAction of [
        |   LambdaApplyForBounty(applyForBountyParams) -> {

                const sender : address = Tezos.get_sender();
                
                const bountyId      : nat           = applyForBountyParams.bountyId;
                const applicant     : applicantType = applyForBountyParams.applicant;

                // get bounty and user record
                const bountyRecord : bountyRecordType = getBountyRecord(bountyId, s);
                
                // ---------------------------------------------
                // verification checks
                // ---------------------------------------------

                verifyBountyIsActive(bountyRecord.status);

                verifyBountyIsNotPaused(bountyRecord.isPaused);

                verifyBountyHasSpaceForNewApplicants(bountyRecord.maxApprovedApplicants, Map.size(bountyRecord.currentApprovedApplicants));

                verifyUserHasNotAlreadyAppliedForBounty(bountyId, applicant, s);

                // ---------------------------------------------

                case applicant of [
                    |   User(_address) -> {

                            var userRecord : userRecordType      := getOrCreateUserRecord(sender, s);
                            
                            verifySenderIsApplicant(_address, sender);
                            verifyMaxApplicationsNotReached(userRecord.currentApplicationCount, s.config.maxApplications);
                            verifyMaxActiveBountiesNotReached(userRecord.activeBountyCount, s.config.maxActiveBounties);

                            // update user storage
                            userRecord.currentApplicationCount    := userRecord.currentApplicationCount + 1n;
                            userRecord.appliedBounties            := Set.add(bountyId, userRecord.appliedBounties);
                            s.userLedger[sender]                  := userRecord;

                        }
                    |   Group(_groupId) -> {

                            var groupRecord : groupRecordType := getGroupRecord(_groupId, s);
                            const groupCreator : address = groupRecord.creator;

                            verifySenderIsGroupCreator(groupCreator, sender);
                            verifyMaxApplicationsNotReached(groupRecord.currentApplicationCount, s.config.maxApplications);
                            verifyMaxActiveBountiesNotReached(groupRecord.activeBountyCount, s.config.maxActiveBounties);

                            // update group storage
                            groupRecord.currentApplicationCount    := groupRecord.currentApplicationCount + 1n;
                            groupRecord.appliedBounties            := Set.add(bountyId, groupRecord.appliedBounties);
                            s.groupLedger[_groupId]                := groupRecord;

                        }
                ];

                const applicationRecord : applicationRecordType = createNewApplicationRecord(unit);

                // update application storage
                s.applicationLedger[(bountyId, applicant)] := applicationRecord;

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  cancelApplication lambda *)
function lambdaCancelApplication(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.cancelApplicationIsPaused, error_CANCEL_APPLICATION_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED);

    case bountyLambdaAction of [
        |   LambdaCancelApplication(cancelApplicationParams) -> {

                const sender        : address       = Tezos.get_sender();

                const bountyId      : nat           = cancelApplicationParams.bountyId;
                const applicant     : applicantType = cancelApplicationParams.applicant;

                // get user and applicant record
                var applicationRecord  : applicationRecordType  := getApplicationRecord(bountyId, applicant, s);

                // ---------------------------------------------
                // verification checks
                // ---------------------------------------------

                verifyApplicationIsPending(applicationRecord.status);

                // ---------------------------------------------

                // update applicant storage
                applicationRecord.status                    := "CANCELED";
                s.applicationLedger[(bountyId, applicant)]  := applicationRecord;

                case applicant of [
                    |   User(_address) -> {

                            verifySenderIsApplicant(_address, sender);
                            var userRecord       : userRecordType           := getUserRecord(sender, s);
                            
                            // check final current application count cannot be less than 0
                            const finalCurrentApplicationCount  : nat = if abs(userRecord.currentApplicationCount - 1n) < 0n then 0n else abs(userRecord.currentApplicationCount - 1n);

                            // update user storage
                            userRecord.currentApplicationCount    := finalCurrentApplicationCount;
                            userRecord.appliedBounties            := Set.remove(bountyId, userRecord.appliedBounties);
                            s.userLedger[sender]                  := userRecord;

                        }
                    |   Group(_groupId) -> {

                            var groupRecord : groupRecordType := getGroupRecord(_groupId, s);
                            const groupCreator : address = groupRecord.creator;

                            verifySenderIsGroupCreator(groupCreator, sender);

                            // check final current application count cannot be less than 0
                            const finalCurrentApplicationCount  : nat = if abs(groupRecord.currentApplicationCount - 1n) < 0n then 0n else abs(groupRecord.currentApplicationCount - 1n);

                            // update group storage
                            groupRecord.currentApplicationCount    := finalCurrentApplicationCount;
                            groupRecord.appliedBounties            := Set.remove(bountyId, groupRecord.appliedBounties);
                            s.groupLedger[_groupId]                := groupRecord;

                        }
                ];

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  completeBounty lambda *)
function lambdaCompleteBounty(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.completeBountyIsPaused, error_COMPLETE_BOUNTY_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED);

    case bountyLambdaAction of [
        |   LambdaCompleteBounty(completeBountyParams) -> {

                const sender        : address       = Tezos.get_sender();
                const bountyId      : nat           = completeBountyParams.bountyId;
                const applicant     : applicantType = completeBountyParams.applicant;

                // get bounty and applicant record
                const bountyRecord : bountyRecordType           = getBountyRecord(bountyId, s);
                var applicationRecord : applicationRecordType  := getApplicationRecord(bountyId, applicant, s);

                // ---------------------------------------------
                // verification checks
                // ---------------------------------------------

                verifyBountyIsActive(bountyRecord.status);

                verifyBountyIsNotPaused(bountyRecord.isPaused);

                verifyUserCanCompleteBounty(applicationRecord.status);

                case applicant of [
                    |   User(_address) -> {
                            verifySenderIsApplicant(_address, sender);
                        }
                    |   Group(_groupId) -> {

                            const groupRecord   : groupRecordType = getGroupRecord(_groupId, s);
                            const groupCreator  : address = groupRecord.creator;

                            verifySenderIsGroupCreator(groupCreator, sender);
                        }
                ];

                // ---------------------------------------------

                if bountyRecord.hasMilestones then {

                    var currentMilestone : nat := case applicationRecord.currentMilestone of [
                            Some(_v) -> _v
                        |   None     -> 1n // first milestone
                    ];                     

                    var milestoneLog : milestoneLogType := case applicationRecord.milestoneLog of [
                            Some(_log) -> _log
                        |   None       -> (map[] : milestoneLogType)
                    ];

                    var milestoneLogRecord : milestoneLogRecordType := case milestoneLog[currentMilestone] of [
                            Some(_record) -> _record
                        |   None -> record [
                                status          = "REVIEW_PENDING";
                                completed       = True;
                                reviewed        = False;
                                review          = (None : option(string));
                                rewarded        = False;
                                rewardTimestamp = (None : option(timestamp));
                            ]
                    ];

                    // get number of bounty milestones
                    const bountyMilestones : milestonesType = case bountyRecord.milestones of [
                            Some(_milestones) -> _milestones
                        |   None              -> failwith(error_BOUNTY_HAS_NO_MILESTONES)
                    ];
                    const numberOfMilestones : nat = Map.size(bountyMilestones);

                    // create new milestone log for next milestone
                    if milestoneLogRecord.status = "REVIEW_APPROVED" and currentMilestone < numberOfMilestones then block {
                        milestoneLogRecord := createNewMilestoneLog(unit);
                        
                        // increment current milestone
                        currentMilestone := currentMilestone + 1n;
                    } else skip;

                    milestoneLogRecord.status      := "REVIEW_PENDING";
                    milestoneLogRecord.completed   := True;
                    milestoneLogRecord.reviewed    := False;

                    milestoneLog[currentMilestone]  := milestoneLogRecord;
                    applicationRecord.milestoneLog  := Some(milestoneLog);

                } else {

                    // bounty has no milestones
                    applicationRecord.status      := "REVIEW_PENDING";
                    applicationRecord.completed   := True;
                    applicationRecord.reviewed    := False;

                };

                // update storage
                s.applicationLedger[(bountyId, applicant)] := applicationRecord;

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  stopBounty lambda *)
function lambdaStopBounty(const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.stopBountyIsPaused, error_STOP_BOUNTY_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED);

    case bountyLambdaAction of [
        |   LambdaStopBounty(stopBountyParams) -> {

                const sender        : address       = Tezos.get_sender();
                const bountyId      : nat           = stopBountyParams.bountyId;
                const applicant     : applicantType = stopBountyParams.applicant;

                // get user and applicant record
                var bountyRecord     : bountyRecordType         := getBountyRecord(bountyId, s);
                var applicationRecord  : applicationRecordType  := getApplicationRecord(bountyId, applicant, s);

                // ---------------------------------------------
                // verification checks
                // ---------------------------------------------

                verifyUserCanStopBounty(applicationRecord.status);

                // ---------------------------------------------

                // update applicant storage
                applicationRecord.status                := "STOPPED";
                s.applicationLedger[(bountyId, applicant)] := applicationRecord;

                case applicant of [
                    |   User(_address) -> {
                            
                            verifySenderIsApplicant(_address, sender);
                            var userRecord : userRecordType      := getOrCreateUserRecord(sender, s);

                            // check final active bounty count cannot be less than 0
                            const finalActiveBountyCount  : nat = if abs(userRecord.activeBountyCount - 1n) < 0n then 0n else abs(userRecord.activeBountyCount - 1n);

                            // update user storage
                            userRecord.activeBountyCount  := finalActiveBountyCount;
                            userRecord.activeBounties     := Set.remove(bountyId, userRecord.activeBounties);
                            s.userLedger[sender]          := userRecord;

                        }
                    |   Group(_groupId) -> {

                            var groupRecord     : groupRecordType := getGroupRecord(_groupId, s);
                            const groupCreator  : address          = groupRecord.creator;

                            verifySenderIsGroupCreator(groupCreator, sender);

                            // check final active bounty count cannot be less than 0
                            const finalActiveBountyCount  : nat = if abs(groupRecord.activeBountyCount - 1n) < 0n then 0n else abs(groupRecord.activeBountyCount - 1n);

                            // update group storage
                            groupRecord.activeBountyCount  := finalActiveBountyCount;
                            groupRecord.activeBounties     := Set.remove(bountyId, groupRecord.activeBounties);
                            s.groupLedger[_groupId]        := groupRecord;

                        }
                ];

                // update bounty storage
                bountyRecord.currentApprovedApplicants  := Map.remove(applicant, bountyRecord.currentApprovedApplicants);
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