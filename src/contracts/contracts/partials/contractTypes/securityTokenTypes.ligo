// ------------------------------------------------------------------------------
// Storage Types
// ------------------------------------------------------------------------------

type tokenIdType            is nat 
type tokenBalanceType       is nat
type snapshotTimestampType  is timestamp
type operatorType           is address;
type ownerType              is address;

type tokenAmountType is [@layout:comb] record [
    token_id        : nat;
    amount          : nat;
    address         : address; 
]

(* Balance_of entrypoint inputs *)
type balanceOfRequestType is [@layout:comb] record[
    owner       : ownerType;
    token_id    : tokenIdType;
]
type balanceOfResponse is [@layout:comb] record[
    request     : balanceOfRequestType;
    balance     : tokenBalanceType;
]
type balanceOfType is [@layout:comb] record[
    requests    : list(balanceOfRequestType);
    callback    : contract(list(balanceOfResponse));
]

(* Update_operators entrypoint inputs *)
type operatorParameterType is [@layout:comb] record[
    owner       : ownerType;
    operator    : operatorType;
    token_id    : tokenIdType;
]
type updateOperatorVariantType is 
        Add_operator    of operatorParameterType
    |   Remove_operator of operatorParameterType
type updateOperatorsType is list(updateOperatorVariantType)


type operatorKeyType is [@layout:comb] record [
    token_id    : nat;
    owner       : address;
    operator    : address; 
]

type txType is [@layout:comb] record[
    to_       : address;
    token_id  : tokenIdType;
    amount    : tokenBalanceType;
]

type transferType is [@layout:comb] record[
    from_     : address;
    txs       : list(txType);
]

type fa2TransferType is list(transferType)


type ledgerKeyType is [@layout:comb] record [
    owner           : address;
    token_id        : nat;
]

type tokenMetadataType is [@layout:comb] record [
    token_id          : tokenIdType;
    token_info        : map(string, bytes);
]

type setAdminActionType is [@layout:comb] record [
    admin            : address;
    token_id         : nat;
]

type removeAdminActionType is [@layout:comb] record [
    admin            : address;
    token_id         : nat;
]


type ruleType is [@layout:comb] record [
    token_id        : nat;
    ruleContract    : address; 
]

type snapshotLookupKeyType is [@layout:comb] record [
    token_id            : nat;
    snapshotTimestamp   : timestamp;
]

type snapshotLedgerKeyType is [@layout:comb] record [
    token_id            : nat;
    owner               : address;
    snapshotTimestamp   : timestamp;
]


type tokenContextType is [@layout:comb] record [
    isPaused                           : bool;
    validateTransferRuleContract       : option(address);
    currentSnapshot                    : option(timestamp);
    nextSnapshot                       : option(timestamp);
]

type validationTransferType is [@layout:comb] record [
    from_       : address;
    to_         : address;
    token_id    : nat;
    amount      : nat;
]


// ------------------------------------------------------------------------------
// Ledger Types
// ------------------------------------------------------------------------------


type administratorsType is big_map(ledgerKeyType, nat)

type tokenMetadataLedgerType is big_map(tokenIdType, tokenMetadataType);

type totalSupplyType is big_map(nat, nat);

type snapshotLedgerType is big_map(snapshotLedgerKeyType, nat)

type snapshotLookupType is big_map(snapshotLookupKeyType, timestamp)

type snapshotTotalSupplyType is big_map(snapshotLookupKeyType, nat)

type tokenContextLedgerType is big_map(nat, tokenContextType)

type identityType is big_map(address, bytes)

type ledgerType is big_map(ledgerKeyType, nat);

type operatorsType is big_map((ownerType * operatorType * tokenIdType), unit)

// ------------------------------------------------------------------------------
// Storage
// ------------------------------------------------------------------------------


type securityTokenStorageType is [@layout:comb] record [
    
    superAdmin              : address;
    newSuperAdmin           : option(address);
    administrators          : administratorsType;

    whitelistContracts      : whitelistContractsType;    
    token_metadata          : tokenMetadataLedgerType;
    totalSupply             : totalSupplyType;

    snapshotLedger          : snapshotLedgerType;
    snapshotLookup          : snapshotLookupType;
    snapshotTotalSupply     : snapshotTotalSupplyType;
    tokenContext            : tokenContextLedgerType;
    identities              : identityType;

    ledger                  : ledgerType;
    operators               : operatorsType;
]
