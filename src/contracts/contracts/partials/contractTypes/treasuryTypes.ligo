// ------------------------------------------------------------------------------
// Required Types
// ------------------------------------------------------------------------------


// Treasury Transfer Types
#include "../../partials/shared/transferTypes.ligo"


// ------------------------------------------------------------------------------
// Storage Types
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Action Types
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Lambda Action Types
// ------------------------------------------------------------------------------


type treasuryLambdaActionType is 

        // Admin Lambdas
        LambdaSetSuperAdmin                  of (address)
    |   LambdaClaimSuperAdmin                of (unit)
    |   LambdaSetAdmin                       of (address)
    |   LambdaRemoveAdmin                    of (address)

        // Housekeeping Entrypoints
    |   LambdaSetBaker                       of option(key_hash)
    |   LambdaSetName                        of (string)
    |   LambdaUpdateMetadata                 of updateMetadataType
    |   LambdaUpdateWhitelistContracts       of updateWhitelistContractsType
    |   LambdaUpdateGeneralContracts         of updateGeneralContractsType
    |   LambdaUpdateWhitelistTokens          of updateWhitelistTokenContractsType

        // Treasury Entrypoints
    |   LambdaTransfer                       of transferActionType

    |   LambdaUpdateMvkOperators             of updateOperatorsType
    |   LambdaStakeMvk                       of (nat)
    |   LambdaUnstakeMvk                     of (nat)


// ------------------------------------------------------------------------------
// Storage
// ------------------------------------------------------------------------------


type treasuryStorageType is [@layout:comb] record [
    
    superAdmin                : address;
    newSuperAdmin             : option(address);
    admins                    : set(address);

    metadata                   : metadataType;

    whitelistContracts         : whitelistContractsType;
    generalContracts           : generalContractsType;
    whitelistTokenContracts    : whitelistTokenContractsType;

    lambdaLedger               : lambdaLedgerType;
]