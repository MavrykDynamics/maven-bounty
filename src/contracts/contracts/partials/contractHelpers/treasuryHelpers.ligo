// ------------------------------------------------------------------------------
//
// Helper Functions Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Admin Helper Functions Begin
// ------------------------------------------------------------------------------

// helper function to verify sender is whitelisted
function verifySenderIsWhitelisted(const s : treasuryStorageType) : unit is 
block {

    if not checkInWhitelistContracts(Tezos.get_sender(), s.whitelistContracts) then failwith(error_ONLY_WHITELISTED_ADDRESSES_ALLOWED)
    else skip;

} with unit 



// helper function to get contract address from general contracts map
function getAddressFromGeneralContracts(const contractName : string; const s : treasuryStorageType; const errorCode : nat) : address is 
block {

    const contractAddress : address = case s.generalContracts[contractName] of [
            Some(_address) -> _address
        |   None           -> failwith(errorCode)
    ];

} with contractAddress

// ------------------------------------------------------------------------------
// Admin Helper Functions End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Entrypoint Helper Functions Begin
// ------------------------------------------------------------------------------

// helper function to %stake entrypoint on the Doorman contract
function getStakeEntrypointOnDoorman(const contractAddress : address) : contract(nat) is
    case (Tezos.get_entrypoint_opt(
        "%stake",
        contractAddress) : option(contract(nat))) of [
                Some(contr) -> contr
            |   None        -> (failwith(error_STAKE_ENTRYPOINT_IN_DOORMAN_CONTRACT_NOT_FOUND) : contract(nat))
        ];



// helper function to %unstake entrypoint on the Doorman contract
function getUnstakeEntrypointOnDoorman(const contractAddress : address) : contract(nat) is
    case (Tezos.get_entrypoint_opt(
        "%unstake",
        contractAddress) : option(contract(nat))) of [
                Some(contr) -> contr
            |   None        -> (failwith(error_UNSTAKE_ENTRYPOINT_IN_DOORMAN_CONTRACT_NOT_FOUND) : contract(nat))
        ];


// helper function to %update_operators entrypoint on the MVK token contract
function getUpdateMvkOperatorsEntrypoint(const tokenContractAddress : address) : contract(updateOperatorsType) is
    case (Tezos.get_entrypoint_opt(
        "%update_operators",
        tokenContractAddress) : option(contract(updateOperatorsType))) of [
                Some (contr)    -> contr
            |   None            -> (failwith(error_UPDATE_OPERATORS_ENTRYPOINT_IN_MVK_TOKEN_CONTRACT_NOT_FOUND) : contract(updateOperatorsType))
        ];

// ------------------------------------------------------------------------------
// Entrypoint Helper Functions End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Operations Helper Functions Begin
// ------------------------------------------------------------------------------

// helper function to stake MVK on the Doorman contract
function stakeMvkOperation(const stakeAmount : nat; const s : treasuryStorageType) : operation is
block {

    // Get Doorman Contract address from the General Contracts Map 
    const doormanAddress : address = getAddressFromGeneralContracts("doorman", s, error_DOORMAN_CONTRACT_NOT_FOUND);

    // Create and send stake operation
    const stakeMvkOperation : operation = Tezos.transaction(
        (stakeAmount),
        0tez, 
        getStakeEntrypointOnDoorman(doormanAddress)
    );

} with stakeMvkOperation



// helper function to unstake MVK on the Doorman contract
function unstakeMvkOperation(const unstakeAmount : nat; const s : treasuryStorageType) : operation is
block {

    // Get Doorman Contract address from the General Contracts Map 
    const doormanAddress : address = getAddressFromGeneralContracts("doorman", s, error_DOORMAN_CONTRACT_NOT_FOUND);

    // Create and send unstake operation
    const unstakeMvkOperation : operation = Tezos.transaction(
        (unstakeAmount),
        0tez, 
        getUnstakeEntrypointOnDoorman(doormanAddress)
    );

} with unstakeMvkOperation



// helper function to update operators on the MVK token contract
function updateMvkOperatorsOperation(const updateOperatorsParams : updateOperatorsType; const s : treasuryStorageType) : operation is
block {

    // Get mvkToken Contract address from the General Contracts Map 
    const mvkTokenAddress : address = getAddressFromGeneralContracts("mvkToken", s, error_MVK_TOKEN_CONTRACT_NOT_FOUND);

    // Create and send update MVK operators operation
    const updateMvkOperatorsOperation : operation = Tezos.transaction(
        (updateOperatorsParams),
        0tez, 
        getUpdateMvkOperatorsEntrypoint(mvkTokenAddress)
    );

} with updateMvkOperatorsOperation

// ------------------------------------------------------------------------------
// Operations Helper Functions End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// General Helper Functions Begin
// ------------------------------------------------------------------------------




// ------------------------------------------------------------------------------
// General Helper Functions End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Lambda Helper Functions Begin
// ------------------------------------------------------------------------------

// helper function to unpack and execute entrypoint logic stored as bytes in lambdaLedger
function unpackLambda(const lambdaBytes : bytes; const treasuryLambdaAction : treasuryLambdaActionType; var s : treasuryStorageType) : return is 
block {

    const res : return = case (Bytes.unpack(lambdaBytes) : option(treasuryUnpackLambdaFunctionType)) of [
            Some(f) -> f(treasuryLambdaAction, s)
        |   None    -> failwith(error_UNABLE_TO_UNPACK_LAMBDA)
    ];

} with (res.0, res.1)

// ------------------------------------------------------------------------------
// Lambda Helper Functions End
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
//
// Helper Functions End
//
// ------------------------------------------------------------------------------