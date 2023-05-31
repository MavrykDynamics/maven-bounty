// ------------------------------------------------------------------------------
// Storage Types
// ------------------------------------------------------------------------------

type tokenRegistryBreakGlassConfigType is [@layout:comb] record [
    setTokenIsPaused          : bool;
    removeTokenIsPaused       : bool;
]

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

        // Admin Lambdas
        LambdaSetSuperAdmin               of (address)
    |   LambdaClaimSuperAdmin             of (unit)
    |   LambdaSetAdmin                    of (address)
    |   LambdaRemoveAdmin                 of (address)

        // Housekeeping Lambdas
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
    
    superAdmin                : address;
    newSuperAdmin             : option(address);
    admins                    : set(address);

    metadata                  : metadataType;
    breakGlassConfig          : tokenRegistryBreakGlassConfigType;

    whitelistContracts        : whitelistContractsType;    
    generalContracts          : generalContractsType;

    defaultFee                : nat;
    defaultBeneficiary        : address;

    tokenLedger               : tokenLedgerType;

    lambdaLedger              : lambdaLedgerType;
]

