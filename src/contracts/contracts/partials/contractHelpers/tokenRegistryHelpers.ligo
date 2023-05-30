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
function pauseAllTokenRegistryEntrypoints(var s : tokenRegistryStorageType) : tokenRegistryStorageType is 
block {

    // set all pause configs to True
    if s.breakGlassConfig.setTokenIsPaused then skip
    else s.breakGlassConfig.setTokenIsPaused := True;

    if s.breakGlassConfig.removeTokenIsPaused then skip
    else s.breakGlassConfig.removeTokenIsPaused := True;

} with s



// helper function to unpause all entrypoints
function unpauseAllTokenRegistryEntrypoints(var s : tokenRegistryStorageType) : tokenRegistryStorageType is 
block {

    // set all pause configs to False
    if s.breakGlassConfig.setTokenIsPaused then s.breakGlassConfig.setTokenIsPaused := False
    else skip;

    if s.breakGlassConfig.removeTokenIsPaused then s.breakGlassConfig.removeTokenIsPaused := False
    else skip;

} with s

// ------------------------------------------------------------------------------
// Pause / BreakGlass Helper Functions End
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Entrypoint Helper Functions Begin
// ------------------------------------------------------------------------------


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
function unpackLambda(const lambdaBytes : bytes; const tokenRegistryLambdaAction : tokenRegistryLambdaActionType; var s : tokenRegistryStorageType) : return is 
block {

    const res : return = case (Bytes.unpack(lambdaBytes) : option(tokenRegistryUnpackLambdaFunctionType)) of [
            Some(f) -> f(tokenRegistryLambdaAction, s)
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