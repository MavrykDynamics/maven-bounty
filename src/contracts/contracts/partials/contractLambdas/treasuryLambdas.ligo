// ------------------------------------------------------------------------------
//
// Treasury Lambdas Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Admin Lambdas Begin
// ------------------------------------------------------------------------------

(*  setSuperAdmin lambda *)
function lambdaSetSuperAdmin(const treasuryLambdaAction : treasuryLambdaActionType; var s : treasuryStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 
    
    case treasuryLambdaAction of [
        |   LambdaSetSuperAdmin(newAdminAddress) -> {
                s.newSuperAdmin := Some(newAdminAddress);
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  claimSuperAdmin lambda *)
function lambdaClaimSuperAdmin(const treasuryLambdaAction : treasuryLambdaActionType; var s : treasuryStorageType) : return is
block {
    
    case treasuryLambdaAction of [
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
function lambdaSetAdmin(const treasuryLambdaAction : treasuryLambdaActionType; var s : treasuryStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 
    
    case treasuryLambdaAction of [
        |   LambdaSetAdmin(newAdminAddress) -> {
                s.admins := Set.add(newAdminAddress, s.admins);
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  removeAdmin lambda *)
function lambdaRemoveAdmin(const treasuryLambdaAction : treasuryLambdaActionType; var s : treasuryStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 
    
    case treasuryLambdaAction of [
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

(* setBaker lambda *)
function lambdaSetBaker(const treasuryLambdaAction : treasuryLambdaActionType; var s : treasuryStorageType) : return is
block {
    
    verifyNoAmountSent(Unit);       // entrypoint should not receive any tez amount  
    verifySenderIsAdmin(s.admins);  // verify that sender is admin 

    var operations : list(operation) := nil;

    case treasuryLambdaAction of [
        |   LambdaSetBaker(keyHash) -> {
                const setBakerOperation  : operation = Tezos.set_delegate(keyHash);
                operations := setBakerOperation # operations;
            }
        |   _ -> skip
    ];

} with (operations, s)



(* updateMetadata lambda - update the metadata at a given key *)
function lambdaUpdateMetadata(const treasuryLambdaAction : treasuryLambdaActionType; var s : treasuryStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // verify that sender is admin 
    
    case treasuryLambdaAction of [
        |   LambdaUpdateMetadata(updateMetadataParams) -> {
                
                const metadataKey   : string = updateMetadataParams.metadataKey;
                const metadataHash  : bytes  = updateMetadataParams.metadataHash;
                
                s.metadata[metadataKey] := metadataHash;

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* updateWhitelistContracts lambda *)
function lambdaUpdateWhitelistContracts(const treasuryLambdaAction : treasuryLambdaActionType; var s: treasuryStorageType) : return is
block {
    
    verifySenderIsAdmin(s.admins); // verify that sender is admin 
    
    case treasuryLambdaAction of [
        |   LambdaUpdateWhitelistContracts(updateWhitelistContractsParams) -> {
                s.whitelistContracts := updateWhitelistContractsMap(updateWhitelistContractsParams, s.whitelistContracts);
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* updateGeneralContracts lambda *)
function lambdaUpdateGeneralContracts(const treasuryLambdaAction : treasuryLambdaActionType; var s: treasuryStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // verify that sender is admin 
    
    case treasuryLambdaAction of [
        |   LambdaUpdateGeneralContracts(updateGeneralContractsParams) -> {
                s.generalContracts := updateGeneralContractsMap(updateGeneralContractsParams, s.generalContracts);
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* updateWhitelistTokenContracts lambda *)
function lambdaUpdateWhitelistTokenContracts(const treasuryLambdaAction : treasuryLambdaActionType; var s: treasuryStorageType) : return is
block {

    verifySenderIsAdmin(s.admins); // verify that sender is admin 

    case treasuryLambdaAction of [
        |   LambdaUpdateWhitelistTokens(updateWhitelistTokenContractsParams) -> {
                s.whitelistTokenContracts := updateWhitelistTokenContractsMap(updateWhitelistTokenContractsParams, s.whitelistTokenContracts);
            }
        |   _ -> skip
    ];


} with (noOperations, s)

// ------------------------------------------------------------------------------
// Housekeeping Lambdas End
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Treasury Lambdas Begin
// ------------------------------------------------------------------------------

(* transfer lambda *)
function lambdaTransfer(const treasuryLambdaAction : treasuryLambdaActionType; var s : treasuryStorageType) : return is 
block {
    
    // Steps Overview:
    // 1. Check if sender is whitelisted (e.g. governance)
    // 2. Check that %transfer entrypoint is not paused (e.g. if glass broken)
    // 3. Check that tokens to be transferred are in the Whitelisted Token Contracts map
    // 4. Create and excecute transfer operations 

    verifySenderIsAdmin(s.admins); // verify that sender is admin 
    
    var operations : list(operation) := nil;

    case treasuryLambdaAction of [
        |   LambdaTransfer(transferTokenParams) -> {
                
                const txs : list(transferDestinationType) = transferTokenParams;
                
                const whitelistTokenContracts : whitelistTokenContractsType = s.whitelistTokenContracts;

                function transferAccumulator (var accumulator : list(operation); const destination : transferDestinationType) : list(operation) is 
                block {

                    const token        : tokenType        = destination.token;
                    const to_          : ownerType        = destination.to_;
                    const amt          : nat              = destination.amount;
                    const from_        : address          = Tezos.get_self_address(); // treasury
                    
                    // Create transfer token operation
                    // - check that token to be transferred are in the Whitelisted Token Contracts map
                    const transferTokenOperation : operation = case token of [
                        |   Tez         -> transferTez((Tezos.get_contract_with_error(to_, "Error. Contract not found at given address") : contract(unit)), amt * 1mutez)
                        |   Fa12(token) -> if not checkInWhitelistTokenContracts(token, whitelistTokenContracts) then failwith(error_TOKEN_NOT_WHITELISTED) else transferFa12Token(from_, to_, amt, token)
                        |   Fa2(token)  -> if not checkInWhitelistTokenContracts(token.tokenContractAddress, whitelistTokenContracts) then failwith(error_TOKEN_NOT_WHITELISTED) else transferFa2Token(from_, to_, amt, token.tokenId, token.tokenContractAddress)
                    ];

                    accumulator := transferTokenOperation # accumulator;

                } with accumulator;

                const emptyOperation : list(operation) = list[];
                operations := List.fold(transferAccumulator, txs, emptyOperation);

            }
        |   _ -> skip
    ];

} with (operations, s)



(* updateMvkOperators lambda *)
function lambdaUpdateMvkOperators(const treasuryLambdaAction : treasuryLambdaActionType; var s : treasuryStorageType) : return is 
block {

    // Steps Overview:
    // 1. Check if sender is admin
    // 2. Update operators of Treasury Contract on the MVK Token contract 
    //    - required to set Doorman Contract as an operator for staking/unstaking 

    verifySenderIsAdmin(s.admins); // verify that sender is admin 

    var operations : list(operation) := nil;

    case treasuryLambdaAction of [
        |   LambdaUpdateMvkOperators(updateOperatorsParams) -> {
                
                // Create and send update operators operation
                const updateMvkOperatorsOperation : operation = updateMvkOperatorsOperation(updateOperatorsParams, s);
                operations := updateMvkOperatorsOperation # operations;

            }
        |   _ -> skip
    ];

} with (operations, s)



(* stakeMvk lambda *)
function lambdaStakeMvk(const treasuryLambdaAction : treasuryLambdaActionType; var s : treasuryStorageType) : return is 
block {

    // Steps Overview:
    // 1. Check if sender is admin
    // 2. Check that %stakeMvk entrypoint is not paused (e.g. if glass broken)
    // 3. Get Doorman Contract address from the General Contracts Map on the Governance Contract
    // 4. Get stake entrypoint in the Doorman Contract
    // 5. Create and send stake operation to the Doorman Contract

    verifySenderIsAdmin(s.admins); // verify that sender is admin 
    
    var operations : list(operation) := nil;


    case treasuryLambdaAction of [
        |   LambdaStakeMvk(stakeAmount) -> {
                
                // Create and send stake operation
                const stakeMvkOperation : operation = stakeMvkOperation(stakeAmount, s);
                operations := stakeMvkOperation # operations;

            }
        |   _ -> skip
    ];

} with (operations, s)



(* unstakeMvk lambda *)
function lambdaUnstakeMvk(const treasuryLambdaAction : treasuryLambdaActionType; var s : treasuryStorageType) : return is 
block {

    // Steps Overview:
    // 1. Check if sender is admin
    // 2. Check that %unstakeMvk entrypoint is not paused (e.g. if glass broken)
    // 3. Get Doorman Contract address from the General Contracts Map on the Governance Contract
    // 4. Get unstake entrypoint in the Doorman Contract
    // 5. Create and send unstake operation to the Doorman Contract
    
    verifySenderIsAdmin(s.admins);  // verify that sender is admin 
    
    var operations : list(operation) := nil;

    case treasuryLambdaAction of [
        |   LambdaUnstakeMvk(unstakeAmount) -> {
                
                // Create and send unstake operation
                const unstakeMvkOperation : operation = unstakeMvkOperation(unstakeAmount, s);
                operations := unstakeMvkOperation # operations;

            }
        |   _ -> skip
    ];

} with (operations, s)

// ------------------------------------------------------------------------------
// Treasury Lambdas End
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
//
// Treasury Lambdas End
//
// ------------------------------------------------------------------------------
