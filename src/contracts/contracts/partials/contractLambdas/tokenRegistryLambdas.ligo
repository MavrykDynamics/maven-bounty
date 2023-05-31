// ------------------------------------------------------------------------------
//
// Token Registry Lambdas Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Admin Lambdas Begin
// ------------------------------------------------------------------------------

(*  setSuperAdmin lambda *)
function lambdaSetSuperAdmin(const tokenRegistryLambdaAction : tokenRegistryLambdaActionType; var s : tokenRegistryStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 
    
    case tokenRegistryLambdaAction of [
        |   LambdaSetSuperAdmin(newAdminAddress) -> {
                s.newSuperAdmin := Some(newAdminAddress);
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  claimSuperAdmin lambda *)
function lambdaClaimSuperAdmin(const tokenRegistryLambdaAction : tokenRegistryLambdaActionType; var s : tokenRegistryStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 
    
    case tokenRegistryLambdaAction of [
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
function lambdaSetAdmin(const tokenRegistryLambdaAction : tokenRegistryLambdaActionType; var s : tokenRegistryStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 
    
    case tokenRegistryLambdaAction of [
        |   LambdaSetAdmin(newAdminAddress) -> {
                s.admins := Set.add(newAdminAddress, s.admins);
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  removeAdmin lambda *)
function lambdaRemoveAdmin(const tokenRegistryLambdaAction : tokenRegistryLambdaActionType; var s : tokenRegistryStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 
    
    case tokenRegistryLambdaAction of [
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
function lambdaUpdateMetadata(const tokenRegistryLambdaAction : tokenRegistryLambdaActionType; var s : tokenRegistryStorageType) : return is
block {
    
    // verify that sender is admin 
    verifySenderIsAdmin(s.admins); 

    case tokenRegistryLambdaAction of [
        |   LambdaUpdateMetadata(updateMetadataParams) -> {
                
                const metadataKey   : string = updateMetadataParams.metadataKey;
                const metadataHash  : bytes  = updateMetadataParams.metadataHash;
                
                s.metadata[metadataKey] := metadataHash;
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  updateWhitelistContracts lambda *)
function lambdaUpdateWhitelistContracts(const tokenRegistryLambdaAction : tokenRegistryLambdaActionType; var s: tokenRegistryStorageType) : return is
block {

    // verify that sender is admin
    verifySenderIsAdmin(s.admins); 

    case tokenRegistryLambdaAction of [
        |   LambdaUpdateWhitelistContracts(updateWhitelistContractsParams) -> {
                s.whitelistContracts := updateWhitelistContractsMap(updateWhitelistContractsParams, s.whitelistContracts);
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  updateGeneralContracts lambda *)
function lambdaUpdateGeneralContracts(const tokenRegistryLambdaAction : tokenRegistryLambdaActionType; var s: tokenRegistryStorageType) : return is
block {

    // verify that sender is admin 
    verifySenderIsAdmin(s.admins); 

    case tokenRegistryLambdaAction of [
        |   LambdaUpdateGeneralContracts(updateGeneralContractsParams) -> {
                s.generalContracts := updateGeneralContractsMap(updateGeneralContractsParams, s.generalContracts);
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  mistaken lambda *)
function lambdaMistakenTransfer(const tokenRegistryLambdaAction : tokenRegistryLambdaActionType; var s: tokenRegistryStorageType) : return is
block {

    var operations : list(operation) := nil;

    case tokenRegistryLambdaAction of [
        |   LambdaMistakenTransfer(destinationParams) -> {

                verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 

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
function lambdaPauseAll(const tokenRegistryLambdaAction : tokenRegistryLambdaActionType; var s : tokenRegistryStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 

    case tokenRegistryLambdaAction of [
        |   LambdaPauseAll(_parameters) -> {
              
                // set all pause configs to True
                s := pauseAllTokenRegistryEntrypoints(s);
              
            }
        |   _ -> skip
    ];  

} with (noOperations, s)



(*  unpauseAll lambda *)
function lambdaUnpauseAll(const tokenRegistryLambdaAction : tokenRegistryLambdaActionType; var s : tokenRegistryStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 

    case tokenRegistryLambdaAction of [
        |   LambdaUnpauseAll(_parameters) -> {
                
                // set all pause configs to False
                s := unpauseAllTokenRegistryEntrypoints(s);
              
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  togglePauseEntrypoint lambda *)
function lambdaTogglePauseEntrypoint(const tokenRegistryLambdaAction : tokenRegistryLambdaActionType; var s : tokenRegistryStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 

    case tokenRegistryLambdaAction of [
        |   LambdaTogglePauseEntrypoint(params) -> {

                case params.targetEntrypoint of [
                        SetToken (_v)             -> s.breakGlassConfig.setTokenIsPaused         := _v
                    |   RemoveToken (_v)          -> s.breakGlassConfig.removeTokenIsPaused      := _v
                ]
                
            }
        |   _ -> skip
    ];

} with (noOperations, s)

// ------------------------------------------------------------------------------
// Pause / Break Glass Lambdas End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Token Registry Lambdas Begin
// ------------------------------------------------------------------------------

(*  setToken lambda *)
function lambdaSetToken(const tokenRegistryLambdaAction : tokenRegistryLambdaActionType; var s : tokenRegistryStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.setTokenIsPaused, error_ADD_TOKEN_ENTRYPOINT_IN_TOKEN_REGISTRY_CONTRACT_PAUSED);

    case tokenRegistryLambdaAction of [
        |   LambdaSetToken(setTokenParams) -> {

                verifySenderIsAdmin(s.admins); // check that sender is admin 

                const token         : listTokenType     = setTokenParams.token;
                const beneficiary   : option(address)   = setTokenParams.beneficiary;
                const fee           : option(nat)       = setTokenParams.fee;
                
                var tokenRecord : tokenRecordType := record [
                    tokenType           = "null";
                    tokenIds            = set[];
                    beneficiaryOverride = beneficiary;
                    feeOverride         = fee;
                ];

                case token of [
                        Fa12 (fa12TokenAddress) -> {
                            tokenRecord.tokenType  := "FA12";
                            s.tokenLedger[fa12TokenAddress] := tokenRecord;
                        }
                    |   Fa2(fa2Token) -> {
                            tokenRecord.tokenType  := "FA2";
                            tokenRecord.tokenIds   := Set.add(fa2Token.tokenId, tokenRecord.tokenIds);
                            s.tokenLedger[fa2Token.tokenContractAddress] := tokenRecord;
                        }
                ];


            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  removeToken lambda *)
function lambdaRemoveToken(const tokenRegistryLambdaAction : tokenRegistryLambdaActionType; var s : tokenRegistryStorageType) : return is
block {

    verifyEntrypointIsNotPaused(s.breakGlassConfig.removeTokenIsPaused, error_REMOVE_TOKEN_ENTRYPOINT_IN_TOKEN_REGISTRY_CONTRACT_PAUSED);

    case tokenRegistryLambdaAction of [
        |   LambdaRemoveToken(removeTokenParams) -> {

                verifySenderIsAdmin(s.admins); // check that sender is admin 
                
                case removeTokenParams of [
                        Fa12 (fa12TokenAddress) -> {
                            remove fa12TokenAddress from map s.tokenLedger;
                        }
                    |   Fa2(fa2Token) -> {

                            var tokenRecord : tokenRecordType := case s.tokenLedger[fa2Token.tokenContractAddress] of [
                                    Some(_record) -> _record
                                |   None          -> failwith(error_TOKEN_RECORD_NOT_FOUND)
                            ];

                            tokenRecord.tokenIds := Set.remove(fa2Token.tokenId, tokenRecord.tokenIds);
                            s.tokenLedger[fa2Token.tokenContractAddress] := tokenRecord;

                            // remove token record if there are no more token ids in the set
                            const cardinal : nat = Set.size(tokenRecord.tokenIds);
                            if cardinal = 0n then remove fa2Token.tokenContractAddress from map s.tokenLedger else skip;
                        }
                ];

            }
        |   _ -> skip
    ];

} with (noOperations, s)

// ------------------------------------------------------------------------------
//
// Token Registry Lambdas End
//
// ------------------------------------------------------------------------------