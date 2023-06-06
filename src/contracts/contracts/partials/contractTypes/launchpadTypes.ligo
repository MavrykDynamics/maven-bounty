// ------------------------------------------------------------------------------
// Storage Types
// ------------------------------------------------------------------------------

type launchpadBreakGlassConfigType is [@layout:comb] record [
    createTokenSaleIsPaused         : bool;
    startSaleIsPaused               : bool;
    closeSaleIsPaused               : bool;
    setSaleWhitelistIsPaused        : bool;
    editSaleIsPaused                : bool;
    pauseSaleIsPaused               : bool;
    unpauseSaleIsPaused             : bool;
    distributeTokensIsPaused        : bool;
    purchaseIsPaused                : bool;
]

type launchpadConfigType is [@layout:comb] record [
    minOfferAmount   : nat;
    empty            : unit
];


type saleWhitelistRecordType is [@layout:comb] record [
    allowed         : map(string, nat);
]
type saleWhitelistLedgerType is big_map((nat * address), saleWhitelistRecordType)


type tokenSaleOptionType is [@layout:comb] record [    
    maxAmountCap                : nat;
    totalBought                 : nat;
    maxAmountPerWalletTotal     : option(nat);
    price                       : nat; 
    currency                    : tokenType;
]
type saleRecordType is [@layout:comb] record [
    name                        : string;
    isPaused                    : bool;     // TRUE / FALSE
    status                      : string;   // ACTIVE / INACTIVE / PAUSED / CLOSED
    tokenIssuanceType           : string;   // mint / transfer
    tokenDistributionType       : string;   // auto / manual
    tokenContractAddress        : address;
    tokenId                     : nat;
    saleStart                   : timestamp;
    saleEnd                     : option(timestamp);
    saleOptions                 : map(string, tokenSaleOptionType);
    defaultWhitelistOptions     : map(string, nat);
]
type saleLedgerType is big_map(nat, saleRecordType)


type salePurchaseRecordType is [@layout:comb] record [
    purchased       : map(string, nat);  // breakdown by sale options (if there's multiple)
    totalPurchased  : nat;               // total purchased (model only assumes one token)
]
type salePurchaseLedgerType is big_map((nat * address), salePurchaseRecordType)

// ------------------------------------------------------------------------------
// Action Types
// ------------------------------------------------------------------------------

type launchpadUpdateConfigNewValueType is nat
type launchpadUpdateConfigActionType is 
        ConfigMinOfferAmount        of unit
    |   Empty                       of unit

type launchpadUpdateConfigParamsType is [@layout:comb] record [
    updateConfigNewValue    : launchpadUpdateConfigNewValueType; 
    updateConfigAction      : launchpadUpdateConfigActionType;
]


type launchpadPausableEntrypointType is
        CreateTokenSale             of bool
    |   SetSaleWhitelist            of bool
    |   StartSale                   of bool
    |   CloseSale                   of bool
    |   EditSale                    of bool
    |   PauseSale                   of bool
    |   UnpauseSale                 of bool
    |   DistributeTokens            of bool
    |   Purchase                    of bool
    
type launchpadTogglePauseEntrypointType is [@layout:comb] record [
    targetEntrypoint  : launchpadPausableEntrypointType;
    empty             : unit
];


type createTokenSaleActionType is [@layout:comb] record [
    name                        : string;
    tokenIssuanceType           : string;       // mint / transfer
    tokenDistributionType       : string;       // auto / manual
    tokenContractAddress        : address;
    tokenId                     : nat;
    saleStart                   : timestamp;
    saleEnd                     : option(timestamp);
    saleOptions                 : map(string, tokenSaleOptionType); // default / whitelist / ABCDEF
    defaultWhitelistOptions     : map(string, nat);
]

type setSaleWhitelistSingleType is [@layout:comb] record [
    saleId                      : nat;
    whitelistUserAddress        : address;
    defaultWhitelistOption      : bool;     // if true, follow default whitelist options in token sale
    whitelistOptions            : option(map(string, nat));
]

type setSaleWhitelistActionType is list(setSaleWhitelistSingleType)


type purchaseActionType is [@layout:comb] record [
    saleId                      : nat;
    amount                      : nat;
    saleOption                  : string;  // default / whitelist / ABCDEF
]

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
    |   LambdaCreateTokenSale             of createTokenSaleActionType
    |   LambdaSetSaleWhitelist            of setSaleWhitelistActionType
    |   LambdaEditSale                    of (unit)
    |   LambdaStartSale                   of (nat)
    |   LambdaCloseSale                   of (nat)
    |   LambdaPauseSale                   of (nat)
    |   LambdaUnpauseSale                 of (nat)
    |   LambdaDistributeTokens            of (nat)

        // User Lambdas
    |   LambdaPurchase                    of purchaseActionType

// ------------------------------------------------------------------------------
// Storage
// ------------------------------------------------------------------------------


type launchpadStorageType is [@layout:comb] record [
    
    superAdmin                : address;
    newSuperAdmin             : option(address);
    admins                    : set(address);

    metadata                  : metadataType;
    config                    : launchpadConfigType;
    breakGlassConfig          : launchpadBreakGlassConfigType;

    whitelistContracts        : whitelistContractsType;    
    generalContracts          : generalContractsType;

    saleLedger                : saleLedgerType;
    saleWhitelistLedger       : saleWhitelistLedgerType;
    salePurchaseLedger        : salePurchaseLedgerType;
    lastSaleId                : nat;
    
    lambdaLedger              : lambdaLedgerType;
]

