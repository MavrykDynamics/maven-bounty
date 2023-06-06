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

(* createTokenSale lambda *)
function lambdaCreateTokenSale(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 
    
    case launchpadLambdaAction of [
        |   LambdaCreateTokenSale(createTokenSaleParams) -> {

                // init create params
                const name                      : string                            = createTokenSaleParams.name;
                const tokenIssuanceType         : string                            = createTokenSaleParams.tokenIssuanceType;
                const tokenDistributionType     : string                            = createTokenSaleParams.tokenDistributionType;
                const tokenContractAddress      : address                           = createTokenSaleParams.tokenContractAddress;
                const tokenId                   : nat                               = createTokenSaleParams.tokenId;
                const saleStart                 : timestamp                         = createTokenSaleParams.saleStart;
                const saleEnd                   : option(timestamp)                 = createTokenSaleParams.saleEnd;
                const saleOptions               : map(string, tokenSaleOptionType)  = createTokenSaleParams.saleOptions;
                const defaultWhitelistOptions   : map(string, nat)                  = createTokenSaleParams.defaultWhitelistOptions;

                // init storage params
                const lastSaleId                : nat = s.lastSaleId;

                // create saleRecord
                const saleRecord : saleRecordType = record [
                    name                        = name;
                    isPaused                    = False;
                    status                      = "ACTIVE";
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
                s.saleLedger[lastSaleId]    := saleRecord;
                s.lastSaleId                := lastSaleId + 1n;

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* setSaleWhitelist lambda *)
function lambdaSetSaleWhitelist(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 
    
    case launchpadLambdaAction of [
        |   LambdaSetSaleWhitelist(saleWhitelist) -> {

                for whitelistUser in list saleWhitelist block {

                    // init params 
                    const saleId                    : nat               = whitelistUser.saleId;
                    const whitelistUserAddress      : address           = whitelistUser.whitelistUserAddress;
                    const defaultWhitelistOption    : bool              = whitelistUser.defaultWhitelistOption;
                    const whitelistOptions          : map(string, nat)  = case whitelistUser.whitelistOptions of [
                            Some(_option) -> _option
                        |   None          -> (map[] : map(string, nat))
                    ];

                    // get sale record
                    const saleRecord : saleRecordType = case s.saleLedger[saleId] of [
                            Some(_record) -> _record
                        |   None          -> failwith(error_SALE_RECORD_NOT_FOUND)
                    ];

                    const whitelistUserKey : (nat * address) = (saleId, whitelistUserAddress);
                    var allowed : map(string, nat) := map[];
                    
                    // set allowed options
                    if defaultWhitelistOption = True then block {
                        allowed := saleRecord.defaultWhitelistOptions;
                    } else {
                        allowed := whitelistOptions;
                    };

                    const saleWhitelistRecord : saleWhitelistRecordType = record [
                        allowed = allowed;
                    ];

                    s.saleWhitelistLedger[whitelistUserKey] := saleWhitelistRecord;

                }

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* editSale lambda *)
function lambdaEditSale(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 
    
    case launchpadLambdaAction of [
        |   LambdaEditSale(_editSaleParams) -> {

                skip

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* startSale lambda *)
function lambdaStartSale(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 
    
    case launchpadLambdaAction of [
        |   LambdaStartSale(_startSaleParams) -> {

                skip

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* pauseSale lambda *)
function lambdaPauseSale(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 
    
    case launchpadLambdaAction of [
        |   LambdaPauseSale(saleId) -> {

                // get sale record
                var saleRecord : saleRecordType := case s.saleLedger[saleId] of [
                        Some(_record) -> _record
                    |   None          -> failwith(error_SALE_RECORD_NOT_FOUND)
                ];

                saleRecord.status       := "PAUSED";
                saleRecord.isPaused     := True;
                s.saleLedger[saleId]    := saleRecord;

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* unpauseSale lambda *)
function lambdaUnpauseSale(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 
    
    case launchpadLambdaAction of [
        |   LambdaUnpauseSale(saleId) -> {

                var saleRecord : saleRecordType := case s.saleLedger[saleId] of [
                        Some(_record) -> _record
                    |   None          -> failwith(error_SALE_RECORD_NOT_FOUND)
                ];

                saleRecord.status       := "ACTIVE";
                saleRecord.isPaused     := False;
                s.saleLedger[saleId]    := saleRecord;                

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* closeSale lambda *)
function lambdaCloseSale(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 
    
    case launchpadLambdaAction of [
        |   LambdaCloseSale(saleId) -> {

                var saleRecord : saleRecordType := case s.saleLedger[saleId] of [
                        Some(_record) -> _record
                    |   None          -> failwith(error_SALE_RECORD_NOT_FOUND)
                ];

                saleRecord.status       := "CLOSED";
                saleRecord.saleEnd      := Some(Tezos.get_now());
                s.saleLedger[saleId]    := saleRecord;      

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
                        CreateTokenSale (_v)        -> s.breakGlassConfig.createTokenSaleIsPaused       := _v
                    |   StartSale (_v)              -> s.breakGlassConfig.startSaleIsPaused             := _v
                    |   SetSaleWhitelist (_v)       -> s.breakGlassConfig.setSaleWhitelistIsPaused      := _v
                    |   EditSale (_v)               -> s.breakGlassConfig.editSaleIsPaused              := _v
                    |   CloseSale (_v)              -> s.breakGlassConfig.closeSaleIsPaused             := _v
                    |   PauseSale (_v)              -> s.breakGlassConfig.pauseSaleIsPaused             := _v
                    |   UnpauseSale (_v)            -> s.breakGlassConfig.unpauseSaleIsPaused           := _v
                    |   DistributeTokens (_v)       -> s.breakGlassConfig.distributeTokensIsPaused      := _v
                    |   Purchase (_v)               -> s.breakGlassConfig.purchaseIsPaused              := _v
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
                const saleId            : nat       = purchaseParams.saleId;
                const amount            : nat       = purchaseParams.amount;
                const saleOptionName    : string    = purchaseParams.saleOption;
                
                // create sale user key
                const saleUserKey   : (nat * address) = (saleId, sender);

                // get sale record
                var saleRecord : saleRecordType := case s.saleLedger[saleId] of [
                        Some(_record) -> _record
                    |   None          -> failwith(error_SALE_RECORD_NOT_FOUND)
                ];

                const tokenId                : nat      = saleRecord.tokenId;
                const tokenContractAddress   : address  = saleRecord.tokenContractAddress;
                const tokenIssuanceType      : string   = saleRecord.tokenIssuanceType;
                const tokenDistributionType  : string   = saleRecord.tokenDistributionType;

                // get sale option
                var saleOption : tokenSaleOptionType := case saleRecord.saleOptions[saleOptionName] of [
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
                var userSalePurchaseRecord : salePurchaseRecordType := case s.salePurchaseLedger[saleUserKey] of [
                        Some(_salePurchaseRecord) -> _salePurchaseRecord
                    |   None -> record [
                            purchased       = (map[] : map(string, nat));
                            totalPurchased  = 0n;
                        ]
                ];

                // get total purchased of user for this particular sale option
                var userSaleOptionPurchased : nat := case userSalePurchaseRecord.purchased[saleOptionName] of [
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
                userSalePurchaseRecord.purchased[saleOptionName]    := finalSaleOptionPurchasedTotal;
                userSalePurchaseRecord.totalPurchased               := userSalePurchaseRecord.totalPurchased + amount;
                s.salePurchaseLedger[saleUserKey]                   := userSalePurchaseRecord;

                // update sale option
                saleOption.totalBought                              := saleOption.totalBought + amount;
                saleRecord.saleOptions[saleOptionName]              := saleOption;

                // update sale record
                s.saleLedger[saleId]                                := saleRecord;

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
