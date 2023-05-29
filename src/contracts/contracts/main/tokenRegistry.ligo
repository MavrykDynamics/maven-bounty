// ------------------------------------------------------------------------------
// Error Codes
// ------------------------------------------------------------------------------

// Error Codes
#include "../partials/errors.ligo"

// ------------------------------------------------------------------------------
// Shared Helpers and Types
// ------------------------------------------------------------------------------

// Shared Helpers
#include "../partials/shared/sharedHelpers.ligo"

// ------------------------------------------------------------------------------
// Contract Types
// ------------------------------------------------------------------------------

// TokenRegistry Types
#include "../partials/contractTypes/tokenRegistryTypes.ligo"

// ------------------------------------------------------------------------------

type action is

        // Housekeeping Entrypoints
        SetAdmin                    of (address)
    |   SetGovernance               of (address)
    |   UpdateMetadata              of updateMetadataType
    |   UpdateConfig                of tokenRegistryUpdateConfigParamsType
    |   UpdateWhitelistContracts    of updateWhitelistContractsType
    |   UpdateGeneralContracts      of updateGeneralContractsType
    |   MistakenTransfer            of transferActionType

        // Pause / Break Glass Entrypoints
    |   PauseAll                    of (unit)
    |   UnpauseAll                  of (unit)
    |   TogglePauseEntrypoint       of tokenRegistryTogglePauseEntrypointType

        // TokenRegistry Entrypoints
    |   AddToken                    of addTokenActionType
    |   RemoveToken                 of removeTokenActionType
    
        // Lambda Entrypoints
    |   SetLambda                   of setLambdaType
    
    
type return is list (operation) * tokenRegistryStorageType
const noOperations : list (operation) = nil;


// tokenRegistry contract methods lambdas
type tokenRegistryUnpackLambdaFunctionType is (tokenRegistryLambdaActionType * tokenRegistryStorageType) -> return


// ------------------------------------------------------------------------------
// Helpers
// ------------------------------------------------------------------------------

// TokenRegistry Helpers:
#include "../partials/contractHelpers/tokenRegistryHelpers.ligo"

// ------------------------------------------------------------------------------
// Views
// ------------------------------------------------------------------------------

// TokenRegistry Views:
#include "../partials/contractViews/tokenRegistryViews.ligo"

// ------------------------------------------------------------------------------
// Lambdas
// ------------------------------------------------------------------------------

// TokenRegistry Lambdas:
#include "../partials/contractLambdas/tokenRegistryLambdas.ligo"

// ------------------------------------------------------------------------------
// Entrypoints
// ------------------------------------------------------------------------------

// TokenRegistry Entrypoints:
#include "../partials/contractEntrypoints/tokenRegistryEntrypoints.ligo"

// ------------------------------------------------------------------------------

(* main entrypoint *)
function main (const action : action; const s : tokenRegistryStorageType) : return is

    case action of [

            // Housekeeping Entrypoints
            SetAdmin(parameters)                  -> setAdmin(parameters, s)
        |   SetGovernance(parameters)             -> setGovernance(parameters, s)
        |   UpdateMetadata(parameters)            -> updateMetadata(parameters, s)
        |   UpdateConfig(parameters)              -> updateConfig(parameters, s)
        |   UpdateWhitelistContracts(parameters)  -> updateWhitelistContracts(parameters, s)
        |   UpdateGeneralContracts(parameters)    -> updateGeneralContracts(parameters, s)
        |   MistakenTransfer(parameters)          -> mistakenTransfer(parameters, s)

            // Pause / Break Glass Entrypoints
        |   PauseAll(_parameters)                 -> pauseAll(s)
        |   UnpauseAll(_parameters)               -> unpauseAll(s)
        |   TogglePauseEntrypoint(parameters)     -> togglePauseEntrypoint(parameters, s)

            // TokenRegistry Entrypoints
        |   AddToken(parameters)                  -> addToken(parameters, s)  
        |   RemoveToken(parameters)               -> removeToken(parameters, s)  
        
            // Lambda Entrypoints
        |   SetLambda(parameters)                 -> setLambda(parameters, s)
    ]

