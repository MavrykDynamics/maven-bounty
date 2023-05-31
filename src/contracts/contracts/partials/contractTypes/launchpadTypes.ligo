// ------------------------------------------------------------------------------
// Storage Types
// ------------------------------------------------------------------------------

type launchpadBreakGlassConfigType is [@layout:comb] record [
    launchNewTokenIsPaused          : bool;
    startNewSaleIsPaused            : bool;
    setSaleWhitelistIsPaused        : bool;
    editSaleIsPaused                : bool;
    pauseSaleIsPaused               : bool;
    unpauseSaleIsPaused             : bool;
    distributeTokensIsPaused        : bool;
]

type launchpadConfigType is [@layout:comb] record [
    minOfferAmount   : nat;
    empty            : unit
];

type whitelistAccessType is 

type saleRecordType is [@layout:comb] record [
    name            : string;
    whitelist       : map(address, nat);
    isPaused        : bool;
    pricing         : map(string, nat);
]
type saleLedgerType is big_map(nat, saleRecordType);

// ------------------------------------------------------------------------------
// Action Types
// ------------------------------------------------------------------------------

type launchpadUpdateConfigNewValueType is nat
type launchpadUpdateConfigActionType is 
        ConfigMiOfferAmount          of unit
    |   Empty                       of unit

type launchpadUpdateConfigParamsType is [@layout:comb] record [
    updateConfigNewValue    : launchpadUpdateConfigNewValueType; 
    updateConfigAction      : launchpadUpdateConfigActionType;
]


type launchpadPausableEntrypointType is
        LaunchNewToken              of bool
    |   StartNewSale                of bool
    |   EditSale                    of bool
    |   PauseSale                   of bool
    |   UnpauseSale                 of bool
    |   DistributeTokens            of bool
    
type launchpadTogglePauseEntrypointType is [@layout:comb] record [
    targetEntrypoint  : launchpadPausableEntrypointType;
    empty             : unit
];


// ------------------------------------------------------------------------------
// Lambda Action Types
// ------------------------------------------------------------------------------


type launchpadLambdaActionType is 

        // Admin Lambdas
        LambdaSetSuperAdmin               of (address)
    |   LambdaClaimSuperAdmin             of (unit)
    |   LambdaSetAdmin                    of (address)
    |   LambdaRemoveAdmin                 of (address)

        // Housekeeping Lambdas
    |   LambdaUpdateMetadata              of updateMetadataType
    |   LambdaUpdateConfig                of launchpadUpdateConfigParamsType
    |   LambdaUpdateWhitelistContracts    of updateWhitelistContractsType
    |   LambdaUpdateGeneralContracts      of updateGeneralContractsType
    |   LambdaMistakenTransfer            of transferActionType

        // Pause / Break Glass Lambdas
    |   LambdaPauseAll                    of (unit)
    |   LambdaUnpauseAll                  of (unit)
    |   LambdaTogglePauseEntrypoint       of launchpadTogglePauseEntrypointType

        // Launchpad Lambdas
    |   LambdaCreateTokenSale             of (nat)
    |   LambdaStartSale                   of (nat)
    |   LambdaSetSaleWhitelist            of (nat)
    |   LambdaEditSale                    of (unit)
    |   LambdaPauseSale                   of (address)
    |   LambdaUnpauseSale                 of (address)
    |   LambdaDistributeTokens            of (address)

// ------------------------------------------------------------------------------
// Storage
// ------------------------------------------------------------------------------


type launchpadStorageType is [@layout:comb] record [
    
    superAdmin                : address;
    newSuperAdmin             : option(address);
    admins                    : set(address);

    metadata                  : metadataType;
    config                    : launchpadConfigType;

    whitelistContracts        : whitelistContractsType;    
    generalContracts          : generalContractsType;

    saleLedger                : saleLedgerType;
    
    lambdaLedger              : lambdaLedgerType;
]

