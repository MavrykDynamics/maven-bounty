// ------------------------------------------------------------------------------
//
// Launchpad Lambdas Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Admin Lambdas Begin
// ------------------------------------------------------------------------------

(*  setSuperAdmin lambda *)
function lambdaSetSuperAdmin(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 
    
    case launchpadLambdaAction of [
        |   LambdaSetSuperAdmin(newAdminAddress) -> {
                s.newSuperAdmin := Some(newAdminAddress);
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  claimSuperAdmin lambda *)
function lambdaClaimSuperAdmin(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 
    
    case launchpadLambdaAction of [
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
function lambdaSetAdmin(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 
    
    case launchpadLambdaAction of [
        |   LambdaSetAdmin(newAdminAddress) -> {
                s.admins := Set.add(newAdminAddress, s.admins);
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  removeAdmin lambda *)
function lambdaRemoveAdmin(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 
    
    case launchpadLambdaAction of [
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
function lambdaUpdateMetadata(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {
    
    // verify that sender is admin (i.e. Governance Proxy Contract address)
    verifySenderIsAdmin(s.admins); 

    case launchpadLambdaAction of [
        |   LambdaUpdateMetadata(updateMetadataParams) -> {
                
                const metadataKey   : string = updateMetadataParams.metadataKey;
                const metadataHash  : bytes  = updateMetadataParams.metadataHash;
                
                s.metadata[metadataKey] := metadataHash;
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* updateConfig lambda *)
function lambdaUpdateConfig(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is 
block {

    // verify that sender is admin (i.e. Governance Proxy Contract address)
    verifySenderIsAdmin(s.admins); 

    case launchpadLambdaAction of [
        |   LambdaUpdateConfig(updateConfigParams) -> {
                
                const updateConfigAction    : launchpadUpdateConfigActionType   = updateConfigParams.updateConfigAction;
                const updateConfigNewValue  : launchpadUpdateConfigNewValueType = updateConfigParams.updateConfigNewValue;

                case updateConfigAction of [
                    |   ConfigMinOfferAmount (_v)  -> s.config.minOfferAmount         := updateConfigNewValue
                    |   _ -> skip
                ];
            }
        |   _ -> skip
    ];
  
} with (noOperations, s)



(*  updateWhitelistContracts lambda *)
function lambdaUpdateWhitelistContracts(const launchpadLambdaAction : launchpadLambdaActionType; var s: launchpadStorageType) : return is
block {

    // verify that sender is admin
    verifySenderIsAdmin(s.admins); 

    case launchpadLambdaAction of [
        |   LambdaUpdateWhitelistContracts(updateWhitelistContractsParams) -> {
                s.whitelistContracts := updateWhitelistContractsMap(updateWhitelistContractsParams, s.whitelistContracts);
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  updateGeneralContracts lambda *)
function lambdaUpdateGeneralContracts(const launchpadLambdaAction : launchpadLambdaActionType; var s: launchpadStorageType) : return is
block {

    // verify that sender is admin (i.e. Governance Proxy Contract address)
    verifySenderIsAdmin(s.admins); 

    case launchpadLambdaAction of [
        |   LambdaUpdateGeneralContracts(updateGeneralContractsParams) -> {
                s.generalContracts := updateGeneralContractsMap(updateGeneralContractsParams, s.generalContracts);
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  mistaken lambda *)
function lambdaMistakenTransfer(const launchpadLambdaAction : launchpadLambdaActionType; var s: launchpadStorageType) : return is
block {

    var operations : list(operation) := nil;

    case launchpadLambdaAction of [
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
// Launchpad Lambdas Begin
// ------------------------------------------------------------------------------

(* createTokenLaunch lambda *)
function lambdaCreateTokenLaunch(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 
    
    case launchpadLambdaAction of [
        |   LambdaCreateTokenLaunch(createTokenLaunchParams) -> {

                // init create params
                const name                      : string                            = createTokenLaunchParams.name;
                const tokenIssuanceType         : string                            = createTokenLaunchParams.tokenIssuanceType;
                const tokenDistributionType     : string                            = createTokenLaunchParams.tokenDistributionType;
                const tokenContractAddress      : address                           = createTokenLaunchParams.tokenContractAddress;
                const tokenId                   : nat                               = createTokenLaunchParams.tokenId;
                const maxAmountCap              : nat                               = createTokenLaunchParams.maxAmountCap;
                const saleStart                 : timestamp                         = createTokenLaunchParams.saleStart;
                const saleEnd                   : option(timestamp)                 = createTokenLaunchParams.saleEnd;
                const whitelistSaleStart        : option(timestamp)                 = createTokenLaunchParams.whitelistSaleStart;
                const whitelistSaleEnd          : option(timestamp)                 = createTokenLaunchParams.whitelistSaleEnd;
                const saleOptions               : map(string, tokenSaleOptionType)  = createTokenLaunchParams.saleOptions;
                const defaultWhitelistOptions   : map(string, nat)                  = createTokenLaunchParams.defaultWhitelistOptions;

                // init storage params
                const lastLaunchId              : nat = s.lastLaunchId;

                verifyValidTokenIssuanceType(tokenIssuanceType);

                verifyValidTokenDistributionType(tokenDistributionType);

                verifyValidSaleEnd(saleStart, saleEnd);

                verifyValidWhitelistSaleEnd(whitelistSaleStart, whitelistSaleEnd);

                // create launchRecord
                const launchRecord : launchRecordType = record [
                    name                        = name;
                    isPaused                    = False;
                    status                      = "INACTIVE";
                    tokenIssuanceType           = tokenIssuanceType;
                    tokenDistributionType       = tokenDistributionType;
                    tokenContractAddress        = tokenContractAddress;
                    tokenId                     = tokenId;
                    maxAmountCap                = maxAmountCap;
                    totalBought                 = 0n;
                    saleStart                   = saleStart;
                    saleEnd                     = saleEnd;
                    saleClosed                  = (None : option(timestamp));
                    whitelistSaleStart          = whitelistSaleStart;
                    whitelistSaleEnd            = whitelistSaleEnd;
                    saleOptions                 = saleOptions;
                    defaultWhitelistOptions     = defaultWhitelistOptions;
                ];

                // update storage
                s.launchLedger[lastLaunchId]   := launchRecord;
                s.lastLaunchId                 := lastLaunchId + 1n;

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* setLaunchWhitelist lambda *)
function lambdaSetLaunchWhitelist(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 
    
    case launchpadLambdaAction of [
        |   LambdaSetLaunchWhitelist(launchWhitelist) -> {

                for whitelistUser in list launchWhitelist block {

                    // init params 
                    const launchId                  : nat               = whitelistUser.launchId;
                    const whitelistUserAddress      : address           = whitelistUser.whitelistUserAddress;
                    const defaultWhitelistOption    : bool              = whitelistUser.defaultWhitelistOption;
                    const whitelistOptions          : map(string, nat)  = case whitelistUser.whitelistOptions of [
                            Some(_option) -> _option
                        |   None          -> (map[] : map(string, nat))
                    ];

                    // get launch record
                    const launchRecord : launchRecordType = getLaunchRecord(launchId, s);

                    const whitelistUserKey : (nat * address) = (launchId, whitelistUserAddress);
                    var allowed : map(string, nat) := map[];
                    
                    // set allowed options
                    if defaultWhitelistOption = True then block {

                        allowed := launchRecord.defaultWhitelistOptions;

                    } else {

                        // verify that whitelist options exist
                        verifyValidCustomWhitelistOptions(whitelistOptions, launchRecord);
                        allowed := whitelistOptions;

                    };

                    const launchWhitelistRecord : launchWhitelistRecordType = record [
                        allowed = allowed;
                    ];

                    s.launchWhitelistLedger[whitelistUserKey] := launchWhitelistRecord;

                }

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* editTokenLaunch lambda *)
function lambdaEditTokenLaunch(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 
    
    case launchpadLambdaAction of [
        |   LambdaEditTokenLaunch(editTokenLaunchParams) -> {

                const launchId    : nat               = editTokenLaunchParams.launchId;
                var launchRecord  : launchRecordType := getLaunchRecord(launchId, s);

                // edit launch record if option found
                case editTokenLaunchParams.name of [
                        Some(_newName) -> launchRecord.name := _newName
                    |   None -> skip
                ];

                case editTokenLaunchParams.tokenIssuanceType of [
                        Some(_newIssuanceType) -> {
                            verifyValidTokenIssuanceType(_newIssuanceType);
                            launchRecord.tokenIssuanceType := _newIssuanceType
                        }
                    |   None -> skip
                ];

                case editTokenLaunchParams.tokenDistributionType of [
                        Some(_newDistributionType) -> {
                            verifyValidTokenDistributionType(_newDistributionType);
                            launchRecord.tokenDistributionType := _newDistributionType
                        }
                    |   None -> skip
                ];

                case editTokenLaunchParams.tokenContractAddress of [
                        Some(_newTokenContractAddress) -> launchRecord.tokenContractAddress := _newTokenContractAddress
                    |   None -> skip
                ];

                case editTokenLaunchParams.tokenId of [
                        Some(_newTokenId) -> launchRecord.tokenId := _newTokenId
                    |   None -> skip
                ];

                case editTokenLaunchParams.maxAmountCap of [
                        Some(_newMaxAmountCap) -> launchRecord.maxAmountCap := _newMaxAmountCap
                    |   None -> skip
                ];

                case editTokenLaunchParams.totalBought of [
                        Some(_newTotalBought) -> launchRecord.totalBought := _newTotalBought
                    |   None -> skip
                ];

                case editTokenLaunchParams.saleStart of [
                        Some(_newSaleStart) -> launchRecord.saleStart := _newSaleStart
                    |   None -> skip
                ];

                case editTokenLaunchParams.saleEnd of [
                        Some(_newSaleEnd) -> {

                            // check that new sale end comes after sale start 
                            case editTokenLaunchParams.saleStart of [
                                    Some(_newSaleStart) -> if _newSaleEnd < _newSaleStart then failwith(error_SALE_END_SHOULD_BE_AFTER_SALE_START) else skip
                                |   None -> if _newSaleEnd < launchRecord.saleStart then failwith(error_SALE_END_SHOULD_BE_AFTER_SALE_START) else skip
                            ];

                            launchRecord.saleEnd := Some(_newSaleEnd)
                        }
                    |   None -> skip
                ];

                case editTokenLaunchParams.whitelistSaleStart of [
                        Some(_newWhitelistSaleStart) -> launchRecord.whitelistSaleStart := Some(_newWhitelistSaleStart)
                    |   None -> skip
                ];

                case editTokenLaunchParams.whitelistSaleEnd of [
                        Some(_newWhitelistSaleEnd) -> {

                            // check that new whitelist sale end comes after whitelist sale start 
                            case editTokenLaunchParams.whitelistSaleStart of [
                                    Some(_newWhitelistSaleStart) -> if _newWhitelistSaleEnd < _newWhitelistSaleStart then failwith(error_WHITELIST_SALE_END_SHOULD_BE_AFTER_WHITELIST_SALE_START) else skip
                                |   None -> {

                                        case launchRecord.whitelistSaleStart of [
                                                Some(_currentWhitelistSaleStart) -> if _newWhitelistSaleEnd < _currentWhitelistSaleStart then failwith(error_WHITELIST_SALE_END_SHOULD_BE_AFTER_WHITELIST_SALE_START) else skip
                                            |   None -> failwith(error_WHITELIST_SALE_START_NOT_SPECIFIED)
                                        ]    
                                    }
                            ];

                            launchRecord.whitelistSaleEnd := Some(_newWhitelistSaleEnd)
                        }
                    |   None -> skip
                ];

                case editTokenLaunchParams.saleOptions of [
                        Some(_newSaleOptions) -> launchRecord.saleOptions := _newSaleOptions
                    |   None -> skip
                ];

                case editTokenLaunchParams.defaultWhitelistOptions of [
                        Some(_newDefaultWhitelistOptions) -> launchRecord.defaultWhitelistOptions := _newDefaultWhitelistOptions
                    |   None -> skip
                ];

                // update storage
                s.launchLedger[launchId] := launchRecord;

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* editSaleOption lambda *)
function lambdaEditSaleOption(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 
    
    case launchpadLambdaAction of [
        |   LambdaEditSaleOption(editSaleOption) -> {

                case editSaleOption of [
                    |   SetNewSaleOption(_setSaleOptionParams) -> {

                            const launchId        : nat               = _setSaleOptionParams.launchId;
                            const saleOptionName  : string            = _setSaleOptionParams.saleOption;
                            var launchRecord      : launchRecordType := getLaunchRecord(launchId, s);

                            const whitelistOnly   : bool    = case _setSaleOptionParams.whitelistOnly of [
                                    Some(_v) -> _v
                                |   None -> False
                            ];

                            // add new sale option
                            launchRecord.saleOptions[saleOptionName] := case launchRecord.saleOptions[saleOptionName] of [
                                    Some(_v) -> failwith(error_SALE_OPTION_ALREADY_EXISTS)
                                |   None -> record [
                                        totalBought             = 0n;
                                        maxAmountCap            = _setSaleOptionParams.maxAmountCap;
                                        minPurchaseAmount       = _setSaleOptionParams.minPurchaseAmount;
                                        maxAmountPerWalletTotal = _setSaleOptionParams.maxAmountPerWalletTotal;
                                        whitelistOnly           = whitelistOnly;
                                        payments                = _setSaleOptionParams.payments;
                                ]
                            ];

                            // update storage
                            s.launchLedger[launchId] := launchRecord;

                        }
                    |   UpdateSaleOption(_updateSaleOptionParams) -> {
                         
                            const launchId        : nat               = _updateSaleOptionParams.launchId;
                            const saleOptionName  : string            = _updateSaleOptionParams.saleOption;
                            var launchRecord      : launchRecordType := getLaunchRecord(launchId, s);

                            // update existing sale option
                            var saleOption : tokenSaleOptionType := case launchRecord.saleOptions[saleOptionName] of [
                                    Some(_record) -> _record
                                |   None -> failwith(error_SALE_OPTION_NOT_FOUND)
                            ];

                            case _updateSaleOptionParams.totalBought of [
                                    Some(_newTotalBought) -> saleOption.totalBought := _newTotalBought
                                |   None -> skip
                            ];

                            case _updateSaleOptionParams.maxAmountCap of [
                                    Some(_newMaxAmountCap) -> saleOption.maxAmountCap := Some(_newMaxAmountCap)
                                |   None -> skip
                            ];

                            case _updateSaleOptionParams.minPurchaseAmount of [
                                    Some(_newMinPurchaseAmount) -> saleOption.minPurchaseAmount := Some(_newMinPurchaseAmount)
                                |   None -> skip
                            ];

                            case _updateSaleOptionParams.maxAmountPerWalletTotal of [
                                    Some(_newMaxAmountPerWalletTotal) -> saleOption.maxAmountPerWalletTotal := Some(_newMaxAmountPerWalletTotal)
                                |   None -> skip
                            ];

                            case _updateSaleOptionParams.whitelistOnly of [
                                    Some(_newWhitelistOnly) -> saleOption.whitelistOnly := _newWhitelistOnly
                                |   None -> skip
                            ];

                            case _updateSaleOptionParams.payments of [
                                    Some(_newPayments) -> saleOption.payments := _newPayments
                                |   None -> skip
                            ];
                            
                            // update storage
                            launchRecord.saleOptions[saleOptionName] := saleOption;
                            s.launchLedger[launchId] := launchRecord;

                        }
                ];


            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* startLaunch lambda *)
function lambdaStartLaunch(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 
    
    case launchpadLambdaAction of [
        |   LambdaStartLaunch(launchId) -> {

                // get launch record
                var launchRecord : launchRecordType := getLaunchRecord(launchId, s);

                launchRecord.status       := "ACTIVE";
                launchRecord.saleClosed   := (None : option(timestamp));
                s.launchLedger[launchId]  := launchRecord;

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* pauseLaunch lambda *)
function lambdaPauseLaunch(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 
    
    case launchpadLambdaAction of [
        |   LambdaPauseLaunch(launchId) -> {

                // get launch record
                var launchRecord : launchRecordType := getLaunchRecord(launchId, s);

                if launchRecord.status = "ACTIVE" then skip else failwith(error_LAUNCH_IS_NOT_ACTIVE);

                launchRecord.status       := "PAUSED";
                launchRecord.isPaused     := True;
                s.launchLedger[launchId]  := launchRecord;

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* unpauseLaunch lambda *)
function lambdaUnpauseLaunch(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 
    
    case launchpadLambdaAction of [
        |   LambdaUnpauseLaunch(launchId) -> {

                var launchRecord : launchRecordType := getLaunchRecord(launchId, s);

                if launchRecord.status = "PAUSED" then skip else failwith(error_LAUNCH_IS_NOT_PAUSED);

                launchRecord.status       := "ACTIVE";
                launchRecord.isPaused     := False;
                s.launchLedger[launchId]  := launchRecord;                

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* closeLaunch lambda *)
function lambdaCloseLaunch(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 
    
    case launchpadLambdaAction of [
        |   LambdaCloseLaunch(launchId) -> {

                var launchRecord : launchRecordType := case s.launchLedger[launchId] of [
                        Some(_record) -> _record
                    |   None          -> failwith(error_LAUNCH_RECORD_NOT_FOUND)
                ];

                launchRecord.status       := "CLOSED";
                launchRecord.saleClosed   := Some(Tezos.get_now());
                s.launchLedger[launchId]  := launchRecord;      

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* distributeTokens lambda *)
function lambdaDistributeTokens(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 

    var operations : list(operation) := nil;
    
    case launchpadLambdaAction of [
        |   LambdaDistributeTokens(distributeTokensParams) -> {

                // get treasury address
                const treasuryAddress : address = getAddressFromGeneralContracts("treasury", s, error_TREASURY_NOT_FOUND);

                for distributeToken in list distributeTokensParams block {

                    const userAddress   : address   = distributeToken.userAddress;
                    const launchId      : nat       = distributeToken.launchId;

                    // create launch user key
                    const launchUserKey  : (nat * address) = (launchId, userAddress);

                    // get launch record
                    const launchRecord : launchRecordType = getLaunchRecord(launchId, s);

                    const tokenId                : nat      = launchRecord.tokenId;
                    const tokenContractAddress   : address  = launchRecord.tokenContractAddress;
                    const tokenIssuanceType      : string   = launchRecord.tokenIssuanceType;

                    // get user purchase record
                    var userPurchaseRecord : purchaseRecordType := getOrCreatePurchaseRecord(launchUserKey, s);

                    const totalPurchased : nat = userPurchaseRecord.totalPurchased;
                    const totalDistributed : nat = userPurchaseRecord.totalDistributed;

                    if totalPurchased > 0n then block {

                        const amountToDistribute : nat = abs(totalPurchased - totalDistributed);

                        // process token issuance - MINT or TRANSFER
                        operations := processTokenIssuance(
                            tokenIssuanceType,
                            treasuryAddress,
                            userAddress,
                            amountToDistribute,
                            tokenId,
                            tokenContractAddress,
                            operations
                        );

                        // update user purchase record : total distributed
                        userPurchaseRecord.totalDistributed  := userPurchaseRecord.totalDistributed + amountToDistribute;
                        s.purchaseLedger[launchUserKey]      := userPurchaseRecord;

                    } else skip;

                }

            }
        |   _ -> skip
    ];

} with (operations, s)

// ------------------------------------------------------------------------------
// Launchpad Lambdas End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Pause / Break Glass Lambdas Begin
// ------------------------------------------------------------------------------

(*  pauseAll lambda *)
function lambdaPauseAll(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 

    case launchpadLambdaAction of [
        |   LambdaPauseAll(_parameters) -> {
              
                // set all pause configs to True
                s := pauseAllLaunchpadEntrypoints(s);
              
            }
        |   _ -> skip
    ];  

} with (noOperations, s)



(*  unpauseAll lambda *)
function lambdaUnpauseAll(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 

    case launchpadLambdaAction of [
        |   LambdaUnpauseAll(_parameters) -> {
                
                // set all pause configs to False
                s := unpauseAllLaunchpadEntrypoints(s);
              
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  togglePauseEntrypoint lambda *)
function lambdaTogglePauseEntrypoint(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifyNoAmountSent(Unit);     // entrypoint should not receive any tez amount  
    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 

    case launchpadLambdaAction of [
        |   LambdaTogglePauseEntrypoint(params) -> {

                case params.targetEntrypoint of [
                        CreateTokenLaunch (_v)        -> s.breakGlassConfig.createTokenLaunchIsPaused       := _v
                    |   StartLaunch (_v)              -> s.breakGlassConfig.startLaunchIsPaused             := _v
                    |   SetLaunchWhitelist (_v)       -> s.breakGlassConfig.setLaunchWhitelistIsPaused      := _v
                    |   EditTokenLaunch (_v)          -> s.breakGlassConfig.editTokenLaunchIsPaused         := _v
                    |   CloseLaunch (_v)              -> s.breakGlassConfig.closeLaunchIsPaused             := _v
                    |   PauseLaunch (_v)              -> s.breakGlassConfig.pauseLaunchIsPaused             := _v
                    |   UnpauseLaunch (_v)            -> s.breakGlassConfig.unpauseLaunchIsPaused           := _v
                    |   DistributeTokens (_v)         -> s.breakGlassConfig.distributeTokensIsPaused        := _v
                    |   Purchase (_v)                 -> s.breakGlassConfig.purchaseIsPaused                := _v
                ]
                
            }
        |   _ -> skip
    ];

} with (noOperations, s)

// ------------------------------------------------------------------------------
// Pause / Break Glass Lambdas End
// ------------------------------------------------------------------------------




// ------------------------------------------------------------------------------
// User Lambdas Begin
// ------------------------------------------------------------------------------

(* purchase lambda *)
function lambdaPurchase(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    var operations : list(operation) := nil;
    
    case launchpadLambdaAction of [
        |   LambdaPurchase(purchaseParams) -> {

                // init params
                const sender            : address   = Tezos.get_sender();
                const launchId          : nat       = purchaseParams.launchId;
                const amount            : nat       = purchaseParams.amount;
                const saleOptionName    : string    = purchaseParams.saleOption;
                const paymentName       : string    = purchaseParams.payment;
                
                // create launch user key
                const launchUserKey     : (nat * address) = (launchId, sender);

                // get launch record
                var launchRecord : launchRecordType := getLaunchRecord(launchId, s);

                const tokenId                : nat      = launchRecord.tokenId;
                const tokenContractAddress   : address  = launchRecord.tokenContractAddress;
                const tokenIssuanceType      : string   = launchRecord.tokenIssuanceType;
                const tokenDistributionType  : string   = launchRecord.tokenDistributionType;
                const launchMaxAmountCap     : nat      = launchRecord.maxAmountCap;

                // verify launch is active
                verifyLaunchIsActive(launchRecord.status);

                // verify launch has not ended
                verifyLaunchHasNotEnded(launchRecord.saleEnd);

                // check if current period is in whitelist period
                var inWhitelistPeriod : bool := False;
                const _whitelistSaleStart : timestamp = case launchRecord.whitelistSaleStart of [
                        Some(_whitelistSaleStartTimestamp) -> {

                            // check whitelist sale start timestamp 
                            if Tezos.get_now() > _whitelistSaleStartTimestamp then inWhitelistPeriod := True else skip;

                            // check if whitelist sale end timestamp has passed
                            case launchRecord.whitelistSaleEnd of [
                                    Some(_whitelistSaleEndTimestamp) -> {
                                        if Tezos.get_now() > _whitelistSaleEndTimestamp then inWhitelistPeriod := False else skip;
                                    }
                                |   None -> skip
                            ];

                        } with _whitelistSaleStartTimestamp
                    |   None     -> zeroTimestamp
                ];

                // check if current period is after sale start
                const saleStarted : bool = if Tezos.get_now() > launchRecord.saleStart then True else False;

                // get sale option
                var saleOption : tokenSaleOptionType := getSaleOption(launchRecord, saleOptionName);
                const saleOptionWhitelistOnly : bool = saleOption.whitelistOnly;

                // get sale option total bought amount
                const saleOptionTotalBought   : nat       = saleOption.totalBought;
                const launchTotalBought       : nat       = launchRecord.totalBought;
                
                // verify token sale option max amount cap not exceeded if it exists
                case saleOption.maxAmountCap of [
                        Some(_saleOptionMaxAmountCap) -> if (saleOptionTotalBought + amount) > _saleOptionMaxAmountCap then failwith(error_MAX_AMOUNT_CAP_FOR_SALE_OPTION_EXCEEDED) else skip
                    |   None -> skip
                ];

                // verify launch max amount cap not exceeded
                if (saleOptionTotalBought + amount) > launchMaxAmountCap then failwith(error_MAX_AMOUNT_CAP_FOR_LAUNCH_EXCEEDED) else skip;
                if (launchTotalBought + amount) > launchMaxAmountCap then failwith(error_MAX_AMOUNT_CAP_FOR_LAUNCH_EXCEEDED) else skip;

                // verify amount bought is greater than minPurchaseAmount if it exists
                case saleOption.minPurchaseAmount of [
                        Some(_minPurchaseAmount) -> if amount < _minPurchaseAmount then failwith(error_AMOUNT_BOUGHT_MUST_EXCEED_MIN_PURCHASE_AMOUNT) else skip
                    |   None -> skip
                ];

                // get payment variables - price and currency
                const payment : paymentType = case saleOption.payments[paymentName] of [
                        Some(_record) -> _record
                    |   None          -> failwith(error_PAYMENT_OPTION_NOT_FOUND)
                ];
                const price         : nat       = payment.price;
                const currency      : tokenType = payment.currency;

                // get total purchased of user
                var userPurchaseRecord : purchaseRecordType := getOrCreatePurchaseRecord(launchUserKey, s);

                // get total purchased of user for this particular sale option
                var userSaleOptionPurchased : nat := case userPurchaseRecord.purchased[saleOptionName] of [
                        Some(_amount) -> _amount
                    |   None          -> 0n
                ];

                // calc final amount purchased for user
                const finalSaleOptionPurchasedTotal : nat = userSaleOptionPurchased + amount;

                // check that max amount per wallet total is not exceeded for this sale option
                // note: maxAmountPerWalletTotal takes precedence over userWhitelistAllowedAmount
                case saleOption.maxAmountPerWalletTotal of [
                        Some(_maxAmount) -> if finalSaleOptionPurchasedTotal > _maxAmount then failwith(error_MAX_AMOUNT_PER_WALLET_FOR_SALE_OPTION_TOTAL_EXCEEDED) else skip
                    |   None -> skip
                ];


                // check if sale has started
                if saleStarted = True then block {

                    // check if sale option is only for whitelist 
                    if saleOptionWhitelistOnly = True then block {

                        // check if user is whitelisted
                        const userLaunchWhitelistRecord : launchWhitelistRecordType = case s.launchWhitelistLedger[launchUserKey] of [
                                Some(_record) -> _record
                            |   None -> failwith(error_USER_WHITELIST_RECORD_NOT_FOUND)
                        ];

                        const userWhitelistAllowedAmount : nat = case userLaunchWhitelistRecord.allowed[saleOptionName] of [
                                Some(_amount) -> _amount
                            |   None -> 0n
                        ];

                        // check that userWhitelistAllowedAmount is not exceeded
                        if (userSaleOptionPurchased + amount) > userWhitelistAllowedAmount then failwith(error_USER_WHITELIST_ALLOWED_AMOUNT_EXCEEDED) else skip;

                    } else skip;

                } else if inWhitelistPeriod = True then block {

                    // check if in whitelist period

                    // inWhitelistPeriod: True
                    // check if user is whitelisted
                    const userLaunchWhitelistRecord : launchWhitelistRecordType = case s.launchWhitelistLedger[launchUserKey] of [
                            Some(_record) -> _record
                        |   None -> failwith(error_USER_WHITELIST_RECORD_NOT_FOUND)
                    ];

                    const userWhitelistAllowedAmount : nat = case userLaunchWhitelistRecord.allowed[saleOptionName] of [
                            Some(_amount) -> _amount
                        |   None -> 0n
                    ];

                    // check that userWhitelistAllowedAmount is not exceeded
                    if (userSaleOptionPurchased + amount) > userWhitelistAllowedAmount then failwith(error_USER_WHITELIST_ALLOWED_AMOUNT_EXCEEDED) else skip;

                } else {
                    
                    // inWhitelistPeriod: False
                    // check if main sale timestamp has started
                    if Tezos.get_now() < launchRecord.saleStart then failwith(error_SALE_HAS_NOT_STARTED) else skip;

                };
                
                // get treasury address
                const treasuryAddress : address = getAddressFromGeneralContracts("treasury", s, error_TREASURY_NOT_FOUND);

                // calc total price (price * (amount to be purchased / 10e6))
                const totalPrice : nat = (price * (amount * fixedPointAccuracy / 1000000n)) / fixedPointAccuracy; 

                // proceed with payment
                case currency of [
                        Tez             -> {
                            operations := transferTez((Tezos.get_contract_with_error(treasuryAddress, "Error. Contract not found at given address") : contract(unit)), totalPrice * 1mutez) # operations;
                        } 
                    |   Fa12(_address)  -> {
                            operations := transferFa12Token(sender, treasuryAddress, totalPrice, _address) # operations;
                        }
                    |   Fa2(_fa2Token)  -> {
                            operations := transferFa2Token(sender, treasuryAddress, totalPrice, _fa2Token.tokenId, _fa2Token.tokenContractAddress) # operations;
                        }
                ];

                // update user sale purchase ledger
                userPurchaseRecord.purchased[saleOptionName]    := finalSaleOptionPurchasedTotal;
                userPurchaseRecord.totalPurchased               := userPurchaseRecord.totalPurchased + amount;
                s.purchaseLedger[launchUserKey]                 := userPurchaseRecord;

                // update sale option
                saleOption.totalBought                          := saleOption.totalBought + amount;
                launchRecord.saleOptions[saleOptionName]        := saleOption;

                // update launch record
                launchRecord.totalBought                        := launchRecord.totalBought + amount;

                // update sale record
                s.launchLedger[launchId]                        := launchRecord;

                if tokenDistributionType = "MANUAL" then skip 
                else if tokenDistributionType = "AUTO" then block {

                    // process token issuance - MINT or TRANSFER
                    operations := processTokenIssuance(
                        tokenIssuanceType,
                        treasuryAddress,
                        sender,
                        amount,
                        tokenId,
                        tokenContractAddress,
                        operations
                    );

                    // update user purchase record : total distributed
                    userPurchaseRecord.totalDistributed  := userPurchaseRecord.totalDistributed + amount;
                    s.purchaseLedger[launchUserKey]      := userPurchaseRecord;

                };
            

            }
        |   _ -> skip
    ];

} with (operations, s)

// ------------------------------------------------------------------------------
// User Lambdas End
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
//
// Launchpad Lambdas End
//
// ------------------------------------------------------------------------------
