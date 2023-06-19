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
                const saleStart                 : timestamp                         = createTokenLaunchParams.saleStart;
                const saleEnd                   : option(timestamp)                 = createTokenLaunchParams.saleEnd;
                const saleOptions               : map(string, tokenSaleOptionType)  = createTokenLaunchParams.saleOptions;
                const defaultWhitelistOptions   : map(string, nat)                  = createTokenLaunchParams.defaultWhitelistOptions;

                // init storage params
                const lastLaunchId              : nat = s.lastLaunchId;

                verifyValidTokenIssuanceType(tokenIssuanceType);

                verifyValidTokenDistributionType(tokenDistributionType);

                // create launchRecord
                const launchRecord : launchRecordType = record [
                    name                        = name;
                    isPaused                    = False;
                    status                      = "INACTIVE";
                    tokenIssuanceType           = tokenIssuanceType;
                    tokenDistributionType       = tokenDistributionType;
                    tokenContractAddress        = tokenContractAddress;
                    tokenId                     = tokenId;
                    saleStart                   = saleStart;
                    saleEnd                     = saleEnd;
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
                    const launchRecord : launchRecordType = case s.launchLedger[launchId] of [
                            Some(_record) -> _record
                        |   None          -> failwith(error_LAUNCH_RECORD_NOT_FOUND)
                    ];

                    const whitelistUserKey : (nat * address) = (launchId, whitelistUserAddress);
                    var allowed : map(string, nat) := map[];
                    
                    // set allowed options
                    if defaultWhitelistOption = True then block {
                        allowed := launchRecord.defaultWhitelistOptions;
                    } else {
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

                const launchId                  : nat                               = editTokenLaunchParams.launchId;
                var launchRecord : launchRecordType := case s.launchLedger[launchId] of [
                            Some(_record) -> _record
                        |   None          -> failwith(error_LAUNCH_RECORD_NOT_FOUND)
                    ];

                // edit launch record if option found
                case editTokenLaunchParams.name of [
                        Some(_newName) -> launchRecord.name := _newName
                    |   None -> skip
                ];

                case editTokenLaunchParams.tokenIssuanceType of [
                        Some(_newIssuanceType) -> launchRecord.tokenIssuanceType := _newIssuanceType
                    |   None -> skip
                ];

                case editTokenLaunchParams.tokenDistributionType of [
                        Some(_newDistributionType) -> launchRecord.tokenDistributionType := _newDistributionType
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

                case editTokenLaunchParams.saleStart of [
                        Some(_newSaleStart) -> launchRecord.saleStart := _newSaleStart
                    |   None -> skip
                ];

                case editTokenLaunchParams.saleEnd of [
                        Some(_newSaleEnd) -> launchRecord.saleEnd := Some(_newSaleEnd)
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



(* startLaunch lambda *)
function lambdaStartLaunch(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 
    
    case launchpadLambdaAction of [
        |   LambdaStartLaunch(launchId) -> {

                // get launch record
                var launchRecord : launchRecordType := case s.launchLedger[launchId] of [
                        Some(_record) -> _record
                    |   None          -> failwith(error_LAUNCH_RECORD_NOT_FOUND)
                ];

                launchRecord.status := "ACTIVE";
                
                // reset sale end if it has been closed
                const currentSaleEnd : timestamp = case launchRecord.saleEnd of [
                        Some(_timestamp) -> _timestamp
                    |   None             -> zeroTimestamp
                ];
                if Tezos.get_now() > currentSaleEnd then launchRecord.saleEnd := (None : option(timestamp)) else skip;

                s.launchLedger[launchId] := launchRecord;

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
                var launchRecord : launchRecordType := case s.launchLedger[launchId] of [
                        Some(_record) -> _record
                    |   None          -> failwith(error_LAUNCH_RECORD_NOT_FOUND)
                ];

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

                var launchRecord : launchRecordType := case s.launchLedger[launchId] of [
                        Some(_record) -> _record
                    |   None          -> failwith(error_LAUNCH_RECORD_NOT_FOUND)
                ];

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
                launchRecord.saleEnd      := Some(Tezos.get_now());
                s.launchLedger[launchId]  := launchRecord;      

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* distributeTokens lambda *)
function lambdaDistributeTokens(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 
    
    case launchpadLambdaAction of [
        |   LambdaDistributeTokens(_distributeTokensParams) -> {

                skip

            }
        |   _ -> skip
    ];

} with (noOperations, s)

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
                
                // create sale user key
                const saleUserKey   : (nat * address) = (launchId, sender);

                // get launch record
                var launchRecord : launchRecordType := case s.launchLedger[launchId] of [
                        Some(_record) -> _record
                    |   None          -> failwith(error_LAUNCH_RECORD_NOT_FOUND)
                ];

                const tokenId                : nat      = launchRecord.tokenId;
                const tokenContractAddress   : address  = launchRecord.tokenContractAddress;
                const tokenIssuanceType      : string   = launchRecord.tokenIssuanceType;
                const tokenDistributionType  : string   = launchRecord.tokenDistributionType;

                // verify launch is active
                verifyLaunchIsActive(launchRecord.status);

                // get sale option
                var saleOption : tokenSaleOptionType := case launchRecord.saleOptions[saleOptionName] of [
                        Some(_saleOption) -> _saleOption
                    |   None              -> failwith(error_SALE_OPTION_NOT_FOUND)
                ];

                // get sale option params
                const maxAmountCap  : nat       = saleOption.maxAmountCap;
                const totalBought   : nat       = saleOption.totalBought;
                const price         : nat       = saleOption.price;
                const currency      : tokenType = saleOption.currency;

                // check that final total bought amount does not exceed max amount cap
                if (totalBought + amount) > maxAmountCap then failwith(error_MAX_AMOUNT_CAP_FOR_SALE_OPTION_EXCEEDED) else skip;

                // get total purchased of user
                var userPurchaseRecord : purchaseRecordType := case s.purchaseLedger[saleUserKey] of [
                        Some(_purchaseRecord) -> _purchaseRecord
                    |   None -> record [
                            purchased       = (map[] : map(string, nat));
                            totalPurchased  = 0n;
                        ]
                ];

                // get total purchased of user for this particular sale option
                var userSaleOptionPurchased : nat := case userPurchaseRecord.purchased[saleOptionName] of [
                        Some(_amount) -> _amount
                    |   None          -> 0n
                ];

                // calc final amount purchased for user
                const finalSaleOptionPurchasedTotal : nat = userSaleOptionPurchased + amount;

                // check that max amount per wallet total is not exceeded for this sale option
                case saleOption.maxAmountPerWalletTotal of [
                        Some(_maxAmount) -> if finalSaleOptionPurchasedTotal > _maxAmount then failwith(error_MAX_AMOUNT_PER_WALLET_FOR_SALE_OPTION_TOTAL_EXCEEDED) else skip
                    |   None -> skip
                ];

                // get treasury address
                const treasuryAddress : address = getAddressFromGeneralContracts("treasury", s, error_TREASURY_NOT_FOUND);

                // calc total price (amount to be purchased * price)
                const totalPrice : nat = amount * price; 

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
                s.purchaseLedger[saleUserKey]                   := userPurchaseRecord;

                // update sale option
                saleOption.totalBought                              := saleOption.totalBought + amount;
                launchRecord.saleOptions[saleOptionName]            := saleOption;

                // update sale record
                s.launchLedger[launchId]                            := launchRecord;

                // transfer or mint if tokenDistributionType is AUTO
                if tokenDistributionType = "MANUAL" then skip 
                else if tokenDistributionType = "AUTO" then block {

                    if tokenIssuanceType = "TRANSFER" then block {

                        const transferOperation : operation = transferFa2Token(
                            treasuryAddress,        // from_
                            sender,                 // to_
                            amount,                 // amount
                            tokenId,                // tokenId
                            tokenContractAddress    // tokenContractAddress
                        );
                        operations := transferOperation # operations;

                    } else if tokenIssuanceType = "MINT" then block {

                        const mintOperation : operation = mintFa2Token(
                            sender,                 // to_
                            amount,                 // amount
                            tokenId,                // tokenId
                            tokenContractAddress    // tokenContractAddress
                        );
                        operations := mintOperation # operations;

                    };

                };

            }
        |   _ -> skip
    ];

} with (noOperations, s)

// ------------------------------------------------------------------------------
// User Lambdas End
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
//
// Launchpad Lambdas End
//
// ------------------------------------------------------------------------------
