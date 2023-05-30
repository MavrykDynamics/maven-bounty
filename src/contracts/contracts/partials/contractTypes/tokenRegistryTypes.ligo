// ------------------------------------------------------------------------------
// Storage Types
// ------------------------------------------------------------------------------

type tokenRegistryBreakGlassConfigType is [@layout:comb] record [
    setTokenIsPaused          : bool;
    removeTokenIsPaused       : bool;
]

// type tokenOverrideType is [@layout:comb] record [
//     beneficiaryOverride     : option(address);
//     feeOverride             : option(nat);
// ]
// type fa12TokenLedgerType is big_map(address, tokenOverrideType);        // token contract address
// type fa2TokenLedgerType is big_map((address * nat), tokenOverrideType); // token contract address * token id

// type tokenCustomType is 
//         Fa12        of address
//     |   Fa2         of set(nat)

type tokenRecordType is [@layout:comb] record [
    tokenType               : string;
    tokenIds                : set(nat);
    beneficiaryOverride     : option(address);
    feeOverride             : option(nat);
]
type tokenLedgerType is big_map(address, tokenRecordType);

// ------------------------------------------------------------------------------
// Action Types
// ------------------------------------------------------------------------------

type tokenRegistryPausableEntrypointType is
        SetToken              of bool
    |   RemoveToken           of bool
    
type tokenRegistryTogglePauseEntrypointType is [@layout:comb] record [
    targetEntrypoint  : tokenRegistryPausableEntrypointType;
    empty             : unit
];

// only FA12 or FA2, no Tez
type listTokenType is 
    |   Fa12   of fa12TokenType   // address
    |   Fa2    of fa2TokenType    // record [ tokenContractAddress : address; tokenId : nat; ]

type setTokenActionType is [@layout:comb] record [
    token           : listTokenType; 
    beneficiary     : option(address);
    fee             : option(nat);
];

type removeTokenActionType is listTokenType

// ------------------------------------------------------------------------------
// Lambda Action Types
// ------------------------------------------------------------------------------


type tokenRegistryLambdaActionType is 

        // Housekeeping Lambdas
        LambdaSetAdmin                    of address
    |   LambdaSetGovernance               of (address)
    |   LambdaUpdateMetadata              of updateMetadataType
    |   LambdaUpdateWhitelistContracts    of updateWhitelistContractsType
    |   LambdaUpdateGeneralContracts      of updateGeneralContractsType
    |   LambdaMistakenTransfer            of transferActionType

        // Pause / Break Glass Lambdas
    |   LambdaPauseAll                    of (unit)
    |   LambdaUnpauseAll                  of (unit)
    |   LambdaTogglePauseEntrypoint       of tokenRegistryTogglePauseEntrypointType

        // TokenRegistry Lambdas
    |   LambdaSetToken                    of setTokenActionType
    |   LambdaRemoveToken                 of removeTokenActionType

// ------------------------------------------------------------------------------
// Storage
// ------------------------------------------------------------------------------


type tokenRegistryStorageType is [@layout:comb] record [
    
    admin                     : address;
    metadata                  : metadataType;
    breakGlassConfig          : tokenRegistryBreakGlassConfigType;

    defaultFee                : nat;
    defaultBeneficiary        : address;

    tokenLedger               : tokenLedgerType;

    whitelistContracts        : whitelistContractsType;    
    generalContracts          : generalContractsType;
    
    lambdaLedger              : lambdaLedgerType;
]

