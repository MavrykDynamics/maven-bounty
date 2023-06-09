// ------------------------------------------------------------------------------
// Storage Types
// ------------------------------------------------------------------------------

// only FA12 or FA2
type listTokenType is 
    |   Fa12Token   of fa12TokenType   // address
    |   Fa2Token    of fa2TokenType    // record [ tokenContractAddress : address; tokenId : nat; ]


type marketplaceBreakGlassConfigType is [@layout:comb] record [
    createListingIsPaused    : bool;
    removeListingIsPaused    : bool;
    purchaseIsPaused         : bool;
    offerIsPaused            : bool;
    acceptOfferIsPaused      : bool;
    removeOfferIsPaused      : bool;
    setCurrencyIsPaused      : bool;
]

type marketplaceConfigType is [@layout:comb] record [
    minOfferAmount   : nat;
    royalty          : nat;
];

type listingRecordType is [@layout:comb] record [
    initiator   : address;
    token       : listTokenType;
    price       : nat;
    amount      : nat; 
    currency    : tokenType;
    expiryTime  : option(timestamp);
]
type listingLedgerType is big_map(nat, listingRecordType)

type offerRecordType is [@layout:comb] record [
    initiator   : address;
    listingId   : nat;
    price       : nat;
    currency    : tokenType;
    expiryTime  : option(timestamp);
]
type offerLedgerType is big_map(nat, offerRecordType)

type currencyRecordType is [@layout:comb] record [
    tokenType   : string;
    tokenIds    : set(nat);
]
type currencyLedgerType is big_map(address, currencyRecordType)

// ------------------------------------------------------------------------------
// Action Types
// ------------------------------------------------------------------------------

type setCurrencyActionType is [@layout:comb] record [
    actionType  : string;           // update, remove
    token       : listTokenType;
]

type removeListingActionType is nat
type purchaseActionType is nat

type acceptOfferActionType is nat
type removeOfferActionType is nat

type createListingActionType is [@layout:comb] record [
    amount      : nat;
    price       : nat;
    expiryTime  : option(timestamp);
    token       : listTokenType;
    currency    : tokenType;
]

type offerActionType is [@layout:comb] record [
    listingId   : nat;
    price       : nat;
    expiryTime  : option(timestamp);
    currency    : tokenType;
]

type marketplaceUpdateConfigNewValueType is nat
type marketplaceUpdateConfigActionType is 
        ConfigMinOfferAmount          of unit
    |   ConfigRoyalty                 of unit

type marketplaceUpdateConfigParamsType is [@layout:comb] record [
    updateConfigNewValue    : marketplaceUpdateConfigNewValueType; 
    updateConfigAction      : marketplaceUpdateConfigActionType;
]

type marketplacePausableEntrypointType is
        CreateListing                of bool
    |   RemoveListing                of bool
    |   Purchase                     of bool
    |   Offer                        of bool
    |   AcceptOffer                  of bool
    |   RemoveOffer                  of bool
    |   SetCurrency                  of bool
    
type marketplaceTogglePauseEntrypointType is [@layout:comb] record [
    targetEntrypoint  : marketplacePausableEntrypointType;
    empty             : unit
];


// ------------------------------------------------------------------------------
// Lambda Action Types
// ------------------------------------------------------------------------------


type marketplaceLambdaActionType is 

        // Admin Lambdas
        LambdaSetSuperAdmin               of (address)
    |   LambdaClaimSuperAdmin             of (unit)
    |   LambdaSetAdmin                    of (address)
    |   LambdaRemoveAdmin                 of (address)

        // Housekeeping Lambdas
    |   LambdaUpdateMetadata              of updateMetadataType
    |   LambdaUpdateConfig                of marketplaceUpdateConfigParamsType
    |   LambdaUpdateWhitelistContracts    of updateWhitelistContractsType
    |   LambdaUpdateGeneralContracts      of updateGeneralContractsType
    |   LambdaMistakenTransfer            of transferActionType

        // Pause / Break Glass Lambdas
    |   LambdaPauseAll                    of (unit)
    |   LambdaUnpauseAll                  of (unit)
    |   LambdaTogglePauseEntrypoint       of marketplaceTogglePauseEntrypointType

        // Marketplace Admin Lambdas
    |   LambdaSetCurrency                 of setCurrencyActionType
        
        // Marketplace Lambdas
    |   LambdaCreateListing               of createListingActionType
    |   LambdaRemoveListing               of removeListingActionType
    |   LambdaPurchase                    of purchaseActionType
    |   LambdaOffer                       of offerActionType
    |   LambdaAcceptOffer                 of acceptOfferActionType
    |   LambdaRemoveOffer                 of removeOfferActionType

// ------------------------------------------------------------------------------
// Storage
// ------------------------------------------------------------------------------


type marketplaceStorageType is [@layout:comb] record [
    
    superAdmin                : address;
    newSuperAdmin             : option(address);
    admins                    : set(address);

    metadata                  : metadataType;
    config                    : marketplaceConfigType;
    breakGlassConfig          : marketplaceBreakGlassConfigType;

    whitelistContracts        : whitelistContractsType;    
    generalContracts          : generalContractsType;

    nextListingId             : nat;
    nextOfferId               : nat;

    listingLedger             : listingLedgerType;
    offerLedger               : offerLedgerType;
    currencyLedger            : currencyLedgerType;

    lambdaLedger              : lambdaLedgerType;
]

