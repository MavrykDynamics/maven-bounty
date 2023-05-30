// ------------------------------------------------------------------------------
//
// Marketplace Lambdas Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Housekeeping Lambdas Begin
// ------------------------------------------------------------------------------

(*  setAdmin lambda *)
function lambdaSetAdmin(const marketplaceLambdaAction : marketplaceLambdaActionType; var s : marketplaceStorageType) : return is
block {

    // verify that sender is admin or the Governance Contract address
    // verifySenderIsAdminOrGovernance(s.admin, s.governanceAddress);

    verifySenderIsAdmin(s.admin); // check that sender is admin 
    
    case marketplaceLambdaAction of [
        |   LambdaSetAdmin(newAdminAddress) -> {
                s.admin := newAdminAddress;
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  setGovernance lambda *)
function lambdaSetGovernance(const marketplaceLambdaAction : marketplaceLambdaActionType; var s : marketplaceStorageType) : return is
block {
    
    // verify that sender is admin or the Governance Contract address
    // verifySenderIsAdminOrGovernance(s.admin, s.governanceAddress);

    verifySenderIsAdmin(s.admin); // check that sender is admin 

    case marketplaceLambdaAction of [
        |   LambdaSetGovernance(newGovernanceAddress) -> {
                s.governanceAddress := newGovernanceAddress;
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  updateMetadata lambda - update the metadata at a given key *)
function lambdaUpdateMetadata(const marketplaceLambdaAction : marketplaceLambdaActionType; var s : marketplaceStorageType) : return is
block {
    
    // verify that sender is admin (i.e. Governance Proxy Contract address)
    verifySenderIsAdmin(s.admin); 

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
    verifySenderIsAdmin(s.admin); 

    case marketplaceLambdaAction of [
        |   LambdaUpdateConfig(updateConfigParams) -> {
                
                const updateConfigAction    : marketplaceUpdateConfigActionType   = updateConfigParams.updateConfigAction;
                const updateConfigNewValue  : marketplaceUpdateConfigNewValueType = updateConfigParams.updateConfigNewValue;

                case updateConfigAction of [
                    |   ConfigMinOfferAmount (_v)  -> s.config.minOfferAmount         := updateConfigNewValue
                    |   Empty (_v)                 -> skip
                ];
            }
        |   _ -> skip
    ];
  
} with (noOperations, s)



(*  updateWhitelistContracts lambda *)
function lambdaUpdateWhitelistContracts(const marketplaceLambdaAction : marketplaceLambdaActionType; var s: marketplaceStorageType) : return is
block {

    // verify that sender is admin
    verifySenderIsAdmin(s.admin); 

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
    verifySenderIsAdmin(s.admin); 

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

                // Verify that the sender is admin or the Governance Satellite Contract
                // verifySenderIsAdminOrGovernanceSatelliteContract(s);
                
                verifySenderIsAdmin(s.admin); // check that sender is admin 

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

    // verify that sender is admin or the Governance Contract address
    verifySenderIsAdminOrGovernance(s.admin, s.governanceAddress);

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

    // verify that sender is admin or the Governance Contract address
    verifySenderIsAdminOrGovernance(s.admin, s.governanceAddress);

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
    verifySenderIsAdmin(s.admin); // check that sender is admin 

    case marketplaceLambdaAction of [
        |   LambdaTogglePauseEntrypoint(params) -> {

                case params.targetEntrypoint of [
                        List (_v)              -> s.breakGlassConfig.listIsPaused         := _v
                    |   Purchase (_v)          -> s.breakGlassConfig.purchaseIsPaused     := _v
                    |   Offer (_v)             -> s.breakGlassConfig.offerIsPaused        := _v
                    |   AcceptOffer (_v)       -> s.breakGlassConfig.acceptOfferIsPaused  := _v
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

                verifySenderIsAdmin(s.admin); // check that sender is admin 

                case token of [
                        Fa12(fa12TokenAddress) -> {
                            
                            const currencyRecord : currencyRecordType = record [
                                tokenType = "FA12";
                                tokenIds  = set[];
                            ];

                            s.currencyLedger[fa12TokenAddress] := currencyRecord;
                        }
                    |   Fa2(fa2Token) -> {

                            const currencyRecord : currencyRecordType = case s.currencyLedger[fa2Token.tokenContractAddress] of [
                                    Some(_record) -> {
                                        _record.tokenIds := Set.add(fa2Token.tokenId, _record.tokenIds);
                                    } with _record
                                |   None -> record [
                                        tokenType = "FA2";
                                        tokenIds  = set[fa2Token.tokenId];
                                    ];
                            ]

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

                verifySenderIsAdmin(s.admin); // check that sender is admin 

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

(*  list lambda *)
function lambdaList(const marketplaceLambdaAction : marketplaceLambdaActionType; var s : marketplaceStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.listIsPaused, error_LIST_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED);

    var operations : list(operation) := nil;

    case marketplaceLambdaAction of [
        |   LambdaList(listParams) -> {

                const token : listTokenType          = listParams.token;
                const amount : nat                   = listParams.amount;
                const expiryTime : option(timestamp) = listParams.expiryTime;
                const currency : tokenType           = listParams.currency;
                const sender : address               = Tezos.get_sender();
                const nextListId : nat               = s.nextListId;

                // verify that currency is accepted
                verifyValidCurrency(currency);

                const listRecord : listRecordType = record [
                    initiator   = sender;
                    token       = token; 
                    amount      = amount;
                    expiryTime  = expiryTime; 
                    currency    = currency;
                ];                

                // create new listing
                s.listLedger[nextListId] := listRecord;

                // transfer token to contract (custodial solution)
                operations := case token of [
                        Fa12(fa12TokenAddress) -> transferFa12Token(sender, Tezos.get_self_address(), amount, fa12TokenAddress) # operations
                    |   Fa2(fa2Token) -> transferFa2Token(sender, Tezos.get_self_address(), amount, fa2Token.tokenId, fa2Token.tokenContractAddress) # operations
                ];
                
            }
        |   _ -> skip
    ];

} with (operations, s)



(*  delist lambda *)
function lambdaDelist(const marketplaceLambdaAction : marketplaceLambdaActionType; var s : marketplaceStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.delistIsPaused, error_DELIST_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED);

    var operations : list(operation) := nil;

    case marketplaceLambdaAction of [
        |   LambdaDelist(listId) -> {

                const sender : address  = Tezos.get_sender();

                const listRecord : listRecordType = case s.listLedger[listId] of [
                        Some(_record) -> _record
                    |   None          -> failwith(error_LIST_RECORD_NOT_FOUND)
                ];

                verifyListOwnership(listRecord.initiator, sender);

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