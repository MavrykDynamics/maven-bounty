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

(* launchNewTokenSale lambda *)
function lambdaLaunchNewTokenSale(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 
    
    case launchpadLambdaAction of [
        |   LambdaLaunchNewTokenSale(launchNewTokenSaleParams) -> {

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
        |   LambdaStartSale(startSaleParams) -> {

                skip

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* setSaleWhitelist lambda *)
function lambdaSetSaleWhitelist(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 
    
    case launchpadLambdaAction of [
        |   LambdaSetSaleWhitelist(setSaleWhitelistParams) -> {

                skip

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* editSale lambda *)
function lambdaEditSale(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 
    
    case launchpadLambdaAction of [
        |   LambdaEditSale(editSaleParams) -> {

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
        |   LambdaPauseSale(pauseSaleParams) -> {

                skip

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* unpauseSale lambda *)
function lambdaUnpauseSale(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 
    
    case launchpadLambdaAction of [
        |   LambdaUnpauseSale(unpauseSaleParams) -> {

                skip

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* closeSale lambda *)
function lambdaCloseSale(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 
    
    case launchpadLambdaAction of [
        |   LambdaCloseSale(closeSaleParams) -> {

                skip

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* distributeTokens lambda *)
function lambdaDistributeTokens(const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // check that sender is admin 
    
    case launchpadLambdaAction of [
        |   LambdaDistributeTokens(distributeTokensParams) -> {

                skip

            }
        |   _ -> skip
    ];

} with (noOperations, s)


// ------------------------------------------------------------------------------
// Launchpad Lambdas End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
//
// Launchpad Lambdas End
//
// ------------------------------------------------------------------------------
