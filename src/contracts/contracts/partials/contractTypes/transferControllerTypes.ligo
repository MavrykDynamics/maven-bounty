// ------------------------------------------------------------------------------
// Storage Types
// ------------------------------------------------------------------------------

type validationTransferType is record [
    from_       : address;
    to_         : address;
    token_id    : nat;
    amount      : nat;
]

type userRecordType is [@layout:comb] record [
    nationality         : string;
    residentCountry     : string;

    accreditedInvestor  : bool;
    kycCompleted        : bool;

    // maxTransferAmount   : nat;
]
type userLedgerType is big_map(address, userRecordType)


type ruleRecordType is [@layout:comb] record [
    countriesAllowed     : set(string);
    countriesNotAllowed  : set(string);
]

type ruleLedgerType is big_map(string, ruleRecordType)

type freezeRuleEngineStorageType is record [
    admin               : address;
    
    config              : configType;

    ledger              : userLedgerType;
    ruleLedger          : ruleLedgerType;

]