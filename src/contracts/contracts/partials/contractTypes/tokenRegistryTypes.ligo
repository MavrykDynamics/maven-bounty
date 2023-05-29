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

type tokenRegistryUpdateConfigNewValueType is nat
type tokenRegistryUpdateConfigActionType is 
        ConfigMiOfferAmount          of unit
    |   Empty                       of unit

type tokenRegistryUpdateConfigParamsType is [@layout:comb] record [
    updateConfigNewValue    : tokenRegistryUpdateConfigNewValueType; 
    updateConfigAction      : tokenRegistryUpdateConfigActionType;
]


type tokenRegistryPausableEntrypointType is
        AddToken              of bool
    |   RemoveToken                of bool
    
type tokenRegistryTogglePauseEntrypointType is [@layout:comb] record [
    targetEntrypoint  : tokenRegistryPausableEntrypointType;
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
    |   LambdaUpdateConfig                of tokenRegistryUpdateConfigParamsType
    |   LambdaUpdateWhitelistContracts    of updateWhitelistContractsType
    |   LambdaUpdateGeneralContracts      of updateGeneralContractsType
    |   LambdaMistakenTransfer            of transferActionType

        // Pause / Break Glass Lambdas
    |   LambdaPauseAll                    of (unit)
    |   LambdaUnpauseAll                  of (unit)
    |   LambdaTogglePauseEntrypoint       of tokenRegistryTogglePauseEntrypointType

        // TokenRegistry Lambdas
    |   LambdaAddToken                    of (nat)
    |   LambdaRemoveSale                  of (nat)

// ------------------------------------------------------------------------------
// Storage
// ------------------------------------------------------------------------------


type tokenRegistryStorageType is [@layout:comb] record [
    
    admin                     : address;
    metadata                  : metadataType;
    config                    : tokenRegistryConfigType;


    whitelistContracts        : whitelistContractsType;    
    generalContracts          : generalContractsType;
    
    lambdaLedger              : lambdaLedgerType;
]

