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
    if s.breakGlassConfig.createListingIsPaused then skip
    else s.breakGlassConfig.createListingIsPaused := True;

    if s.breakGlassConfig.removeListingIsPaused then skip
    else s.breakGlassConfig.removeListingIsPaused := True;

    if s.breakGlassConfig.purchaseIsPaused then skip
    else s.breakGlassConfig.purchaseIsPaused := True;

    if s.breakGlassConfig.offerIsPaused then skip
    else s.breakGlassConfig.offerIsPaused := True;

    if s.breakGlassConfig.acceptOfferIsPaused then skip
    else s.breakGlassConfig.acceptOfferIsPaused := True;

    if s.breakGlassConfig.removeOfferIsPaused then skip
    else s.breakGlassConfig.removeOfferIsPaused := True;

    if s.breakGlassConfig.setCurrencyIsPaused then skip
    else s.breakGlassConfig.setCurrencyIsPaused := True;

    if s.breakGlassConfig.removeCurrencyIsPaused then skip
    else s.breakGlassConfig.removeCurrencyIsPaused := True;

} with s



// helper function to unpause all entrypoints
function unpauseAllMarketplaceEntrypoints(var s : marketplaceStorageType) : marketplaceStorageType is 
block {

    // set all pause configs to False
    if s.breakGlassConfig.createListingIsPaused then s.breakGlassConfig.createListingIsPaused := False
    else skip;

    if s.breakGlassConfig.removeListingIsPaused then s.breakGlassConfig.removeListingIsPaused := False
    else skip;

    if s.breakGlassConfig.purchaseIsPaused then s.breakGlassConfig.purchaseIsPaused := False
    else skip;

    if s.breakGlassConfig.offerIsPaused then s.breakGlassConfig.offerIsPaused := False
    else skip;
    
    if s.breakGlassConfig.acceptOfferIsPaused then s.breakGlassConfig.acceptOfferIsPaused := False
    else skip;

    if s.breakGlassConfig.removeOfferIsPaused then s.breakGlassConfig.removeOfferIsPaused := False
    else skip;

    if s.breakGlassConfig.setCurrencyIsPaused then s.breakGlassConfig.setCurrencyIsPaused := False
    else skip;

    if s.breakGlassConfig.removeCurrencyIsPaused then s.breakGlassConfig.removeCurrencyIsPaused := False
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

function verifyValidCurrency(const currency : tokenType; const s : marketplaceStorageType) : unit is 
block {

    skip

} with unit


function verifyListingOwnership(const listInitiator : address; const sender : address) : unit is 
block {

    if listInitiator = sender then skip else failwith(error_SENDER_IS_NOT_LISTING_INITIATOR);

} with unit

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