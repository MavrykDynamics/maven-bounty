// ------------------------------------------------------------------------------
// Storage Types
// ------------------------------------------------------------------------------


type marketplaceBreakGlassConfigType is [@layout:comb] record [
    listIsPaused             : bool;
    purchaseIsPaused         : bool;
    offerIsPaused            : bool;
    acceptOfferIsPaused      : bool;
]

type marketplaceConfigType is [@layout:comb] record [
    minOfferAmount   : nat;
    empty            : unit
];

// ------------------------------------------------------------------------------
// Action Types
// ------------------------------------------------------------------------------

type marketplaceUpdateConfigNewValueType is nat
type marketplaceUpdateConfigActionType is 
        ConfigMiOfferAmount          of unit
    |   Empty                       of unit

type marketplaceUpdateConfigParamsType is [@layout:comb] record [
    updateConfigNewValue    : marketplaceUpdateConfigNewValueType; 
    updateConfigAction      : marketplaceUpdateConfigActionType;
]


type marketplacePausableEntrypointType is
        List                         of bool
    |   Purchase                     of bool
    |   Offer                        of bool
    |   AcceptOffer                  of bool
    
type marketplaceTogglePauseEntrypointType is [@layout:comb] record [
    targetEntrypoint  : marketplacePausableEntrypointType;
    empty             : unit
];


// ------------------------------------------------------------------------------
// Lambda Action Types
// ------------------------------------------------------------------------------


type marketplaceLambdaActionType is 

        // Housekeeping Lambdas
        LambdaSetAdmin                    of address
    |   LambdaSetGovernance               of (address)
    |   LambdaUpdateMetadata              of updateMetadataType
    |   LambdaUpdateConfig                of marketplaceUpdateConfigParamsType
    |   LambdaUpdateWhitelistContracts    of updateWhitelistContractsType
    |   LambdaUpdateGeneralContracts      of updateGeneralContractsType
    |   LambdaMistakenTransfer            of transferActionType

        // Pause / Break Glass Lambdas
    |   LambdaPauseAll                    of (unit)
    |   LambdaUnpauseAll                  of (unit)
    |   LambdaTogglePauseEntrypoint       of marketplaceTogglePauseEntrypointType

        // Marketplace Lambdas
    |   LambdaList                        of (nat)
    |   LambdaDelist                      of (nat)
    |   LambdaPurchase                    of (nat)
    |   LambdaOffer                       of (unit)
    |   LambdaAcceptOffer                 of (address)
    |   LambdaRemoveOffer                 of (address)

// ------------------------------------------------------------------------------
// Storage
// ------------------------------------------------------------------------------


type marketplaceStorageType is [@layout:comb] record [
    
    admin                     : address;
    metadata                  : metadataType;
    config                    : marketplaceConfigType;

    mvkTokenAddress           : address;
    governanceAddress         : address;
    
    whitelistContracts        : whitelistContractsType;    
    generalContracts          : generalContractsType;
    
    breakGlassConfig          : marketplaceBreakGlassConfigType;
    
    lambdaLedger              : lambdaLedgerType;
]

