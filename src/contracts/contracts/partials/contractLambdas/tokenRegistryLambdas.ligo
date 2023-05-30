// ------------------------------------------------------------------------------
//
// Token Registry Lambdas Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Housekeeping Lambdas Begin
// ------------------------------------------------------------------------------

(*  setAdmin lambda *)
function lambdaSetAdmin(const tokenRegistryLambdaAction : tokenRegistryLambdaActionType; var s : tokenRegistryStorageType) : return is
block {

    // verify that sender is admin or the Governance Contract address
    // verifySenderIsAdminOrGovernance(s.admin, s.governanceAddress);

    verifySenderIsAdmin(s.admin); // check that sender is admin 
    
    case tokenRegistryLambdaAction of [
        |   LambdaSetAdmin(newAdminAddress) -> {
                s.admin := newAdminAddress;
            }
        |   _ -> skip
    ];

} with (noOperations, s)



// (*  setGovernance lambda *)
// function lambdaSetGovernance(const tokenRegistryLambdaAction : tokenRegistryLambdaActionType; var s : tokenRegistryStorageType) : return is
// block {
    
//     // verify that sender is admin or the Governance Contract address
//     // verifySenderIsAdminOrGovernance(s.admin, s.governanceAddress);

//     verifySenderIsAdmin(s.admin); // check that sender is admin 

//     case tokenRegistryLambdaAction of [
//         |   LambdaSetGovernance(newGovernanceAddress) -> {
//                 s.governanceAddress := newGovernanceAddress;
//             }
//         |   _ -> skip
//     ];

// } with (noOperations, s)



(*  updateMetadata lambda - update the metadata at a given key *)
function lambdaUpdateMetadata(const tokenRegistryLambdaAction : tokenRegistryLambdaActionType; var s : tokenRegistryStorageType) : return is
block {
    
    // verify that sender is admin (i.e. Governance Proxy Contract address)
    verifySenderIsAdmin(s.admin); 

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
    verifySenderIsAdmin(s.admin); 

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

    // verify that sender is admin (i.e. Governance Proxy Contract address)
    verifySenderIsAdmin(s.admin); 

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
function lambdaPauseAll(const tokenRegistryLambdaAction : tokenRegistryLambdaActionType; var s : tokenRegistryStorageType) : return is
block {

    // verify that sender is admin or the Governance Contract address
    // verifySenderIsAdminOrGovernance(s.admin, s.governanceAddress);
    
    verifySenderIsAdmin(s.admin); // check that sender is admin 

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

    // verify that sender is admin or the Governance Contract address
    // verifySenderIsAdminOrGovernance(s.admin, s.governanceAddress);

    verifySenderIsAdmin(s.admin); // check that sender is admin 

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

    verifySenderIsAdmin(s.admin); // check that sender is admin 

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

                verifySenderIsAdmin(s.admin); // check that sender is admin 

                // const token         : listTokenType     = setTokenParams.token;
                // const beneficiary   : option(address)   = setTokenParams.beneficiary;
                // const fee           : option(nat)       = setTokenParams.fee;
                
                // const tokenOverride : tokenOverrideType = record [
                //     beneficiaryOverride = beneficiary;
                //     feeOverride         = fee;
                // ];

                // case token of [
                //         Fa12 (fa12TokenAddress) -> {
                //             s.fa12TokenLedger[fa12TokenAddress] := tokenOverride;
                //         }
                //     |   Fa2(fa2Token) -> {
                //             s.fa2TokenLedger[(fa2Token.tokenContractAddress, fa2Token.tokenId)] := tokenOverride;
                //         }
                // ];

                const token         : listTokenType     = setTokenParams.token;
                const beneficiary   : option(address)   = setTokenParams.beneficiary;
                const fee           : option(nat)       = setTokenParams.fee;

                case token of [
                        Fa12 (fa12TokenAddress) -> {
                            s.tokenLedger[fa12TokenAddress] := record [
                                tokenType           = Fa12Token(fa12TokenAddress);
                                beneficiaryOverride = beneficiary;
                                feeOverride         = fee;
                            ];
                        }
                    |   Fa2(fa2Token) -> {

                            var tokenRecord : tokenRecordType := case s.tokenLedger[fa2Token.tokenContractAddress] of [

                                    Some (_tokenRecord) -> block {

                                        var _record : tokenRecordType := _tokenRecord;

                                        _record.tokenType := case _record.tokenType of [
                                                Fa2Token(_set) -> Fa2Token(Set.add(fa2Token.tokenId, _set))
                                            |   _              -> Fa2Token(set[fa2Token.tokenId]) // should not be reached
                                        ];

                                        _record.beneficiaryOverride  := beneficiary;
                                        _record.feeOverride          := fee;

                                    } with _record

                                |   None -> record [
                                        tokenType           = Fa2Token(set[fa2Token.tokenId]);
                                        beneficiaryOverride = beneficiary;
                                        feeOverride         = fee;
                                    ]   
                            ];

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

                verifySenderIsAdmin(s.admin); // check that sender is admin 

                case removeTokenParams of [
                        Fa12 (fa12TokenAddress) -> remove fa12TokenAddress from map s.tokenLedger
                    |   Fa2 (fa2Token) -> {

                            // remove token id from Fa2Token set of tokenIds
                            var tokenRecord : tokenRecordType := case s.tokenLedger[fa2Token.tokenContractAddress] of [
                                    Some (_tokenRecord) -> block {
                                        var _record : tokenRecordType := _tokenRecord;
                                        _record.tokenType := case _record.tokenType of [
                                                Fa2Token(_set) -> Fa2Token(Set.remove(fa2Token.tokenId, _set))
                                            |   _              -> Fa2Token(set[]) // should not be reached
                                        ];
                                    } with _record
                                |   None -> failwith(error_FA2_TOKEN_RECORD_NOT_FOUND_TO_BE_REMOVED)
                            ];
                            s.tokenLedger[fa2Token.tokenContractAddress] := tokenRecord;

                            // remove token record if there are no more token ids for the Fa2 Token
                            const cardinal : nat = case tokenRecord.tokenType of [
                                    Fa2Token(_set) -> Set.size(_set)
                                |   _              -> 0n
                            ];
                            
                            if cardinal = 0n then remove fa2Token.tokenContractAddress from map s.tokenLedger;
                            
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