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

// Marketplace Types
#include "../partials/contractTypes/marketplaceTypes.ligo"

// ------------------------------------------------------------------------------

type action is

        // Housekeeping Entrypoints
        SetAdmin                    of (address)
    |   SetGovernance               of (address)
    |   UpdateMetadata              of updateMetadataType
    |   UpdateConfig                of marketplaceUpdateConfigParamsType
    |   UpdateWhitelistContracts    of updateWhitelistContractsType
    |   UpdateGeneralContracts      of updateGeneralContractsType
    |   MistakenTransfer            of transferActionType

        // Pause / Break Glass Entrypoints
    |   PauseAll                    of (unit)
    |   UnpauseAll                  of (unit)
    |   TogglePauseEntrypoint       of marketplaceTogglePauseEntrypointType

        // Marketplace Entrypoints
    |   List                        of listActionType
    |   Delist                      of delistActionType
    |   Purchase                    of purchaseActionType
    |   Offer                       of offerActionType
    |   AcceptOffer                 of acceptOfferActionType
    |   RemoveOffer                 of removeOfferActionType
    
        // Lambda Entrypoints
    |   SetLambda                   of setLambdaType
    
    
type return is list (operation) * marketplaceStorageType
const noOperations : list (operation) = nil;


// marketplace contract methods lambdas
type marketplaceUnpackLambdaFunctionType is (marketplaceLambdaActionType * marketplaceStorageType) -> return


// ------------------------------------------------------------------------------
// Helpers
// ------------------------------------------------------------------------------

// Marketplace Helpers:
#include "../partials/contractHelpers/marketplaceHelpers.ligo"

// ------------------------------------------------------------------------------
// Views
// ------------------------------------------------------------------------------

// Marketplace Views:
#include "../partials/contractViews/marketplaceViews.ligo"

// ------------------------------------------------------------------------------
// Lambdas
// ------------------------------------------------------------------------------

// Marketplace Lambdas:
#include "../partials/contractLambdas/marketplaceLambdas.ligo"

// ------------------------------------------------------------------------------
// Entrypoints
// ------------------------------------------------------------------------------

// Marketplace Entrypoints:
#include "../partials/contractEntrypoints/marketplaceEntrypoints.ligo"

// ------------------------------------------------------------------------------

(* main entrypoint *)
function main (const action : action; const s : marketplaceStorageType) : return is

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

            // Marketplace Entrypoints
        |   List(parameters)                      -> list(parameters, s)  
        |   Delist(parameters)                    -> delist(parameters, s)  
        |   Purchase(parameters)                  -> purchase(parameters, s)
        |   Offer(parameters)                     -> offer(parameters, s)
        |   AcceptOffer(parameters)               -> acceptOffer(parameters, s)
        |   RemoveOffer(parameters)               -> removeOffer(parameters, s)

            // Lambda Entrypoints
        |   SetLambda(parameters)                 -> setLambda(parameters, s)
    ]

