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

// Transfer Helpers
#include "../partials/shared/transferHelpers.ligo"

// Constants
#include "../partials/shared/constants.ligo"

// ------------------------------------------------------------------------------
// Contract Types
// ------------------------------------------------------------------------------

// Marketplace Types
#include "../partials/contractTypes/marketplaceTypes.ligo"

// ------------------------------------------------------------------------------

type action is

        // Admin Entrypoints
        SetSuperAdmin               of (address)
    |   ClaimSuperAdmin             of (unit)
    |   SetAdmin                    of (address)
    |   RemoveAdmin                 of (address)

        // Housekeeping Entrypoints
    |   UpdateMetadata              of updateMetadataType
    |   UpdateConfig                of marketplaceUpdateConfigParamsType
    |   UpdateWhitelistContracts    of updateWhitelistContractsType
    |   UpdateGeneralContracts      of updateGeneralContractsType
    |   MistakenTransfer            of transferActionType

        // Pause / Break Glass Entrypoints
    |   PauseAll                    of (unit)
    |   UnpauseAll                  of (unit)
    |   TogglePauseEntrypoint       of marketplaceTogglePauseEntrypointType

        // Marketplace Admin Entrypoints
    |   SetCurrency                 of setCurrencyActionType

        // Marketplace Entrypoints
    |   CreateListing               of createListingActionType
    |   EditListing                 of editListingActionType
    |   RemoveListing               of removeListingActionType
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

            // Marketplace Admin Entrypoints
        |   SetCurrency(parameters)               -> setCurrency(parameters, s)

            // Marketplace Entrypoints
        |   CreateListing(parameters)             -> createListing(parameters, s)  
        |   EditListing(parameters)               -> editListing(parameters, s)  
        |   RemoveListing(parameters)             -> removeListing(parameters, s)  
        |   Purchase(parameters)                  -> purchase(parameters, s)
        |   Offer(parameters)                     -> offer(parameters, s)
        |   AcceptOffer(parameters)               -> acceptOffer(parameters, s)
        |   RemoveOffer(parameters)               -> removeOffer(parameters, s)

            // Lambda Entrypoints
        |   SetLambda(parameters)                 -> setLambda(parameters, s)
    ]

