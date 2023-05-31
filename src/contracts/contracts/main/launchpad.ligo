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

// Launchpad Types
#include "../partials/contractTypes/launchpadTypes.ligo"

// ------------------------------------------------------------------------------

type action is

        // Admin Entrypoints
        SetSuperAdmin               of (address)
    |   ClaimSuperAdmin             of (unit)
    |   SetAdmin                    of (address)
    |   RemoveAdmin                 of (address)

        // Housekeeping Entrypoints
    |   UpdateMetadata              of updateMetadataType
    |   UpdateConfig                of launchpadUpdateConfigParamsType
    |   UpdateWhitelistContracts    of updateWhitelistContractsType
    |   UpdateGeneralContracts      of updateGeneralContractsType
    |   MistakenTransfer            of transferActionType

        // Pause / Break Glass Entrypoints
    |   PauseAll                    of (unit)
    |   UnpauseAll                  of (unit)
    |   TogglePauseEntrypoint       of launchpadTogglePauseEntrypointType

        // Launchpad Entrypoints
    |   CreateTokenSale             of createTokenSaleActionType
    |   SetSaleWhitelist            of setSaleWhitelistActionType
    |   StartSale                   of startSaleActionType 
    |   CloseSale                   of closeSaleActionType
    |   EditSale                    of editSaleActionType
    |   PauseSale                   of pauseSaleActionType
    |   UnpauseSale                 of unpauseSaleActionType
    |   DistributeTokens            of distributeTokensActionType
    
        // Lambda Entrypoints
    |   SetLambda                   of setLambdaType
    
    
type return is list (operation) * launchpadStorageType
const noOperations : list (operation) = nil;


// launchpad contract methods lambdas
type launchpadUnpackLambdaFunctionType is (launchpadLambdaActionType * launchpadStorageType) -> return


// ------------------------------------------------------------------------------
// Helpers
// ------------------------------------------------------------------------------

// Launchpad Helpers:
#include "../partials/contractHelpers/launchpadHelpers.ligo"

// ------------------------------------------------------------------------------
// Views
// ------------------------------------------------------------------------------

// Launchpad Views:
#include "../partials/contractViews/launchpadViews.ligo"

// ------------------------------------------------------------------------------
// Lambdas
// ------------------------------------------------------------------------------

// Launchpad Lambdas:
#include "../partials/contractLambdas/launchpadLambdas.ligo"

// ------------------------------------------------------------------------------
// Entrypoints
// ------------------------------------------------------------------------------

// Launchpad Entrypoints:
#include "../partials/contractEntrypoints/launchpadEntrypoints.ligo"

// ------------------------------------------------------------------------------

(* main entrypoint *)
function main (const action : action; const s : launchpadStorageType) : return is

    case action of [

            // Admin Entrypoints
            SetSuperAdmin(parameters)             -> setSuperAdmin(parameters, s)
        |   ClaimSuperAdmin(_parameters)          -> claimSuperAdmin(s)
        |   SetAdmin(parameters)                  -> setAdmin(parameters, s)
        |   RemoveAdmin(parameters)               -> removeAdmin(parameters, s)

            // Housekeeping Entrypoints
        |   UpdateMetadata(parameters)            -> updateMetadata(parameters, s)
        |   UpdateConfig(parameters)              -> updateConfig(parameters, s)
        |   UpdateWhitelistContracts(parameters)  -> updateWhitelistContracts(parameters, s)
        |   UpdateGeneralContracts(parameters)    -> updateGeneralContracts(parameters, s)
        |   MistakenTransfer(parameters)          -> mistakenTransfer(parameters, s)

            // Pause / Break Glass Entrypoints
        |   PauseAll(_parameters)                 -> pauseAll(s)
        |   UnpauseAll(_parameters)               -> unpauseAll(s)
        |   TogglePauseEntrypoint(parameters)     -> togglePauseEntrypoint(parameters, s)

            // Launchpad Entrypoints
        |   CreateTokenSale(parameters)           -> createTokenSale(parameters, s)  
        |   SetSaleWhitelist(parameters)          -> setSaleWhitelist(parameters, s)  
        |   StartSale(parameters)                 -> startSale(parameters, s)  
        |   CloseSale(parameters)                 -> closeSale(parameters, s)  
        |   EditSale(parameters)                  -> editSale(parameters, s)
        |   PauseSale(parameters)                 -> pauseSale(parameters, s)
        |   UnpauseSale(parameters)               -> unpauseSale(parameters, s)
        |   DistributeTokens(parameters)          -> distributeTokens(parameters, s)
        
            // Lambda Entrypoints
        |   SetLambda(parameters)                 -> setLambda(parameters, s)
    ]

