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
        |   LambdaSetCurrency(setCurrencyParams) -> {

                verifySenderIsAdmin(s.admins); // check that sender is admin 

                const actionType : string   = setCurrencyParams.actionType;
                const token : listTokenType = setCurrencyParams.token;

                case token of [
                        Fa12Token(fa12TokenAddress) -> {
                            
                            if actionType = "update" then {

                                const currencyRecord : currencyRecordType = record [
                                    tokenType = "FA12";
                                    tokenIds  = set[];
                                ];

                                s.currencyLedger[fa12TokenAddress] := currencyRecord;

                            } else if actionType = "remove" then {

                                remove fa12TokenAddress from map s.currencyLedger;
                            }
                        }
                    |   Fa2Token(fa2Token) -> {

                            if actionType = "update" then {
                                
                                var currencyRecord : currencyRecordType := case s.currencyLedger[fa2Token.tokenContractAddress] of [
                                        Some(_record) -> {
                                            
                                            var _record := _record;
                                            _record.tokenIds := Set.add(fa2Token.tokenId, _record.tokenIds);

                                        } with _record
                                    |   None -> record [
                                            tokenType = "FA2";
                                            tokenIds  = set[fa2Token.tokenId];
                                        ]
                                ];

                                s.currencyLedger[fa2Token.tokenContractAddress] := currencyRecord;

                            } else if actionType = "remove" then {
                            
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
        |   LambdaCreateListing(listingParams) -> {

                const token : listTokenType          = listingParams.token;
                const amount : nat                   = listingParams.amount;
                const price : nat                    = listingParams.price;
                const expiryTime : option(timestamp) = listingParams.expiryTime;
                const currency : tokenType           = listingParams.currency;
                const sender : address               = Tezos.get_sender();
                const nextListingId : nat            = s.nextListingId;
                const marketplace : address          = Tezos.get_self_address();

                // verify that currency is accepted
                verifyValidCurrency(currency, s);

                const listingRecord : listingRecordType = record [
                    initiator   = sender;
                    token       = token; 
                    price       = price;
                    amount      = amount;
                    currency    = currency;
                    expiryTime  = expiryTime; 
                ];                

                // create new listing
                s.listingLedger[nextListingId] := listingRecord;

                // transfer token to contract (custodial solution)
                operations := case token of [
                        Fa12Token(fa12TokenAddress) -> transferFa12Token(sender, marketplace, amount, fa12TokenAddress) # operations
                    |   Fa2Token(fa2Token)          -> transferFa2Token(sender, marketplace, amount, fa2Token.tokenId, fa2Token.tokenContractAddress) # operations
                ];

                s.nextListingId := nextListingId + 1n;
                
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
        |   LambdaRemoveListing(listingId) -> {

                const sender : address  = Tezos.get_sender();

                const listingRecord : listingRecordType = case s.listingLedger[listingId] of [
                        Some(_record) -> _record
                    |   None          -> failwith(error_LISTING_RECORD_NOT_FOUND)
                ];

                verifyOwnership(listingRecord.initiator, sender);

                remove listingId from map s.listingLedger;

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
        |   LambdaPurchase(listingId) -> {

                const sender : address          = Tezos.get_sender();
                const marketplace : address     = Tezos.get_self_address();
                const listingRecord : listingRecordType = case s.listingLedger[listingId] of [
                        Some(_record) -> _record
                    |   None          -> failwith(error_LISTING_RECORD_NOT_FOUND)
                ];

                // verify purchaser is not initiator
                verifyPurchaserIsNotInitiator(sender, listingRecord.initiator);

                // verify listing is not expired
                case listingRecord.expiryTime of [
                        Some(_timestamp) -> verifyNotExpired(_timestamp, error_LISTING_HAS_EXPIRED)
                    |   None             -> skip
                ];
                
                const lister    : address        = listingRecord.initiator;
                const token     : listTokenType  = listingRecord.token;
                const price     : nat            = listingRecord.price;
                const amount    : nat            = listingRecord.amount;

                const treasuryAddress    : address  = getAddressFromGeneralContracts("treasury", s, error_TREASURY_NOT_FOUND);           
                const royalty            : nat      = s.config.royalty;
                const royaltyFeeTotal    : nat      = (price * fixedPointAccuracy * royalty) / (fixedPointAccuracy * 10000n);
                const priceLessRoyalty   : nat      = abs(price - royaltyFeeTotal);

                // transfer price/fees to lister and treasury
                case listingRecord.currency of [
                        Tez        -> {
                            operations := transferTez((Tezos.get_contract_with_error(lister, "Error. Contract not found at given address") : contract(unit)), priceLessRoyalty * 1mutez) # operations;
                            operations := transferTez((Tezos.get_contract_with_error(treasuryAddress, "Error. Contract not found at given address") : contract(unit)), royaltyFeeTotal * 1mutez) # operations;
                        } 
                    |   Fa12(_address)  -> {
                            operations := transferFa12Token(sender, lister, priceLessRoyalty, _address) # operations;
                            operations := transferFa12Token(sender, treasuryAddress, royaltyFeeTotal, _address) # operations;
                        }
                    |   Fa2(_fa2Token)  -> {
                            operations := transferFa2Token(sender, lister, priceLessRoyalty, _fa2Token.tokenId, _fa2Token.tokenContractAddress) # operations;
                            operations := transferFa2Token(sender, treasuryAddress, royaltyFeeTotal, _fa2Token.tokenId, _fa2Token.tokenContractAddress) # operations;
                        }
                ];

                // transfer purchased token amount to sender
                operations := case token of [
                        Fa12Token(_address) -> transferFa12Token(marketplace, sender, amount, _address) # operations
                    |   Fa2Token(_fa2Token) -> transferFa2Token(marketplace, sender, amount, _fa2Token.tokenId, _fa2Token.tokenContractAddress) # operations
                ];

                remove listingId from map s.listingLedger;

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
        |   LambdaOffer(offerParams) -> {

                const listingId : nat                = offerParams.listingId;
                const price : nat                    = offerParams.price;
                const expiryTime : option(timestamp) = offerParams.expiryTime;
                const currency : tokenType           = offerParams.currency;

                const sender : address               = Tezos.get_sender();
                const nextOfferId : nat              = s.nextOfferId;
                const marketplace : address          = Tezos.get_self_address();

                // verify that currency is accepted
                verifyValidCurrency(currency, s);

                const offerRecord : offerRecordType = record [
                    initiator   = sender;
                    listingId   = listingId;
                    price       = price;
                    currency    = currency;
                    expiryTime  = expiryTime; 
                ];                

                // create new offer
                s.offerLedger[nextOfferId] := offerRecord;

                // transfer offer to contract (custodial solution)
                operations := case currency of [
                        Tez                     -> transferTez((Tezos.get_contract_with_error(marketplace, "Error. Contract not found at given address") : contract(unit)), price * 1mutez) # operations
                    |   Fa12(fa12TokenAddress)  -> transferFa12Token(sender, marketplace, price, fa12TokenAddress) # operations
                    |   Fa2(fa2Token)           -> transferFa2Token(sender, marketplace, price, fa2Token.tokenId, fa2Token.tokenContractAddress) # operations
                ];

                // increment next offer id
                s.nextOfferId := nextOfferId + 1n;

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
        |   LambdaAcceptOffer(offerId) -> {

                const sender : address               = Tezos.get_sender();
                const marketplace : address          = Tezos.get_self_address();

                const offerRecord : offerRecordType = case s.offerLedger[offerId] of [
                        Some(_record) -> _record
                    |   None          -> failwith(error_OFFER_RECORD_NOT_FOUND)
                ];

                // get offerer
                const offerer : address = offerRecord.initiator;

                // verify offer is not expired
                case offerRecord.expiryTime of [
                        Some(_timestamp) -> verifyNotExpired(_timestamp, error_OFFER_HAS_EXPIRED)
                    |   None             -> skip
                ];

                const listingId          : nat       = offerRecord.listingId;
                const offerPrice         : nat       = offerRecord.price;

                const listingRecord : listingRecordType = case s.listingLedger[listingId] of [
                        Some(_record) -> _record
                    |   None          -> failwith(error_LISTING_RECORD_NOT_FOUND)
                ];

                // listing params
                const lister             : address       = listingRecord.initiator;
                const token              : listTokenType = listingRecord.token;
                const listingAmount      : nat           = listingRecord.amount;
                
                // verify sender is listing creator
                verifyOwnership(lister, sender);

                // do we want to allow lister to accept an offer even if his listing has expired?
                // verify listing is not expired
                case listingRecord.expiryTime of [
                        Some(_timestamp) -> verifyNotExpired(_timestamp, error_LISTING_HAS_EXPIRED)
                    |   None             -> skip
                ];

                const treasuryAddress           : address  = getAddressFromGeneralContracts("treasury", s, error_TREASURY_NOT_FOUND);           
                const royalty                   : nat      = s.config.royalty;
                const royaltyFeeTotal           : nat      = (offerPrice * fixedPointAccuracy * royalty) / (fixedPointAccuracy * 10000n);
                const offerPriceLessRoyalty     : nat      = abs(offerPrice - royaltyFeeTotal);

                // transfer offer price/fees to lister and treasury
                case offerRecord.currency of [
                        Tez        -> {
                            operations := transferTez((Tezos.get_contract_with_error(lister, "Error. Contract not found at given address") : contract(unit)), offerPriceLessRoyalty * 1mutez) # operations;
                            operations := transferTez((Tezos.get_contract_with_error(treasuryAddress, "Error. Contract not found at given address") : contract(unit)), royaltyFeeTotal * 1mutez) # operations;
                        } 
                    |   Fa12(_address)  -> {
                            operations := transferFa12Token(marketplace, lister, offerPriceLessRoyalty, _address) # operations;
                            operations := transferFa12Token(marketplace, treasuryAddress, royaltyFeeTotal, _address) # operations;
                        }
                    |   Fa2(_fa2Token)  -> {
                            operations := transferFa2Token(marketplace, lister, offerPriceLessRoyalty, _fa2Token.tokenId, _fa2Token.tokenContractAddress) # operations;
                            operations := transferFa2Token(marketplace, treasuryAddress, royaltyFeeTotal, _fa2Token.tokenId, _fa2Token.tokenContractAddress) # operations;
                        }
                ];

                // transfer listing token amount to offerer
                operations := case token of [
                        Fa12Token(_address) -> transferFa12Token(marketplace, offerer, listingAmount, _address) # operations
                    |   Fa2Token(_fa2Token) -> transferFa2Token(marketplace, offerer, listingAmount, _fa2Token.tokenId, _fa2Token.tokenContractAddress) # operations
                ];

                // remove listing and offer
                remove listingId from map s.listingLedger;
                remove offerId from map s.offerLedger;
                
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
        |   LambdaRemoveOffer(offerId) -> {

                const sender : address  = Tezos.get_sender();

                const offerRecord : offerRecordType = case s.offerLedger[offerId] of [
                        Some(_record) -> _record
                    |   None          -> failwith(error_OFFER_RECORD_NOT_FOUND)
                ];

                verifyOwnership(offerRecord.initiator, sender);

                remove offerId from map s.offerLedger;

            }
        |   _ -> skip
    ];

} with (operations, s)

// ------------------------------------------------------------------------------
//
// Marketplace Lambdas End
//
// ------------------------------------------------------------------------------