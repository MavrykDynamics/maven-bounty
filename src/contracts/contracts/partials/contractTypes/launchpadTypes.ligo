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

        // Housekeeping Lambdas
        LambdaSetAdmin                    of address
    |   LambdaSetGovernance               of (address)
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
    |   LambdaLaunchNewToken              of (nat)
    |   LambdaStartNewSale                of (nat)
    |   LambdaSetSaleWhitelist            of (nat)
    |   LambdaEditSale                    of (unit)
    |   LambdaPauseSale                   of (address)
    |   LambdaUnpauseSale                 of (address)
    |   LambdaDistributeTokens            of (address)

// ------------------------------------------------------------------------------
// Storage
// ------------------------------------------------------------------------------


type launchpadStorageType is [@layout:comb] record [
    
    admin                     : address;
    metadata                  : metadataType;
    config                    : launchpadConfigType;


    whitelistContracts        : whitelistContractsType;    
    generalContracts          : generalContractsType;
    
    lambdaLedger              : lambdaLedgerType;
]

