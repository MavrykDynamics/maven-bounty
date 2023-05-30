// ------------------------------------------------------------------------------
// Storage Types
// ------------------------------------------------------------------------------

// only FA12 or FA2, no Tez
type listTokenType is 
    |   Fa12   of fa12TokenType   // address
    |   Fa2    of fa2TokenType    // record [ tokenContractAddress : address; tokenId : nat; ]


type marketplaceBreakGlassConfigType is [@layout:comb] record [
    listIsPaused             : bool;
    delistIsPaused           : bool;
    purchaseIsPaused         : bool;
    offerIsPaused            : bool;
    acceptOfferIsPaused      : bool;
    removeOfferIsPaused      : bool;
]

type marketplaceConfigType is [@layout:comb] record [
    minOfferAmount   : nat;
    royalty          : nat;
];

type listRecordType is [@layout:comb] record [
    token       : listTokenType;
    amount      : nat; 
    expiryTime  : option(timestamp);
    currency    : tokenType;
]
type listLedgerType is big_map(nat, listRecordType)

type offerRecordType is [@layout:comb] record [
    listId      : nat;
    token       : tokenType;
    amount      : nat;
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

type delistActionType is nat
type purchaseActionType is nat

type acceptOfferActionType is nat
type removeOfferActionType is nat

type listActionType is [@layout:comb] record [
    initiator   : address;
    token       : listTokenType;
    amount      : nat;
    expiryTime  : option(timestamp);
    currency    : tokenType;
]

type offerActionType is [@layout:comb] record [
    listId      : nat;
    amount      : nat;
    expiryTime  : option(timestamp);
    currency    : tokenType;
]

type setCurrencyActionType is tokenType
type removeCurrencyActionType is tokenType

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
    |   Delist                       of bool
    |   Purchase                     of bool
    |   Offer                        of bool
    |   AcceptOffer                  of bool
    |   RemoveOffer                  of bool
    
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

        // Marketplace Admin Lambdas
    |   LambdaSetCurrency                 of setCurrencyActionType
    |   LambdaRemoveCurrency              of removeCurrencyActionType
        
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

    nextListId                : nat;
    nextOfferId               : nat;

    listLedger                : listLedgerType;
    offerLedger               : offerLedgerType;
    currencyLedger            : currencyLedgerType;

    whitelistContracts        : whitelistContractsType;    
    generalContracts          : generalContractsType;
    
    lambdaLedger              : lambdaLedgerType;
]

