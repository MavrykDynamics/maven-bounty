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


type saleWhitelistRecordType is [@layout:comb] record [
    allowed         : map(string, nat);
    purchased       : map(string, nat);
]
type saleWhitelistLedgerType is big_map((nat * address), saleWhitelistRecordType)


type saleRecordType is [@layout:comb] record [
    name            : string;
    isPaused        : bool;
    status          : string;

    saleStart       : timestamp;
    saleEnd         : timestamp;

    pricing         : map(string, nat);
]
type saleLedgerType is big_map(nat, saleRecordType)



type salePurchaseRecordType is [@layout:comb] record [

]
type salePurchasaeLedgerType is big_map((nat * address), salePurchaseRecordType)

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
    saleWhitelistLedger       : saleWhitelistLedgerType;
    salePurchaseLedger        : salePurchasaeLedgerType;
    lastSaleId                : nat;
    
    lambdaLedger              : lambdaLedgerType;
]

