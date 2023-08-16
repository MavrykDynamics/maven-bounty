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

// Bounty Types
#include "../partials/contractTypes/bountyTypes.ligo"

// ------------------------------------------------------------------------------

type action is

    |   Default                     of unit

        // Admin Entrypoints
    |   SetSuperAdmin               of (address)
    |   ClaimSuperAdmin             of (unit)
    |   SetAdmin                    of (address)
    |   RemoveAdmin                 of (address)

        // Housekeeping Entrypoints
    |   UpdateMetadata              of updateMetadataType
    |   UpdateConfig                of bountyUpdateConfigParamsType
    |   UpdateWhitelistContracts    of updateWhitelistContractsType
    |   UpdateGeneralContracts      of updateGeneralContractsType
    |   MistakenTransfer            of transferActionType

        // Pause / Break Glass Entrypoints
    |   PauseAll                    of (unit)
    |   UnpauseAll                  of (unit)
    |   TogglePauseEntrypoint       of bountyTogglePauseEntrypointType

        // Bounty Admin Entrypoints
    |   SetBountyCreator            of updateWhitelistContractsType
    |   SetBounty                   of setBountyActionType
    |   TogglePauseBounty           of togglePauseBountyActionType
    |   ApproveOrReject             of approveOrRejectActionType
    |   ReviewBounty                of reviewBountyActionType
    |   SendBountyReward            of sendBountyRewardActionType

        // Bounty Entrypoints
    |   ApplyForBounty              of applyForBountyActionType
    |   CancelApplication           of cancelApplicationActionType
    |   CompleteBounty              of completeBountyActionType
    |   StopBounty                  of stopBountyActionType

        // Lambda Entrypoints
    |   SetLambda                   of setLambdaType
    
    
type return is list (operation) * bountyStorageType
const noOperations : list (operation) = nil;


// Bounty contract methods lambdas
type bountyUnpackLambdaFunctionType is (bountyLambdaActionType * bountyStorageType) -> return


// ------------------------------------------------------------------------------
// Helpers
// ------------------------------------------------------------------------------

// Bounty Helpers:
#include "../partials/contractHelpers/bountyHelpers.ligo"

// ------------------------------------------------------------------------------
// Views
// ------------------------------------------------------------------------------

// Bounty Views:
#include "../partials/contractViews/bountyViews.ligo"

// ------------------------------------------------------------------------------
// Lambdas
// ------------------------------------------------------------------------------

// Bounty Lambdas:
#include "../partials/contractLambdas/bountyLambdas.ligo"

// ------------------------------------------------------------------------------
// Entrypoints
// ------------------------------------------------------------------------------

// Bounty Entrypoints:
#include "../partials/contractEntrypoints/bountyEntrypoints.ligo"

// ------------------------------------------------------------------------------

(* main entrypoint *)
function main (const action : action; const s : bountyStorageType) : return is

    case action of [

        |   Default(_params)                      -> ((nil : list(operation)), s)

            // Admin Entrypoints
        |   SetSuperAdmin(parameters)             -> setSuperAdmin(parameters, s)
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

            // Bounty Admin Entrypoints
        |   SetBountyCreator(parameters)          -> setBountyCreator(parameters, s)
        |   SetBounty(parameters)                 -> setBounty(parameters, s)
        |   TogglePauseBounty(parameters)         -> togglePauseBounty(parameters, s)
        |   ApproveOrReject(parameters)           -> approveOrReject(parameters, s)
        |   ReviewBounty(parameters)              -> reviewBounty(parameters, s)
        |   SendBountyReward(parameters)          -> sendBountyReward(parameters, s)

            // Bounty Entrypoints
        |   ApplyForBounty(parameters)            -> applyForBounty(parameters, s)  
        |   CancelApplication(parameters)         -> cancelApplication(parameters, s)  
        |   CompleteBounty(parameters)            -> completeBounty(parameters, s)  
        |   StopBounty(parameters)                -> stopBounty(parameters, s)  

            // Lambda Entrypoints
        |   SetLambda(parameters)                 -> setLambda(parameters, s)
    ]

