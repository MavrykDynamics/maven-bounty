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
                    |   ConfigMarketplaceFee (_v)  -> s.config.marketplaceFee         := updateConfigNewValue
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
                    |   EditListing (_v)       -> s.breakGlassConfig.editListingIsPaused        := _v
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

                const token             : listTokenType     = listingParams.token;
                const amount            : nat               = listingParams.amount;
                const pricePerUnit      : nat               = listingParams.pricePerUnit;
                const quickBuyPrice     : option(nat)       = listingParams.quickBuyPrice;
                const expiryTime        : option(timestamp) = listingParams.expiryTime;
                const currency          : tokenType         = listingParams.currency;
                
                const sender            : address           = Tezos.get_sender();
                const nextListingId     : nat               = s.nextListingId;
                const marketplace       : address           = Tezos.get_self_address();

                // verify that currency is accepted
                verifyValidCurrency(currency, s);

                const listingRecord : listingRecordType = record [
                    initiator       = sender;
                    status          = "ACTIVE";
                    token           = token; 
                    pricePerUnit    = pricePerUnit;
                    amount          = amount;
                    currency        = currency;
                    quickBuyPrice   = quickBuyPrice;
                    expiryTime      = expiryTime; 
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



(*  editListing lambda *)
function lambdaEditListing(const marketplaceLambdaAction : marketplaceLambdaActionType; var s : marketplaceStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.editListingIsPaused, error_EDIT_LISTING_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED);

    var operations : list(operation) := nil;

    case marketplaceLambdaAction of [
        |   LambdaEditListing(editListingParams) -> {

                const sender    : address   = Tezos.get_sender();
                const listingId : nat       = editListingParams.listingId;
                const marketplace : address = Tezos.get_self_address();

                var listingRecord : listingRecordType := case s.listingLedger[listingId] of [
                        Some(_record) -> _record
                    |   None          -> failwith(error_LISTING_RECORD_NOT_FOUND)
                ];
                const token     : listTokenType  = listingRecord.token;
                const currentListingAmount : nat = listingRecord.amount;
                
                // verify sender is listing initiator
                verifyOwnership(listingRecord.initiator, sender);

                // 
                case editListingParams.amount of [
                        Some(_newAmount) -> {

                            const amountDiff : int = _newAmount - currentListingAmount;
                            if _newAmount > currentListingAmount then {
                                // increase in listing amount: transfer difference in amount to marketplace
                                operations := case token of [
                                        Fa12Token(fa12TokenAddress) -> transferFa12Token(sender, marketplace, abs(amountDiff), fa12TokenAddress) # operations
                                    |   Fa2Token(fa2Token)          -> transferFa2Token(sender, marketplace, abs(amountDiff), fa2Token.tokenId, fa2Token.tokenContractAddress) # operations
                                ];

                            } else {
                                // decrease in listing amount: transfer difference in amount back to sender
                                operations := case token of [
                                        Fa12Token(_address) -> transferFa12Token(marketplace, sender, abs(amountDiff), _address) # operations
                                    |   Fa2Token(_fa2Token) -> transferFa2Token(marketplace, sender, abs(amountDiff), _fa2Token.tokenId, _fa2Token.tokenContractAddress) # operations
                                ];
                            }
                        }
                    |   None -> skip
                ];

                case editListingParams.pricePerUnit of [
                        Some(_newPricePerUnit) -> listingRecord.pricePerUnit := _newPricePerUnit
                    |   None            -> skip
                ];

                case editListingParams.quickBuyPrice of [
                        Some(_newQuickBuyPrice) -> listingRecord.quickBuyPrice := Some(_newQuickBuyPrice)
                    |   None            -> skip
                ];

                case editListingParams.expiryTime of [
                        Some(_newExpiryTime) -> listingRecord.expiryTime := Some(_newExpiryTime)
                    |   None                 -> skip
                ];

                case editListingParams.currency of [
                        Some(_newCurrency) -> listingRecord.currency := _newCurrency
                    |   None -> skip
                ];

                // update storage
                s.listingLedger[listingId] := listingRecord;
                
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

                const sender        : address  = Tezos.get_sender();
                const marketplace   : address  = Tezos.get_self_address();

                var listingRecord : listingRecordType := case s.listingLedger[listingId] of [
                        Some(_record) -> _record
                    |   None          -> failwith(error_LISTING_RECORD_NOT_FOUND)
                ];

                verifyOwnership(listingRecord.initiator, sender);

                const token     : listTokenType  = listingRecord.token;
                const amount    : nat            = listingRecord.amount;

                // update listing status
                listingRecord.status        := "CLOSED";
                s.listingLedger[listingId]  := listingRecord;

                // transfer tokens back to listing initiator
                operations := case token of [
                        Fa12Token(_address) -> transferFa12Token(marketplace, sender, amount, _address) # operations
                    |   Fa2Token(_fa2Token) -> transferFa2Token(marketplace, sender, amount, _fa2Token.tokenId, _fa2Token.tokenContractAddress) # operations
                ];

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
        |   LambdaPurchase(purchaseParams) -> {

                // init variables
                const sender            : address   = Tezos.get_sender();
                const marketplace       : address   = Tezos.get_self_address();
                const standardUnit      : nat       = s.config.standardUnit;
                
                const listingId : nat = case purchaseParams of [
                    |   PartialPurchase(_partialPurchase) -> _partialPurchase.listingId
                    |   QuickBuyPurchase(_listingId)      -> _listingId
                ];

                // get listing record
                var listingRecord : listingRecordType := case s.listingLedger[listingId] of [
                        Some(_record) -> _record
                    |   None          -> failwith(error_LISTING_RECORD_NOT_FOUND)
                ];
                
                const lister                    : address        = listingRecord.initiator;
                const token                     : listTokenType  = listingRecord.token;
                const pricePerUnit              : nat            = listingRecord.pricePerUnit;
                const listingAmount             : nat            = listingRecord.amount;

                const purchaseAmount            : nat = case purchaseParams of [
                    |   PartialPurchase(_partialPurchase) -> _partialPurchase.amount
                    |   QuickBuyPurchase(_v)              -> listingAmount
                ];

                // ------------------------------------------------------
                // Verification Checks
                // ------------------------------------------------------

                // verify listing is active 
                verifyListingIsActive(listingRecord.status);

                // verify purchaser is not initiator
                verifyPurchaserIsNotInitiator(sender, listingRecord.initiator);

                // verify listing amount is greater than or equal to purchase amount
                verifyGreaterThanOrEqual(listingAmount, purchaseAmount, error_PURCHASE_AMOUNT_CANNOT_BE_GREATER_THAN_LISTING_AMOUNT);

                // verify listing is not expired
                case listingRecord.expiryTime of [
                        Some(_timestamp) -> verifyNotExpired(_timestamp, error_LISTING_HAS_EXPIRED)
                    |   None             -> skip
                ];

                // ------------------------------------------------------
                // Calculations
                // ------------------------------------------------------

                const treasuryAddress           : address        = getAddressFromGeneralContracts("treasury", s, error_TREASURY_NOT_FOUND);           
                const royalty                   : nat            = s.config.royalty;
                const marketplaceFee            : nat            = s.config.marketplaceFee;

                // const totalPaid                 : nat            = pricePerUnit * ( ( (purchaseAmount * fixedPointAccuracy) / standardUnit) / fixedPointAccuracy);

                const totalPaid                 : nat            = case listingRecord.quickBuyPrice of [
                        Some(_v) -> _v
                    |   None     -> case purchaseParams of [
                            |   PartialPurchase(_partialPurchase) -> pricePerUnit * ( ( (purchaseAmount * fixedPointAccuracy) / standardUnit) / fixedPointAccuracy)
                            |   QuickBuyPurchase(_v)              -> failwith(error_QUICK_BUY_OPTION_DOES_NOT_EXIST_ON_LISTING)
                        ]
                ];

                const marketplaceFeeTotal       : nat            = (totalPaid * fixedPointAccuracy * marketplaceFee) / (fixedPointAccuracy * 10000n);
                const totalPaidLessFee          : nat            = abs(totalPaid - marketplaceFeeTotal);

                const royaltyAmount             : nat            = (purchaseAmount * fixedPointAccuracy * royalty) / (fixedPointAccuracy * 10000n);
                const purchaseAmountLessRoyalty : nat            = abs(purchaseAmount - royaltyAmount);

                // ------------------------------------------------------
                // Transfers
                // ------------------------------------------------------

                // transfer price/fees to lister and treasury
                case listingRecord.currency of [
                        Tez        -> {
                            operations := transferTez((Tezos.get_contract_with_error(lister, "Error. Contract not found at given address") : contract(unit)), totalPaidLessFee * 1mutez) # operations;
                            operations := transferTez((Tezos.get_contract_with_error(treasuryAddress, "Error. Contract not found at given address") : contract(unit)), marketplaceFeeTotal * 1mutez) # operations;
                        } 
                    |   Fa12(_address)  -> {
                            operations := transferFa12Token(sender, lister, totalPaidLessFee, _address) # operations;
                            operations := transferFa12Token(sender, treasuryAddress, marketplaceFeeTotal, _address) # operations;
                        }
                    |   Fa2(_fa2Token)  -> {
                            operations := transferFa2Token(sender, lister, totalPaidLessFee, _fa2Token.tokenId, _fa2Token.tokenContractAddress) # operations;
                            operations := transferFa2Token(sender, treasuryAddress, marketplaceFeeTotal, _fa2Token.tokenId, _fa2Token.tokenContractAddress) # operations;
                        }
                ];

                // transfer purchased token amount to sender and treasury
                case token of [
                        Fa12Token(_address) -> {
                            operations := transferFa12Token(marketplace, sender, purchaseAmountLessRoyalty, _address) # operations;
                            operations := transferFa12Token(marketplace, treasuryAddress, royaltyAmount, _address) # operations;
                        }
                    |   Fa2Token(_fa2Token) -> {
                            operations := transferFa2Token(marketplace, sender, purchaseAmountLessRoyalty, _fa2Token.tokenId, _fa2Token.tokenContractAddress) # operations;
                            operations := transferFa2Token(marketplace, treasuryAddress, royaltyAmount, _fa2Token.tokenId, _fa2Token.tokenContractAddress) # operations;
                        }
                ];


                // ------------------------------------------------------
                // Update Storage
                // ------------------------------------------------------

                // update listing status
                listingRecord.status        := "CLOSED";
                s.listingLedger[listingId]  := listingRecord;

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
                const amount : nat                   = offerParams.amount;
                const expiryTime : option(timestamp) = offerParams.expiryTime;
                const currency : tokenType           = offerParams.currency;

                const sender : address               = Tezos.get_sender();
                const nextOfferId : nat              = s.nextOfferId;
                const marketplace : address          = Tezos.get_self_address();
                // const standardUnit  : nat            = s.config.standardUnit;

                // verify that currency is accepted
                verifyValidCurrency(currency, s);

                const offerRecord : offerRecordType = record [
                    initiator       = sender;
                    status          = "OPEN";
                    listingId       = listingId;
                    price           = price;
                    amount          = amount;
                    currency        = currency;
                    expiryTime      = expiryTime; 
                ];                

                // create new offer
                s.offerLedger[nextOfferId] := offerRecord;

                // const totalCurrencyAmount : nat = pricePerUnit * ( ( (amount * fixedPointAccuracy) / standardUnit) / fixedPointAccuracy);

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

                const sender        : address   = Tezos.get_sender();
                const marketplace   : address   = Tezos.get_self_address();
                // const standardUnit  : nat       = s.config.standardUnit;

                var offerRecord : offerRecordType := case s.offerLedger[offerId] of [
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
                // const offerPricePerUnit  : nat       = offerRecord.pricePerUnit;
                const offerPrice         : nat       = offerRecord.price;
                const offerAmount        : nat       = offerRecord.amount;

                var listingRecord : listingRecordType := case s.listingLedger[listingId] of [
                        Some(_record) -> _record
                    |   None          -> failwith(error_LISTING_RECORD_NOT_FOUND)
                ];

                // listing params
                const lister             : address       = listingRecord.initiator;
                const token              : listTokenType = listingRecord.token;
                const listingAmount      : nat           = listingRecord.amount;
                
                // ------------------------------------------------------
                // Verification Checks
                // ------------------------------------------------------

                // verify offer is open 
                verifyOfferIsOpen(offerRecord.status);

                // verify listing is active 
                verifyListingIsActive(listingRecord.status);

                // verify sender is listing creator
                verifyOwnership(lister, sender);

                // verify listing amount is greater than or equal to offer amount
                verifyGreaterThanOrEqual(listingAmount, offerAmount, error_OFFER_AMOUNT_CANNOT_BE_GREATER_THAN_LISTING_AMOUNT);

                // do we want to allow lister to accept an offer even if his listing has expired?
                // verify listing is not expired
                case listingRecord.expiryTime of [
                        Some(_timestamp) -> verifyNotExpired(_timestamp, error_LISTING_HAS_EXPIRED)
                    |   None             -> skip
                ];

                // ------------------------------------------------------

                // const totalOfferPrice           : nat      = offerPricePerUnit * ( ( (offerAmount * fixedPointAccuracy) / standardUnit) / fixedPointAccuracy);

                const treasuryAddress           : address  = getAddressFromGeneralContracts("treasury", s, error_TREASURY_NOT_FOUND);           
                const royalty                   : nat      = s.config.royalty;
                const marketplaceFee            : nat      = s.config.marketplaceFee;

                const marketplaceFeeTotal       : nat      = (offerPrice * fixedPointAccuracy * marketplaceFee) / (fixedPointAccuracy * 10000n);
                const offerPriceLessFee         : nat      = abs(offerPrice - marketplaceFeeTotal);

                const royaltyAmount             : nat      = (offerAmount * fixedPointAccuracy * royalty) / (fixedPointAccuracy * 10000n);
                const offerAmountLessRoyalty    : nat      = abs(offerAmount - royaltyAmount);

                // transfer offer price/fees to lister and treasury
                case offerRecord.currency of [
                        Tez        -> {
                            operations := transferTez((Tezos.get_contract_with_error(lister, "Error. Contract not found at given address") : contract(unit)), offerPriceLessFee * 1mutez) # operations;
                            operations := transferTez((Tezos.get_contract_with_error(treasuryAddress, "Error. Contract not found at given address") : contract(unit)), marketplaceFeeTotal * 1mutez) # operations;
                        } 
                    |   Fa12(_address)  -> {
                            operations := transferFa12Token(marketplace, lister, offerPriceLessFee, _address) # operations;
                            operations := transferFa12Token(marketplace, treasuryAddress, marketplaceFeeTotal, _address) # operations;
                        }
                    |   Fa2(_fa2Token)  -> {
                            operations := transferFa2Token(marketplace, lister, offerPriceLessFee, _fa2Token.tokenId, _fa2Token.tokenContractAddress) # operations;
                            operations := transferFa2Token(marketplace, treasuryAddress, marketplaceFeeTotal, _fa2Token.tokenId, _fa2Token.tokenContractAddress) # operations;
                        }
                ];

                // transfer offer token amount to offerer and treasury
                case token of [
                        Fa12Token(_address) -> {
                            operations := transferFa12Token(marketplace, offerer, offerAmountLessRoyalty, _address) # operations;
                            operations := transferFa12Token(marketplace, treasuryAddress, royaltyAmount, _address) # operations;
                        }
                    |   Fa2Token(_fa2Token) -> {
                            operations := transferFa2Token(marketplace, offerer, offerAmountLessRoyalty, _fa2Token.tokenId, _fa2Token.tokenContractAddress) # operations;
                            operations := transferFa2Token(marketplace, treasuryAddress, royaltyAmount, _fa2Token.tokenId, _fa2Token.tokenContractAddress) # operations;
                        }
                ];

                // calc remaining amount in listing
                const remainingAmount : nat = abs(listingAmount - offerAmount);

                // update listing record
                listingRecord.amount        := remainingAmount;
                s.listingLedger[listingId]  := listingRecord; 

                // update offer record status
                offerRecord.status          := "ACCEPTED";
                s.offerLedger[offerId]      := offerRecord;
                
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

                const sender : address          = Tezos.get_sender();
                const marketplace : address     = Tezos.get_self_address();
                // const standardUnit  : nat       = s.config.standardUnit;

                var offerRecord : offerRecordType := case s.offerLedger[offerId] of [
                        Some(_record) -> _record
                    |   None          -> failwith(error_OFFER_RECORD_NOT_FOUND)
                ];

                verifyOwnership(offerRecord.initiator, sender);

                const price : nat            = offerRecord.price;
                // const amount : nat           = offerRecord.amount;
                const currency : tokenType   = offerRecord.currency;

                // update offer status
                offerRecord.status          := "CLOSED";
                s.offerLedger[offerId]      := offerRecord;

                // const totalCurrencyAmount : nat = pricePerUnit * ( ( (amount * fixedPointAccuracy) / standardUnit) / fixedPointAccuracy);

                // transfer offer amount back to offerer
                operations := case currency of [
                        Tez                     -> transferTez((Tezos.get_contract_with_error(sender, "Error. Contract not found at given address") : contract(unit)), price * 1mutez) # operations
                    |   Fa12(fa12TokenAddress)  -> transferFa12Token(marketplace, sender, price, fa12TokenAddress) # operations
                    |   Fa2(fa2Token)           -> transferFa2Token(marketplace, sender, price, fa2Token.tokenId, fa2Token.tokenContractAddress) # operations
                ];

            }
        |   _ -> skip
    ];

} with (operations, s)

// ------------------------------------------------------------------------------
//
// Marketplace Lambdas End
//
// ------------------------------------------------------------------------------