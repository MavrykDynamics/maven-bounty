// ------------------------------------------------------------------------------
// Storage Types
// ------------------------------------------------------------------------------

type validationTransferType is record [
    from_       : address;
    to_         : address;
    token_id    : nat;
    amount      : nat;
]

type freezeRuleEngineStorageType is record [
    administrator       : address;
    frozen_accounts     : big_map(address, unit);
]