// ------------------------------------------------------------------------------
// Storage Types
// ------------------------------------------------------------------------------

type launchpadBreakGlassConfigType is [@layout:comb] record [
    createTokenLaunchIsPaused         : bool;
    startLaunchIsPaused               : bool;
    closeLaunchIsPaused               : bool;
    setLaunchWhitelistIsPaused        : bool;
    editTokenLaunchIsPaused           : bool;
    pauseLaunchIsPaused               : bool;
    unpauseLaunchIsPaused             : bool;
    distributeTokensIsPaused          : bool;
    purchaseIsPaused                  : bool;
]

type launchpadConfigType is [@layout:comb] record [
    minOfferAmount   : nat;
    empty            : unit
];


type launchWhitelistRecordType is [@layout:comb] record [
    allowed         : map(string, nat);         // sale option name * allowed amount for sale option
]
type launchWhitelistLedgerType is big_map((nat * address), launchWhitelistRecordType)


type tokenSaleOptionType is [@layout:comb] record [    
    maxAmountCap                : nat;
    totalBought                 : nat;
    minPurchaseAmount           : nat;
    maxAmountPerWalletTotal     : option(nat);
    
    price                       : nat; 
    currency                    : tokenType;
    
    // todo: accept multi currency and price
    // currencyMap                 : map()
]
type launchRecordType is [@layout:comb] record [
    name                        : string;
    isPaused                    : bool;         // TRUE / FALSE
    status                      : string;       // ACTIVE / INACTIVE / PAUSED / CLOSED
    tokenIssuanceType           : string;       // mint / transfer
    tokenDistributionType       : string;       // auto / manual
    tokenContractAddress        : address;
    tokenId                     : nat;
    saleStart                   : timestamp;
    saleEnd                     : option(timestamp);
    whitelistSaleStart          : option(timestamp);
    whitelistSaleEnd            : option(timestamp);
    saleOptions                 : map(string, tokenSaleOptionType);
    defaultWhitelistOptions     : map(string, nat);
]
type launchLedgerType is big_map(nat, launchRecordType)


type purchaseRecordType is [@layout:comb] record [
    purchased           : map(string, nat);  // breakdown by sale options (if there's multiple)
    totalPurchased      : nat;               // total purchased (model only assumes one token)
    totalDistributed    : nat; 
]
type purchaseLedgerType is big_map((nat * address), purchaseRecordType)

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
        CreateTokenLaunch             of bool
    |   SetLaunchWhitelist            of bool
    |   EditTokenLaunch               of bool
    |   StartLaunch                   of bool
    |   CloseLaunch                   of bool
    |   PauseLaunch                   of bool
    |   UnpauseLaunch                 of bool
    |   DistributeTokens              of bool
    |   Purchase                      of bool
    
type launchpadTogglePauseEntrypointType is [@layout:comb] record [
    targetEntrypoint  : launchpadPausableEntrypointType;
    empty             : unit
];


type createTokenLaunchActionType is [@layout:comb] record [
    name                        : string;
    tokenIssuanceType           : string;       // mint / transfer
    tokenDistributionType       : string;       // auto / manual
    tokenContractAddress        : address;
    tokenId                     : nat;
    saleStart                   : timestamp;
    saleEnd                     : option(timestamp);
    whitelistSaleStart          : option(timestamp);
    whitelistSaleEnd            : option(timestamp);
    saleOptions                 : map(string, tokenSaleOptionType); // default / whitelist / ABCDEF
    defaultWhitelistOptions     : map(string, nat);
]

type editTokenLaunchActionType is [@layout:comb] record [
    launchId                    : nat;
    name                        : option(string);
    tokenIssuanceType           : option(string);       // mint / transfer
    tokenDistributionType       : option(string);       // auto / manual
    tokenContractAddress        : option(address);
    tokenId                     : option(nat);
    saleStart                   : option(timestamp);
    saleEnd                     : option(timestamp);
    whitelistSaleStart          : option(timestamp);
    whitelistSaleEnd            : option(timestamp);
    saleOptions                 : option(map(string, tokenSaleOptionType)); // default / whitelist / ABCDEF
    defaultWhitelistOptions     : option(map(string, nat));
]

type setLaunchWhitelistSingleType is [@layout:comb] record [
    launchId                    : nat;
    whitelistUserAddress        : address;
    defaultWhitelistOption      : bool;     // if true, follow default whitelist options in token sale
    whitelistOptions            : option(map(string, nat));
]

type setLaunchWhitelistActionType is list(setLaunchWhitelistSingleType)


type purchaseActionType is [@layout:comb] record [
    launchId                    : nat;
    amount                      : nat;
    saleOption                  : string;  // default / whitelist / ABCDEF
]

type distributeTokensSingleActionType is [@layout:comb] record [
    userAddress                 : address; 
    launchId                    : nat;
]
type distributeTokensActionType is list(distributeTokensSingleActionType)

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
    |   LambdaCreateTokenLaunch           of createTokenLaunchActionType
    |   LambdaSetLaunchWhitelist          of setLaunchWhitelistActionType
    |   LambdaEditTokenLaunch             of editTokenLaunchActionType
    |   LambdaStartLaunch                 of (nat)
    |   LambdaCloseLaunch                 of (nat)
    |   LambdaPauseLaunch                 of (nat)
    |   LambdaUnpauseLaunch               of (nat)
    |   LambdaDistributeTokens            of distributeTokensActionType

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

    launchLedger              : launchLedgerType;
    launchWhitelistLedger     : launchWhitelistLedgerType;
    purchaseLedger            : purchaseLedgerType;
    lastLaunchId              : nat;
    
    lambdaLedger              : lambdaLedgerType;
]

