// ------------------------------------------------------------------------------
//
// Helper Functions Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Admin Helper Functions Begin
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Admin Helper Functions End
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Pause / BreakGlass Helper Functions Begin
// ------------------------------------------------------------------------------

// helper function to pause all entrypoints
function pauseAllLaunchpadEntrypoints(var s : launchpadStorageType) : launchpadStorageType is 
block {

    // set all pause configs to True
    if s.breakGlassConfig.createTokenSaleIsPaused then skip
    else s.breakGlassConfig.createTokenSaleIsPaused := True;

    if s.breakGlassConfig.startSaleIsPaused then skip
    else s.breakGlassConfig.startSaleIsPaused := True;

    if s.breakGlassConfig.closeSaleIsPaused then skip
    else s.breakGlassConfig.closeSaleIsPaused := True;

    if s.breakGlassConfig.setSaleWhitelistIsPaused then skip
    else s.breakGlassConfig.setSaleWhitelistIsPaused := True;

    if s.breakGlassConfig.editSaleIsPaused then skip
    else s.breakGlassConfig.editSaleIsPaused := True;

    if s.breakGlassConfig.pauseSaleIsPaused then skip
    else s.breakGlassConfig.pauseSaleIsPaused := True;

    if s.breakGlassConfig.unpauseSaleIsPaused then skip
    else s.breakGlassConfig.unpauseSaleIsPaused := True;

    if s.breakGlassConfig.distributeTokensIsPaused then skip
    else s.breakGlassConfig.distributeTokensIsPaused := True;

    if s.breakGlassConfig.purchaseIsPaused then skip
    else s.breakGlassConfig.purchaseIsPaused := True;

} with s



// helper function to unpause all entrypoints
function unpauseAllLaunchpadEntrypoints(var s : launchpadStorageType) : launchpadStorageType is 
block {

    // set all pause configs to False
    if s.breakGlassConfig.createTokenSaleIsPaused then s.breakGlassConfig.createTokenSaleIsPaused := False
    else skip;

    if s.breakGlassConfig.createTokenSaleIsPaused then s.breakGlassConfig.createTokenSaleIsPaused := False
    else skip;

    if s.breakGlassConfig.closeSaleIsPaused then s.breakGlassConfig.closeSaleIsPaused := False
    else skip;

    if s.breakGlassConfig.setSaleWhitelistIsPaused then s.breakGlassConfig.setSaleWhitelistIsPaused := False
    else skip;
    
    if s.breakGlassConfig.editSaleIsPaused then s.breakGlassConfig.editSaleIsPaused := False
    else skip;

    if s.breakGlassConfig.pauseSaleIsPaused then s.breakGlassConfig.pauseSaleIsPaused := False
    else skip;

    if s.breakGlassConfig.unpauseSaleIsPaused then s.breakGlassConfig.unpauseSaleIsPaused := False
    else skip;

    if s.breakGlassConfig.distributeTokensIsPaused then s.breakGlassConfig.distributeTokensIsPaused := False
    else skip;

    if s.breakGlassConfig.purchaseIsPaused then s.breakGlassConfig.purchaseIsPaused := False
    else skip;

} with s

// ------------------------------------------------------------------------------
// Pause / BreakGlass Helper Functions End
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Entrypoint Helper Functions Begin
// ------------------------------------------------------------------------------

// helper function to get transfer entrypoint
function getTransferEntrypointFromTokenAddress(const tokenAddress : address) : contract(fa2TransferType) is
    case (Tezos.get_entrypoint_opt(
        "%transfer",
        tokenAddress) : option(contract(fa2TransferType))) of [
                Some(contr) -> contr
            |   None -> (failwith(error_TRANSFER_ENTRYPOINT_IN_FA2_CONTRACT_NOT_FOUND) : contract(fa2TransferType))
        ];


// helper function to get mint entrypoint
function getMintEntrypointFromTokenAddress(const tokenAddress : address) : contract(list(tokenAmountType)) is
    case (Tezos.get_entrypoint_opt(
        "%mint",
        tokenAddress) : option(contract(list(tokenAmountType)))) of [
                Some(contr) -> contr
            |   None -> (failwith(error_MINT_ENTRYPOINT_IN_FA2_CONTRACT_NOT_FOUND) : contract(list(tokenAmountType)))
        ];


// ------------------------------------------------------------------------------
// Entrypoint Helper Functions End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Operations Helper Functions Begin
// ------------------------------------------------------------------------------

function mintFa2Token(const to_ : address; const tokenAmount : nat; const tokenId : nat; const tokenContractAddress : address) : operation is
block{

    const mintParams : list(tokenAmountType) = list[
            record[
                address         = to_;
                token_id        = tokenId;
                amount          = tokenAmount;
            ]
        ];

    const tokenContract : contract(list(tokenAmountType)) =
        case (Tezos.get_entrypoint_opt("%mint", tokenContractAddress) : option(contract(list(tokenAmountType)))) of [
                Some (c) -> c
            |   None     -> (failwith(error_MINT_ENTRYPOINT_IN_FA2_CONTRACT_NOT_FOUND) : contract(list(tokenAmountType)))
        ];
        
} with (Tezos.transaction(mintParams, 0tez, tokenContract))


// ------------------------------------------------------------------------------
// Operations Helper Functions End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// General Helper Functions Begin
// ------------------------------------------------------------------------------

// helper function to get contract address from general contracts map
function getAddressFromGeneralContracts(const contractName : string; const s : launchpadStorageType; const errorCode : nat) : address is 
block {

    const contractAddress : address = case s.generalContracts[contractName] of [
            Some(_address) -> _address
        |   None           -> failwith(errorCode)
    ];

} with contractAddress



// function verifyValidCurrency(const currency : tokenType; const s : launchpadStorageType) : unit is 
// block {

//     case currency of [
//             Tez -> skip
//         |   Fa12(_address) -> if Big_map.mem(_address, s.currencyLedger) then skip else failwith(error_INVALID_CURRENCY)
//         |   Fa2(_fa2Token) -> if Big_map.mem(_fa2Token.tokenContractAddress, s.currencyLedger) then skip else failwith(error_INVALID_CURRENCY)
//     ];

// } with unit



// ------------------------------------------------------------------------------
// Contract Helper Functions End
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Lambda Helper Functions Begin
// ------------------------------------------------------------------------------

// helper function to unpack and execute entrypoint logic stored as bytes in lambdaLedger
function unpackLambda(const lambdaBytes : bytes; const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is 
block {

    const res : return = case (Bytes.unpack(lambdaBytes) : option(launchpadUnpackLambdaFunctionType)) of [
            Some(f) -> f(launchpadLambdaAction, s)
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