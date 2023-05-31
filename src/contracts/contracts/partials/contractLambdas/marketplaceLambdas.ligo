// ------------------------------------------------------------------------------
//
// Marketplace Lambdas Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Admin Lambdas Begin
// ------------------------------------------------------------------------------

(*  setSuperAdmin lambda *)
function lambdaSetSuperAdmin(const marketplaceLambdaAction : marketplaceLambdaActionType; var s : marketplaceStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 
    
    case marketplaceLambdaAction of [
        |   LambdaSetSuperAdmin(newAdminAddress) -> {
                s.newSuperAdmin := Some(newAdminAddress);
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  claimSuperAdmin lambda *)
function lambdaClaimSuperAdmin(const marketplaceLambdaAction : marketplaceLambdaActionType; var s : marketplaceStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 
    
    case marketplaceLambdaAction of [
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
function lambdaSetAdmin(const marketplaceLambdaAction : marketplaceLambdaActionType; var s : marketplaceStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 
    
    case marketplaceLambdaAction of [
        |   LambdaSetAdmin(newAdminAddress) -> {
                s.admins := Set.add(newAdminAddress, s.admins);
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  removeAdmin lambda *)
function lambdaRemoveAdmin(const marketplaceLambdaAction : marketplaceLambdaActionType; var s : marketplaceStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 
    
    case marketplaceLambdaAction of [
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
function lambdaUpdateMetadata(const marketplaceLambdaAction : marketplaceLambdaActionType; var s : marketplaceStorageType) : return is
block {
    
    // verify that sender is admin (i.e. Governance Proxy Contract address)
    verifySenderIsAdmin(s.admins); 

    case marketplaceLambdaAction of [
        |   LambdaUpdateMetadata(updateMetadataParams) -> {
                
                const metadataKey   : string = updateMetadataParams.metadataKey;
                const metadataHash  : bytes  = updateMetadataParams.metadataHash;
                
                s.metadata[metadataKey] := metadataHash;
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* updateConfig lambda *)
function lambdaUpdateConfig(const marketplaceLambdaAction : marketplaceLambdaActionType; var s : marketplaceStorageType) : return is 
block {

    // verify that sender is admin (i.e. Governance Proxy Contract address)
    verifySenderIsAdmin(s.admins); 

    case marketplaceLambdaAction of [
        |   LambdaUpdateConfig(updateConfigParams) -> {
                
                const updateConfigAction    : marketplaceUpdateConfigActionType   = updateConfigParams.updateConfigAction;
                const updateConfigNewValue  : marketplaceUpdateConfigNewValueType = updateConfigParams.updateConfigNewValue;

                case updateConfigAction of [
                    |   ConfigMinOfferAmount (_v)  -> s.config.minOfferAmount         := updateConfigNewValue
                    |   ConfigRoyalty (_v)         -> s.config.royalty                := updateConfigNewValue
                ];
            }
        |   _ -> skip
    ];
  
} with (noOperations, s)



(*  updateWhitelistContracts lambda *)
function lambdaUpdateWhitelistContracts(const marketplaceLambdaAction : marketplaceLambdaActionType; var s: marketplaceStorageType) : return is
block {

    // verify that sender is admin
    verifySenderIsAdmin(s.admins); 

    case marketplaceLambdaAction of [
        |   LambdaUpdateWhitelistContracts(updateWhitelistContractsParams) -> {
                s.whitelistContracts := updateWhitelistContractsMap(updateWhitelistContractsParams, s.whitelistContracts);
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  updateGeneralContracts lambda *)
function lambdaUpdateGeneralContracts(const marketplaceLambdaAction : marketplaceLambdaActionType; var s: marketplaceStorageType) : return is
block {

    // verify that sender is admin (i.e. Governance Proxy Contract address)
    verifySenderIsAdmin(s.admins); 

    case marketplaceLambdaAction of [
        |   LambdaUpdateGeneralContracts(updateGeneralContractsParams) -> {
                s.generalContracts := updateGeneralContractsMap(updateGeneralContractsParams, s.generalContracts);
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  mistaken lambda *)
function lambdaMistakenTransfer(const marketplaceLambdaAction : marketplaceLambdaActionType; var s: marketplaceStorageType) : return is
block {

    var operations : list(operation) := nil;

    case marketplaceLambdaAction of [
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
function lambdaPauseAll(const marketplaceLambdaAction : marketplaceLambdaActionType; var s : marketplaceStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 

    case marketplaceLambdaAction of [
        |   LambdaPauseAll(_parameters) -> {
              
                // set all pause configs to True
                s := pauseAllMarketplaceEntrypoints(s);
              
            }
        |   _ -> skip
    ];  

} with (noOperations, s)



(*  unpauseAll lambda *)
function lambdaUnpauseAll(const marketplaceLambdaAction : marketplaceLambdaActionType; var s : marketplaceStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 

    case marketplaceLambdaAction of [
        |   LambdaUnpauseAll(_parameters) -> {
                
                // set all pause configs to False
                s := unpauseAllMarketplaceEntrypoints(s);
              
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  togglePauseEntrypoint lambda *)
function lambdaTogglePauseEntrypoint(const marketplaceLambdaAction : marketplaceLambdaActionType; var s : marketplaceStorageType) : return is
block {

    verifyNoAmountSent(Unit);     // entrypoint should not receive any tez amount  
    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 

    case marketplaceLambdaAction of [
        |   LambdaTogglePauseEntrypoint(params) -> {

                case params.targetEntrypoint of [
                        CreateListing (_v)     -> s.breakGlassConfig.createListingIsPaused      := _v
                    |   RemoveListing (_v)     -> s.breakGlassConfig.removeListingIsPaused      := _v
                    |   Purchase (_v)          -> s.breakGlassConfig.purchaseIsPaused           := _v
                    |   Offer (_v)             -> s.breakGlassConfig.offerIsPaused              := _v
                    |   AcceptOffer (_v)       -> s.breakGlassConfig.acceptOfferIsPaused        := _v
                    |   RemoveOffer (_v)       -> s.breakGlassConfig.removeOfferIsPaused        := _v
                    |   SetCurrency (_v)       -> s.breakGlassConfig.setCurrencyIsPaused        := _v
                    |   RemoveCurrency (_v)    -> s.breakGlassConfig.removeCurrencyIsPaused     := _v
                ]
                
            }
        |   _ -> skip
    ];

} with (noOperations, s)

// ------------------------------------------------------------------------------
// Pause / Break Glass Lambdas End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Marketplace Admin Lambdas Begin
// ------------------------------------------------------------------------------

(*  setCurrency lambda *)
function lambdaSetCurrency(const marketplaceLambdaAction : marketplaceLambdaActionType; var s : marketplaceStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.setCurrencyIsPaused, error_SET_CURRENCY_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED);

    case marketplaceLambdaAction of [
        |   LambdaSetCurrency(token) -> {

                verifySenderIsAdmin(s.admins); // check that sender is admin 

                case token of [
                        Fa12(fa12TokenAddress) -> {
                            
                            const currencyRecord : currencyRecordType = record [
                                tokenType = "FA12";
                                tokenIds  = set[];
                            ];

                            s.currencyLedger[fa12TokenAddress] := currencyRecord;
                        }
                    |   Fa2(fa2Token) -> {

                            var currencyRecord : currencyRecordType := case s.currencyLedger[fa2Token.tokenContractAddress] of [
                                    Some(_record) -> block {
                                        
                                        _record.tokenIds := Set.add(fa2Token.tokenId, _record.tokenIds);

                                    } with _record

                                |   None -> record [
                                        tokenType = "FA2";
                                        tokenIds  = set[fa2Token.tokenId];
                                    ]
                            ];

                            s.currencyLedger[fa2Token.tokenContractAddress] := currencyRecord;

                        }
                ]
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  removeCurrency lambda *)
function lambdaRemoveCurrency(const marketplaceLambdaAction : marketplaceLambdaActionType; var s : marketplaceStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.removeCurrencyIsPaused, error_REMOVE_CURRENCY_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED);

    case marketplaceLambdaAction of [
        |   LambdaRemoveCurrency(token) -> {

                verifySenderIsAdmin(s.admins); // check that sender is admin 

                case token of [
                        Fa12(fa12TokenAddress) -> {
                            remove fa12TokenAddress from map s.currencyLedger;
                        }
                    |   Fa2(fa2Token) -> {

                            var currencyRecord : currencyRecordType := case s.currencyLedger[fa2Token.tokenContractAddress] of [
                                    Some(_record) -> _record
                                |   None          -> failwith(error_CURRENCY_RECORD_NOT_FOUND)
                            ];

                            currencyRecord.tokenIds := Set.remove(fa2Token.tokenId, currencyRecord.tokenIds);
                            s.currencyLedger[fa2Token.tokenContractAddress] := currencyRecord;

                            // remove token record if there are no more token ids in the set
                            const cardinal : nat = Set.size(currencyRecord.tokenIds);
                            if cardinal = 0n then remove fa2Token.tokenContractAddress from map s.currencyLedger else skip;

                        }
                ]
            }
        |   _ -> skip
    ];

} with (noOperations, s)

// ------------------------------------------------------------------------------
// Marketplace Admin Lambdas End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Marketplace Lambdas Begin
// ------------------------------------------------------------------------------

(*  createListing lambda *)
function lambdaCreateListing(const marketplaceLambdaAction : marketplaceLambdaActionType; var s : marketplaceStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.createListingIsPaused, error_CREATE_LISTING_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED);

    var operations : list(operation) := nil;

    case marketplaceLambdaAction of [
        |   LambdaCreateListing(listParams) -> {

                const token : listTokenType          = listParams.token;
                const amount : nat                   = listParams.amount;
                const expiryTime : option(timestamp) = listParams.expiryTime;
                const currency : tokenType           = listParams.currency;
                const sender : address               = Tezos.get_sender();
                const nextListId : nat               = s.nextListId;

                // verify that currency is accepted
                verifyValidCurrency(currency);

                const listingRecord : listingRecordType = record [
                    initiator   = sender;
                    token       = token; 
                    amount      = amount;
                    expiryTime  = expiryTime; 
                    currency    = currency;
                ];                

                // create new listing
                s.listLedger[nextListId] := listingRecord;

                // transfer token to contract (custodial solution)
                operations := case token of [
                        Fa12(fa12TokenAddress) -> transferFa12Token(sender, Tezos.get_self_address(), amount, fa12TokenAddress) # operations
                    |   Fa2(fa2Token) -> transferFa2Token(sender, Tezos.get_self_address(), amount, fa2Token.tokenId, fa2Token.tokenContractAddress) # operations
                ];
                
            }
        |   _ -> skip
    ];

} with (operations, s)



(*  removeListing lambda *)
function lambdaRemoveListing(const marketplaceLambdaAction : marketplaceLambdaActionType; var s : marketplaceStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.removeListingIsPaused, error_REMOVE_LISTING_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED);

    var operations : list(operation) := nil;

    case marketplaceLambdaAction of [
        |   LambdaRemoveListing(listId) -> {

                const sender : address  = Tezos.get_sender();

                const listingRecord : listingRecordType = case s.listLedger[listId] of [
                        Some(_record) -> _record
                    |   None          -> failwith(error_LIST_RECORD_NOT_FOUND)
                ];

                verifyListingOwnership(listingRecord.initiator, sender);

                remove listId from map s.listLedger;

            }
        |   _ -> skip
    ];

} with (operations, s)



(*  purchase lambda *)
function lambdaPurchase(const marketplaceLambdaAction : marketplaceLambdaActionType; var s : marketplaceStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.purchaseIsPaused, error_PURCHASE_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED);

    var operations : list(operation) := nil;

    case marketplaceLambdaAction of [
        |   LambdaPurchase(_params) -> {

                skip

            }
        |   _ -> skip
    ];

} with (operations, s)



(*  offer lambda *)
function lambdaOffer(const marketplaceLambdaAction : marketplaceLambdaActionType; var s : marketplaceStorageType) : return is
block {
    
    verifyEntrypointIsNotPaused(s.breakGlassConfig.offerIsPaused, error_OFFER_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED);

    var operations : list(operation) := nil;

    case marketplaceLambdaAction of [
        |   LambdaOffer(_params) -> {

                skip

            }
        |   _ -> skip
    ];

} with (operations, s)



(*  acceptOffer lambda *)
function lambdaAcceptOffer(const marketplaceLambdaAction : marketplaceLambdaActionType; var s : marketplaceStorageType) : return is
block {
    
    verifyEntrypointIsNotPaused(s.breakGlassConfig.acceptOfferIsPaused, error_ACCEPT_OFFER_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED);

    var operations : list(operation) := nil;

    case marketplaceLambdaAction of [
        |   LambdaAcceptOffer(_params) -> {

                skip
                
            }
        |   _ -> skip
    ];

} with (operations, s)



(*  removeOffer lambda *)
function lambdaRemoveOffer(const marketplaceLambdaAction : marketplaceLambdaActionType; var s : marketplaceStorageType) : return is
block {
    
    verifyEntrypointIsNotPaused(s.breakGlassConfig.removeOfferIsPaused, error_REMOVE_OFFER_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED);

    var operations : list(operation) := nil;

    case marketplaceLambdaAction of [
        |   LambdaRemoveOffer(_params) -> {

                skip
                
            }
        |   _ -> skip
    ];

} with (operations, s)

// ------------------------------------------------------------------------------
//
// Marketplace Lambdas End
//
// ------------------------------------------------------------------------------