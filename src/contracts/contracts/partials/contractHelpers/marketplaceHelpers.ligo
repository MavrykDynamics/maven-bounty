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
function pauseAllMarketplaceEntrypoints(var s : marketplaceStorageType) : marketplaceStorageType is 
block {

    // set all pause configs to True
    if s.breakGlassConfig.listIsPaused then skip
    else s.breakGlassConfig.listIsPaused := True;

    if s.breakGlassConfig.purchaseIsPaused then skip
    else s.breakGlassConfig.purchaseIsPaused := True;

    if s.breakGlassConfig.offerIsPaused then skip
    else s.breakGlassConfig.offerIsPaused := True;

    if s.breakGlassConfig.acceptOfferIsPaused then skip
    else s.breakGlassConfig.acceptOfferIsPaused := True;

} with s



// helper function to unpause all entrypoints
function unpauseAllMarketplceEntrypoints(var s : marketplaceStorageType) : marketplaceStorageType is 
block {

    // set all pause configs to False
    if s.breakGlassConfig.listIsPaused then s.breakGlassConfig.listIsPaused := False
    else skip;

    if s.breakGlassConfig.purchaseIsPaused then s.breakGlassConfig.purchaseIsPaused := False
    else skip;

    if s.breakGlassConfig.offerIsPaused then s.breakGlassConfig.offerIsPaused := False
    else skip;
    
    if s.breakGlassConfig.acceptOfferIsPaused then s.breakGlassConfig.acceptOfferIsPaused := False
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

// ------------------------------------------------------------------------------
// Entrypoint Helper Functions End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Operations Helper Functions Begin
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Operations Helper Functions End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// General Helper Functions Begin
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Contract Helper Functions End
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Lambda Helper Functions Begin
// ------------------------------------------------------------------------------

// helper function to unpack and execute entrypoint logic stored as bytes in lambdaLedger
function unpackLambda(const lambdaBytes : bytes; const marketplaceLambdaAction : marketplaceLambdaActionType; var s : marketplaceStorageType) : return is 
block {

    const res : return = case (Bytes.unpack(lambdaBytes) : option(marketplaceUnpackLambdaFunctionType)) of [
            Some(f) -> f(marketplaceLambdaAction, s)
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