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

// ------------------------------------------------------------------------------
// Contract Types
// ------------------------------------------------------------------------------

// Treasury Types
#include "../partials/contractTypes/treasuryTypes.ligo"

// ------------------------------------------------------------------------------

type treasuryAction is 

    |   Default                         of unit

        // Admin Entrypoints
    |   SetSuperAdmin                   of (address)
    |   ClaimSuperAdmin                 of (unit)
    |   SetAdmin                        of (address)
    |   RemoveAdmin                     of (address)

        // Housekeeping Entrypoints
    |   SetBaker                        of option(key_hash)
    |   UpdateMetadata                  of updateMetadataType
    |   UpdateWhitelistContracts        of updateWhitelistContractsType
    |   UpdateGeneralContracts          of updateGeneralContractsType
    |   UpdateWhitelistTokenContracts   of updateWhitelistTokenContractsType

        // Treasury Entrypoints
    |   Transfer                        of transferActionType

        // Staking Entrypoints
    |   UpdateMvkOperators              of updateOperatorsType
    |   StakeMvk                        of (nat)
    |   UnstakeMvk                      of (nat)

        // Lambda Entrypoints
    |   SetLambda                       of setLambdaType


const noOperations : list (operation) = nil;
type return is list (operation) * treasuryStorageType

// treasury contract methods lambdas
type treasuryUnpackLambdaFunctionType is (treasuryLambdaActionType * treasuryStorageType) -> return


// ------------------------------------------------------------------------------
// Helpers
// ------------------------------------------------------------------------------

// Treasury Helpers:
#include "../partials/contractHelpers/treasuryHelpers.ligo"

// ------------------------------------------------------------------------------
// Views
// ------------------------------------------------------------------------------

// Treasury Views:
#include "../partials/contractViews/treasuryViews.ligo"

// ------------------------------------------------------------------------------
// Lambdas
// ------------------------------------------------------------------------------

// Treasury Lambdas :
#include "../partials/contractLambdas/treasuryLambdas.ligo"

// ------------------------------------------------------------------------------
// Entrypoints
// ------------------------------------------------------------------------------

// Treasury Entrypoints:
#include "../partials/contractEntrypoints/treasuryEntrypoints.ligo"

// ------------------------------------------------------------------------------


(* main entrypoint *)
function main (const action : treasuryAction; const s : treasuryStorageType) : return is 
    
    case action of [

        |   Default(_params)                                -> ((nil : list(operation)), s)
        
            // Admin Entrypoints
        |   SetSuperAdmin(parameters)                       -> setSuperAdmin(parameters, s)
        |   ClaimSuperAdmin(_parameters)                    -> claimSuperAdmin(s)
        |   SetAdmin(parameters)                            -> setAdmin(parameters, s)
        |   RemoveAdmin(parameters)                         -> removeAdmin(parameters, s)

            // Housekeeping Entrypoints
        |   SetBaker(parameters)                            -> setBaker(parameters, s)
        |   UpdateMetadata(parameters)                      -> updateMetadata(parameters, s)
        |   UpdateWhitelistContracts(parameters)            -> updateWhitelistContracts(parameters, s)
        |   UpdateGeneralContracts(parameters)              -> updateGeneralContracts(parameters, s)
        |   UpdateWhitelistTokenContracts(parameters)       -> updateWhitelistTokenContracts(parameters, s)

            // Treasury Entrypoints
        |   Transfer(parameters)                            -> transfer(parameters, s)

            // Staking Entrypoints
        |   UpdateMvkOperators(parameters)                  -> updateMvkOperators(parameters, s)
        |   StakeMvk(parameters)                            -> stakeMvk(parameters, s)
        |   UnstakeMvk(parameters)                          -> unstakeMvk(parameters, s)

            // Lambda Entrypoints
        |   SetLambda(parameters)                           -> setLambda(parameters, s)
    ]
