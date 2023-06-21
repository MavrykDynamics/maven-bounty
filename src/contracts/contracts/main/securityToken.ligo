// ------------------------------------------------------------------------------
// Error Codes
// ------------------------------------------------------------------------------

// Error Codes
#include "../partials/errors.ligo"

// ------------------------------------------------------------------------------
// Shared Helpers and Types
// ------------------------------------------------------------------------------

// Shared Helpers
#include "../partials/shared/sharedHelpers.ligo"

// Transfer Helpers
#include "../partials/shared/transferHelpers.ligo"

// Constants
#include "../partials/shared/constants.ligo"

// ------------------------------------------------------------------------------
// Contract Types
// ------------------------------------------------------------------------------

// CMTA Token Types
#include "../partials/contractTypes/securityTokenTypes.ligo"

// ------------------------------------------------------------------------------

type action is

        // Admin Entrypoints
        SetSuperAdmin             of (address)
    |   ClaimSuperAdmin           of (unit)
    |   SetAdmin                  of setAdminActionType
    |   RemoveAdmin               of removeAdminActionType

        // Housekeeping Entrypoints
    |   SetTokenMetadata          of list(tokenMetadataType)
    |   UpdateWhitelistContracts  of updateWhitelistContractsType
    |   MistakenTransfer          of transferActionType
        
        // Owner Entrypoints
    |   InitialiseToken           of list(tokenIdType)
    |   Mint                      of list(tokenAmountType)
    |   Burn                      of list(tokenAmountType)
    |   Pause                     of list(tokenIdType)
    |   Unpause                   of list(tokenIdType)
    |   SetRuleEngines            of list(ruleType)
    |   ScheduleSnapshot          of (tokenIdType * snapshotTimestampType)
    |   UnscheduleSnapshot        of tokenIdType
    |   DeleteSnapshot            of snapshotLookupKeyType
    |   Kill                      of unit 
    
        // Open FA2 Entrypoints
    |   SetIdentity               of bytes
    |   Transfer                  of fa2TransferType

        // Base FA2 Entrypoints
    |   Balance_of                of balanceOfType
    |   Update_operators          of updateOperatorsType
    
    
type return is list (operation) * securityTokenStorageType
const noOperations : list (operation) = nil;


// ------------------------------------------------------------------------------
// Constants Begin
// ------------------------------------------------------------------------------

const is_admin : nat = 1n;
const is_proposed_admin : nat = 2n;

// ------------------------------------------------------------------------------
// Constants End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Admin Helper Functions Begin
// ------------------------------------------------------------------------------

function verifySenderIsAdmin(const ledgerKey : ledgerKeyType; const s : securityTokenStorageType) : unit is 
block {

    const administratorCheck : nat = case s.administrators[ledgerKey] of [
            Some (_v) -> _v
        |   None      -> failwith(error_ADMINISTRATOR_NOT_FOUND)
    ];

    if administratorCheck = is_admin then skip else failwith(error_NOT_ADMIN);

} with unit



function verifySenderIsProposedAdmin(const ledgerKey : ledgerKeyType; const s : securityTokenStorageType) : unit is 
block {

    const administratorCheck : nat = case s.administrators[ledgerKey] of [
            Some (_v) -> _v
        |   None      -> failwith(error_ADMINISTRATOR_NOT_FOUND)
    ];

    if administratorCheck = is_proposed_admin then skip else failwith(error_NOT_ADMIN);

} with unit



function verifyTokenDoesNotExist(const token_id : nat; const s : securityTokenStorageType) : unit is
block {

    case s.tokenContext[token_id] of [
            Some(_v) -> failwith(error_TOKEN_EXISTS)
        |   None     -> skip
    ];

} with unit



function verifyNoScheduledSnapshot(const tokenContext : tokenContextType) : unit is 
block {

    case tokenContext.nextSnapshot of [
            Some (_v) -> failwith(error_SNAPSHOT_ALREADY_SCHEDULED)
        |   None      -> skip
    ];

} with unit



function verifySnapshotInFuture(const snapshotTimestamp : timestamp) : unit is
block {

    if Tezos.get_now() < snapshotTimestamp then skip else failwith(error_SNAPSHOT_IN_PAST);

} with unit



function verifyTokenIsDefined(const token_id : nat; const s : securityTokenStorageType) : unit is
block {

    case s.token_metadata[token_id] of [
            Some (_v) -> skip
        |   None      -> failwith(error_TOKEN_UNDEFINED)
    ];

} with unit



function verifyTokenContextIsNotPaused(const tokenContext : tokenContextType) : unit is 
block {

    if tokenContext.isPaused = True then failwith(error_TOKEN_PAUSED) else skip;

} with unit



function verifySufficientBalance(const ledgerKey : ledgerKeyType; const amount : nat; const s : securityTokenStorageType) : unit is
block {

    const ledger_balance : nat = case s.ledger[ledgerKey] of [
            Some(_v) -> _v
        |   None     -> 0n
    ];

    if ledger_balance < amount then failwith(error_INSUFFICIENT_BALANCE) else skip;

} with unit

// ------------------------------------------------------------------------------
// Admin Helper Functions End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Private Lambdas Begin
// ------------------------------------------------------------------------------

function bootstrapSnapshot(const params : (tokenContextType * nat); var s : securityTokenStorageType) : (tokenContextType * securityTokenStorageType) is 
block {

    var tokenContext : tokenContextType := params.0;
    const token_id      : nat             = params.1;

    case tokenContext.nextSnapshot of [
            Some(nextSnapshotTimestamp) -> {

                if nextSnapshotTimestamp < Tezos.get_now() then block {

                    // check if there is a current snapshot set, if there is, set it to the next snapshot timestamp
                    case tokenContext.currentSnapshot of [
                            Some(currentSnapshotTimestamp) -> {

                                const snapshotLookupKey : snapshotLookupKeyType = record [
                                    token_id            = token_id;
                                    snapshotTimestamp  = currentSnapshotTimestamp;
                                ];

                                s.snapshotLookup[snapshotLookupKey] := nextSnapshotTimestamp;

                            }
                        |   None -> skip
                    ];

                    tokenContext.currentSnapshot  := Some(nextSnapshotTimestamp);
                    tokenContext.nextSnapshot     := (None : option(timestamp));

                    // update token context
                    s.tokenContext[token_id] := tokenContext;

                }    
            }
        |   None -> skip
    ];

} with (tokenContext, s)



function setSnapshotLedger(const params : (tokenContextType * nat * address); var s : securityTokenStorageType) : securityTokenStorageType is
block {

    const tokenContext  : tokenContextType = params.0;
    const token_id       : nat              = params.1;
    const ownerAddress   : address          = params.2;

    case tokenContext.currentSnapshot of [
            Some (currentSnapshotTimestamp) -> {

                const snapshotLedgerKey : snapshotLedgerKeyType = record [
                    token_id            = token_id;
                    owner               = ownerAddress;
                    snapshotTimestamp  = currentSnapshotTimestamp;
                ];

                case s.snapshotLedger[snapshotLedgerKey] of [
                        Some (_v) -> {
                            
                            const ledgerKey : ledgerKeyType = record [
                                owner       = ownerAddress;
                                token_id    = token_id;
                            ];

                            const ledger_value : nat = case s.ledger[ledgerKey] of [
                                    Some (_v) -> _v
                                |   None      -> 0n
                            ];

                            // set snapshot ledger value
                            s.snapshotLedger[snapshotLedgerKey] := ledger_value;

                        }
                    |   None -> skip
                ];

            }
        |   None -> skip
    ];

} with s



function setSnapshotTotalSupply(const params : (tokenContextType * nat); var s : securityTokenStorageType) : securityTokenStorageType is
block {

    const tokenContext : tokenContextType = params.0;
    const token_id      : nat              = params.1;

    case tokenContext.currentSnapshot of [
            Some (currentSnapshotTimestamp) -> {

                const snapshotLookupKey : snapshotLookupKeyType = record [
                    token_id            = token_id;
                    snapshotTimestamp  = currentSnapshotTimestamp;
                ];

                const totalSupply : nat = case s.totalSupply[token_id] of [
                        Some (_v) -> _v
                    |   None      -> 0n
                ];

                // set snapshot total supply
                s.snapshotTotalSupply[snapshotLookupKey] := totalSupply;

            }   
        |   None -> skip
    ];

} with s

// ------------------------------------------------------------------------------
// Private Lambdas End
// ------------------------------------------------------------------------------




// ------------------------------------------------------------------------------
// FA2 Helper Functions Begin
// ------------------------------------------------------------------------------

function verifyIsOwner(const owner : ownerType) : unit is
    if Tezos.get_sender() =/= owner then failwith("FA2_NOT_OWNER")
    else unit



function verifySenderIsOwnerOrOperator(const owner : ownerType; const token_id : tokenIdType; const operators : operatorsType) : unit is
    if owner = Tezos.get_sender() or Big_map.mem((owner, Tezos.get_sender(), token_id), operators) then unit
    else failwith ("FA2_NOT_OPERATOR")



// mergeOperations helper function - used in transfer entrypoint
function mergeOperations(const first : list (operation); const second : list (operation)) : list (operation) is 
List.fold( 
    function(const operations : list(operation); const operation : operation) : list(operation) is operation # operations,
    first,
    second
)



// addOperator helper function - used in update_operators entrypoint
function addOperator(const operatorParameter : operatorParameterType; const operators : operatorsType; const s : securityTokenStorageType) : operatorsType is
block{

    const owner     : ownerType     = operatorParameter.owner;
    const operator  : operatorType  = operatorParameter.operator;
    const token_id  : tokenIdType   = operatorParameter.token_id;

    verifyTokenIsDefined(token_id, s);

    verifyIsOwner(owner);

    const operatorKey : (ownerType * operatorType * tokenIdType) = (owner, operator, token_id)

} with(Big_map.update(operatorKey, Some (unit), operators))



// removeOperator helper function - used in update_operators entrypoint
function removeOperator(const operatorParameter : operatorParameterType; const operators : operatorsType; const s : securityTokenStorageType) : operatorsType is
block{

    const owner     : ownerType     = operatorParameter.owner;
    const operator  : operatorType  = operatorParameter.operator;
    const token_id  : tokenIdType   = operatorParameter.token_id;

    verifyTokenIsDefined(token_id, s);
    
    verifyIsOwner(owner);

    const operatorKey : (ownerType * operatorType * tokenIdType) = (owner, operator, token_id)

} with(Big_map.remove(operatorKey, operators))

// ------------------------------------------------------------------------------
// FA2 Helper Functions End
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
//
// Helper Functions End
//
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
//
// Views Begin
//
// ------------------------------------------------------------------------------

(* view_totalSupply
    - Given a token id allows the consumer to view the current total supply.
*)
[@view] function view_totalSupply(const token_id : nat; var s : securityTokenStorageType) : nat is
    case Big_map.find_opt(token_id, s.totalSupply) of [
            Some (_v) -> _v
        |   None      -> 0n
    ]



(* view_balance_of
    - Given a ledger key (consisting of token_id = sp.TNat, owner = sp.TAddress) allows the 
      consumer to view the current balance.
*)
[@view] function view_balance_of(const ledgerKey : ledgerKeyType; var s : securityTokenStorageType) : nat is
    case Big_map.find_opt(ledgerKey, s.ledger) of [
            Some (_v) -> _v
        |   None      -> 0n
    ]



(* view_currentSnapshot
    - Given a token id allows the consumer to view the current snapshot timestamp. Can be null.
*)
[@view] function view_currentSnapshot(const token_id : nat; var s : securityTokenStorageType) : option(timestamp) is
    case Big_map.find_opt(token_id, s.tokenContext) of [
            Some (_v) -> _v.currentSnapshot
        |   None      -> (None : option(timestamp))
    ]



(* view_nextSnapshot
    - Given a token id allows the consumer to view the next snapshot timestamp. Can be null.
*)
[@view] function view_nextSnapshot(const token_id : nat; var s : securityTokenStorageType) : option(timestamp) is
    case Big_map.find_opt(token_id, s.tokenContext) of [
            Some (_v) -> _v.nextSnapshot
        |   None      -> (None : option(timestamp))
    ]



(* view_snapshot_totalSupply
    - Given the snapshot lookup key (consisting of token_id = sp.TNat, snapshotTimestamp = sp.TTimestamp) allows 
      the consumer to retrieve the total supply in nat of a given snapshot.
*)
[@view] function view_snapshot_totalSupply(const snapshotLookupKey : snapshotLookupKeyType; var s : securityTokenStorageType) : nat is
block {

    var snapshot_totalSupply : nat := 0n;
    case s.snapshotTotalSupply[snapshotLookupKey] of [
            Some (_totalSupply) -> snapshot_totalSupply := _totalSupply
        |   None -> block {

                var keep_loop : bool := True;
                var currentSnapshotLookupKey : snapshotLookupKeyType := snapshotLookupKey;

                while keep_loop = True block {
                    case s.snapshotLookup[currentSnapshotLookupKey] of [
                            Some (_timestamp) -> {

                                currentSnapshotLookupKey := record [
                                    token_id            = currentSnapshotLookupKey.token_id;
                                    snapshotTimestamp  = _timestamp
                                ];

                                case s.snapshotTotalSupply[currentSnapshotLookupKey] of [
                                        Some (_v) -> keep_loop := False
                                    |   None      -> skip
                                ];

                            }
                        |   None -> keep_loop := False
                    ]
                };

                case s.snapshotTotalSupply[currentSnapshotLookupKey] of [
                        Some (_v) -> snapshot_totalSupply := _v
                    |   None      -> skip
                ];

            }
    ];

} with snapshot_totalSupply



(* view_snapshot_balance_of
    - Given the snapshot ledger key (consisting of token_id = sp.TNat, owner = sp.TAddress, snapshotTimestamp = sp.TTimestamp) allows 
      the consumer to retrieve the balance in nat of a given snapshot.
*)
[@view] function view_snapshot_balance_of(const snapshot_ledgerKey : snapshotLedgerKeyType; var s : securityTokenStorageType) : nat is
block {

    var snapshot_balance_of : nat := 0n;
    case s.snapshotLedger[snapshot_ledgerKey] of [
            Some (_balance) -> snapshot_balance_of := _balance
        |   None -> block {

                var keep_loop : bool := True;
                var currentSnapshotLookupKey : snapshotLookupKeyType := record [
                    token_id            = snapshot_ledgerKey.token_id;
                    snapshotTimestamp  = snapshot_ledgerKey.snapshotTimestamp;
                ];
                var currentSnapshot_ledgerKey : snapshotLedgerKeyType := record [
                    token_id            = snapshot_ledgerKey.token_id;
                    owner               = snapshot_ledgerKey.owner;
                    snapshotTimestamp  = currentSnapshotLookupKey.snapshotTimestamp;
                ];

                while keep_loop = True block {
                    case s.snapshotLookup[currentSnapshotLookupKey] of [
                            Some (_timestamp) -> {

                                currentSnapshotLookupKey := record [
                                    token_id            = snapshot_ledgerKey.token_id;
                                    snapshotTimestamp  = _timestamp
                                ];

                                currentSnapshot_ledgerKey := record [
                                    token_id            = snapshot_ledgerKey.token_id;
                                    owner               = snapshot_ledgerKey.owner;
                                    snapshotTimestamp  = currentSnapshotLookupKey.snapshotTimestamp;
                                ];

                                case s.snapshotLedger[currentSnapshot_ledgerKey] of [
                                        Some (_v) -> keep_loop := False
                                    |   None      -> skip
                                ];

                            }
                        |   None -> keep_loop := False
                    ]
                };

                case s.snapshotLedger[currentSnapshot_ledgerKey] of [
                        Some (_v) -> snapshot_balance_of := _v
                    |   None      -> skip
                ];

            }
    ];

} with snapshot_balance_of



(* get: operator *)
[@view] function getOperatorOpt(const operator : (ownerType * operatorType * nat); const s : securityTokenStorageType) : option(unit) is
    Big_map.find_opt(operator, s.operators)



// (* check if operator *)
[@view] function is_operator(const operator : (ownerType * operatorType * nat); const s : securityTokenStorageType) : bool is
    Big_map.mem(operator, s.operators)



(* get: metadata *)
[@view] function token_metadata(const tokenId : nat; const s : securityTokenStorageType) : option(tokenMetadataType) is
    case Big_map.find_opt(tokenId, s.token_metadata) of [
            Some (_metadata)  -> Some(_metadata)
        |   None              -> (None : option(tokenMetadataType))
    ]

// ------------------------------------------------------------------------------
//
// Views End
//
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
//
// Entrypoints Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Admin Entrypoints Begin
// ------------------------------------------------------------------------------

(*  setSuperAdmin entrypoint *)
function setSuperAdmin(const newAdminAddress : address; var s : securityTokenStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 
    s.newSuperAdmin := Some(newAdminAddress);
    
} with (noOperations, s)



(*  claimSuperAdmin entrypoint *)
function claimSuperAdmin(var s : securityTokenStorageType) : return is
block {

    // get sender and new super admin address 
    const sender : address = Tezos.get_sender();
    const newSuperAdmin : address = case s.newSuperAdmin of [
            Some(_address) -> _address
        |   None           -> failwith(error_NO_NEW_SUPER_ADMIN_FOUND)
    ];

    // check if sender is not new super admin 
    if sender =/= newSuperAdmin then failwith(error_SENDER_IS_NOT_NEW_SUPER_ADMIN) else skip;
    s.superAdmin := newSuperAdmin;
    
} with (noOperations, s)



(*  setAdmin entrypoint *)
function setAdmin(const setAdminParams : setAdminActionType; var s : securityTokenStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 

    const administratorLedgerKey : ledgerKeyType = record [
        owner       = setAdminParams.admin;
        token_id    = setAdminParams.token_id;
    ];    

    s.administrators[administratorLedgerKey] := is_admin;
    
} with (noOperations, s)



(*  removeAdmin entrypoint *)
function removeAdmin(const removeAdminParams : removeAdminActionType; var s : securityTokenStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 
    
    const administrator_to_remove_ledgerKey : ledgerKeyType = record [
        owner       = removeAdminParams.admin;
        token_id    = removeAdminParams.token_id;
    ];    

    remove administrator_to_remove_ledgerKey from map s.administrators;
    
} with (noOperations, s)

// ------------------------------------------------------------------------------
// Admin Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Housekeeping Entrypoints Begin
// ------------------------------------------------------------------------------

(*  setTokenMetadata entrypoint 
    - The definition of a new token requires its metadata to be set. Only the administrators of a certain token 
      can edit existing. 
    - If no token metadata is set for a given ID the sender will become admin of that token automatically if that sender 
      was super administrator (token 0 admin)
*)
function setTokenMetadata(const tokenMetadataList : list(tokenMetadataType); var s : securityTokenStorageType) : return is
block {

    for token_metadata in list tokenMetadataList block {

        const administratorLedgerKey : ledgerKeyType = record [
            owner       = Tezos.get_sender();
            token_id    = token_metadata.token_id;
        ];

        case s.token_metadata[token_metadata.token_id] of [
                Some(_v) -> {
                    // verify sender is admin
                    verifySenderIsAdmin(administratorLedgerKey, s);
                }
            |   None -> {

                    const super_administratorLedgerKey : ledgerKeyType = record [
                        owner       = Tezos.get_sender();
                        token_id    = 0n;
                    ];

                    // verify sender is admin
                    verifySenderIsAdmin(super_administratorLedgerKey, s);

                    s.administrators[administratorLedgerKey] := is_admin;
                }
        ];

        s.token_metadata[token_metadata.token_id] := token_metadata;

    }

} with (noOperations, s)



(*  updateWhitelistContracts entrypoint *)
function updateWhitelistContracts(const updateWhitelistContractsParams : updateWhitelistContractsType; var s : securityTokenStorageType) : return is
block {

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 
    s.whitelistContracts := updateWhitelistContractsMap(updateWhitelistContractsParams, s.whitelistContracts);
  
} with (noOperations, s)



(*  mistakenTransfer entrypoint *)
function mistakenTransfer(const destinationParams : transferActionType; var s : securityTokenStorageType) : return is
block {

    // Steps Overview:    
    // 1. Check that sender is admin 
    // 2. Create and execute transfer operations based on the params sent

    verifySenderIsSuperAdmin(s.superAdmin); // check that sender is super admin 

    // Operations list
    var operations : list(operation) := nil;

    // Create transfer operations (transferOperationFold in transferHelpers)
    operations := List.fold_right(transferOperationFold, destinationParams, operations)

} with (operations, s)

// ------------------------------------------------------------------------------
// Housekeeping Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Owner Entrypoints Begin
// ------------------------------------------------------------------------------

(* initialiseToken entrypoint
    - Initialise the token with the required additional token context, can only be called once per token and 
      only one of its admin can call this
 *)
function initialiseToken(const initialiseTokenParams : list(tokenIdType); var s : securityTokenStorageType) : return is
block{

    for token_id in list initialiseTokenParams block {

        verifyTokenDoesNotExist(token_id, s);

        const administratorLedgerKey : ledgerKeyType = record [
            owner       = Tezos.get_sender();
            token_id    = token_id;
        ];

        // verify sender is admin
        verifySenderIsAdmin(administratorLedgerKey, s);

        // add new token context
        const newTokenContext : tokenContextType = record [
            isPaused                       = False;
            validateTransferRuleContract   = (None : option(address));
            currentSnapshot                = (None : option(timestamp));
            nextSnapshot                   = (None : option(timestamp));
        ];

        s.tokenContext[token_id] := newTokenContext;
    }

} with (noOperations, s)



(* mint entrypoint 
   - Allows to mint new tokens to the defined recipient address, only a token administrator can do this
*)
function mint(const tokenAmounts : list(tokenAmountType); var s : securityTokenStorageType) : return is
block {

    for tokenAmount in list tokenAmounts block {

        const administratorLedgerKey : ledgerKeyType = record [
            owner       = Tezos.get_sender();
            token_id    = tokenAmount.token_id;
        ];

        const recipientLedgerKey : ledgerKeyType = record [
            owner       = tokenAmount.address;
            token_id    = tokenAmount.token_id;
        ];

        verifySenderIsAdmin(administratorLedgerKey, s);

        verifyTokenIsDefined(tokenAmount.token_id, s);

        var tokenContext : tokenContextType := case s.tokenContext[tokenAmount.token_id] of [
                Some (_v) -> _v
            |   None      -> failwith(error_TOKEN_CONTEXT_NOT_FOUND)
        ];

        const bootstrapSnapshot : (tokenContextType * securityTokenStorageType) = bootstrapSnapshot((tokenContext, tokenAmount.token_id), s);
        tokenContext  := bootstrapSnapshot.0;
        s             := bootstrapSnapshot.1;

        s := setSnapshotTotalSupply((tokenContext, tokenAmount.token_id), s);
        s := setSnapshotLedger((tokenContext, tokenAmount.token_id, tokenAmount.address), s);

        s.ledger[recipientLedgerKey] := case s.ledger[recipientLedgerKey] of [
                Some(_v) -> _v + tokenAmount.amount
            |   None     -> tokenAmount.amount
        ];

        s.totalSupply[tokenAmount.token_id] := case s.totalSupply[tokenAmount.token_id] of [
                Some (_v) -> _v + tokenAmount.amount
            |   None      -> tokenAmount.amount
        ];

    }

} with (noOperations, s)



(* burn entrypoint 
    - Allows to burn tokens on the defined recipient address, only a token administrator can do this
*)
function burn(const tokenAmounts : list(tokenAmountType); var s : securityTokenStorageType) : return is
block {


    for tokenAmount in list tokenAmounts block {

        const administratorLedgerKey : ledgerKeyType = record [
            owner       = Tezos.get_sender();
            token_id    = tokenAmount.token_id;
        ];

        const recipientLedgerKey : ledgerKeyType = record [
            owner       = tokenAmount.address;
            token_id    = tokenAmount.token_id;
        ];

        verifySenderIsAdmin(administratorLedgerKey, s);

        verifySufficientBalance(recipientLedgerKey, tokenAmount.amount, s);

        var tokenContext : tokenContextType := case s.tokenContext[tokenAmount.token_id] of [
                Some (_v) -> _v
            |   None      -> failwith(error_TOKEN_CONTEXT_NOT_FOUND)
        ];

        const bootstrapSnapshot : (tokenContextType * securityTokenStorageType) = bootstrapSnapshot((tokenContext, tokenAmount.token_id), s);
        tokenContext  := bootstrapSnapshot.0;
        s              := bootstrapSnapshot.1;

        s := setSnapshotTotalSupply((tokenContext, tokenAmount.token_id), s);
        s := setSnapshotLedger((tokenContext, tokenAmount.token_id, tokenAmount.address), s);

        s.ledger[recipientLedgerKey] := case s.ledger[recipientLedgerKey] of [
                Some(_v) -> if _v > tokenAmount.amount then abs(_v - tokenAmount.amount) else 0n
            |   None     -> 0n
        ];

        s.totalSupply[tokenAmount.token_id] := case s.totalSupply[tokenAmount.token_id] of [
                Some (_v) -> if _v > tokenAmount.amount then abs(_v - tokenAmount.amount) else 0n
            |   None      -> 0n
        ];

        const recipient_balance : nat = case s.ledger[recipientLedgerKey] of [
                Some(_v) -> _v
            |   None     -> 0n
        ];

        if recipient_balance = 0n then remove recipientLedgerKey from map s.ledger else skip;

    }

} with (noOperations, s)



(* pause entrypoint 
    - Allows to pause tokens, only a token administrator can do this
*)
function pause(const pauseParams : list(tokenIdType); var s : securityTokenStorageType) : return is
block{

    for token_id in list pauseParams block {

        const administratorLedgerKey : ledgerKeyType = record [
            owner       = Tezos.get_sender();
            token_id    = token_id;
        ];

        // verify sender is admin
        verifySenderIsAdmin(administratorLedgerKey, s);

        var tokenContext : tokenContextType := case s.tokenContext[token_id] of [
                Some (_context) -> _context
            |   None            -> failwith(error_TOKEN_CONTEXT_NOT_FOUND)
        ];

        tokenContext.isPaused := True;

        s.tokenContext[token_id] := tokenContext;
    }

} with (noOperations, s)



(* unpause entrypoint 
    - Allows to unpause tokens, only a token administrator can do this
*)
function unpause(const unpauseParams : list(tokenIdType); var s : securityTokenStorageType) : return is
block{

    for token_id in list unpauseParams block {

        const administratorLedgerKey : ledgerKeyType = record [
            owner       = Tezos.get_sender();
            token_id    = token_id;
        ];

        // verify sender is admin
        verifySenderIsAdmin(administratorLedgerKey, s);

        var tokenContext : tokenContextType := case s.tokenContext[token_id] of [
                Some (_context) -> _context
            |   None            -> failwith(error_TOKEN_CONTEXT_NOT_FOUND)
        ];

        tokenContext.isPaused := False;

        s.tokenContext[token_id] := tokenContext;
    }

} with (noOperations, s)



(* setRuleEngines entrypoint 
    - Allows to specify the rules contract for a specific token, only a token administrator can do this
*)
function setRuleEngines(const setRuleEnginesParams : list(ruleType); var s : securityTokenStorageType) : return is
block{

    for rule in list setRuleEnginesParams block {

        const ruleTokenId : nat = rule.token_id;

        const administratorLedgerKey : ledgerKeyType = record [
            owner       = Tezos.get_sender();
            token_id    = ruleTokenId;
        ];

        // verify sender is admin
        verifySenderIsAdmin(administratorLedgerKey, s);

        // get and update token context
        var tokenContext : tokenContextType := case s.tokenContext[ruleTokenId] of [
                Some (_context) -> _context
            |   None            -> failwith(error_TOKEN_CONTEXT_NOT_FOUND)
        ];

        tokenContext.validateTransferRuleContract := Some(rule.ruleContract);

        s.tokenContext[ruleTokenId] := tokenContext;
        
    };

} with (noOperations, s)



(* scheduleSnapshot entrypoint 
    - Schedules a snapshot for the future for a specific token. Only one snapshot can be scheduled, repeated call will fail, to re-schedule you need to unschedule using the `unschedule_snapshot` entry point first. Only token administrator can do this.
*)
function scheduleSnapshot(const token_id : nat; const snapshotTimestamp : timestamp; var s : securityTokenStorageType) : return is
block{

    const administratorLedgerKey : ledgerKeyType = record [
        owner       = Tezos.get_sender();
        token_id    = token_id;
    ];

    // verify sender is admin
    verifySenderIsAdmin(administratorLedgerKey, s);

    // get token context
    var tokenContext : tokenContextType := case s.tokenContext[token_id] of [
            Some (_context) -> _context
        |   None            -> failwith(error_TOKEN_CONTEXT_NOT_FOUND)
    ];

    verifyNoScheduledSnapshot(tokenContext);

    verifySnapshotInFuture(snapshotTimestamp);

    tokenContext.nextSnapshot := Some(snapshotTimestamp);

    s.tokenContext[token_id] := tokenContext;

} with (noOperations, s)



(* unscheduleSnapshot entrypoint 
    - Unschedules the scheduled snapshot for the given token_id. Only token administrator can do this.
*)
function unscheduleSnapshot(const token_id : nat; var s : securityTokenStorageType) : return is
block{

    const administratorLedgerKey : ledgerKeyType = record [
        owner       = Tezos.get_sender();
        token_id    = token_id;
    ];

    // verify is admin
    verifySenderIsAdmin(administratorLedgerKey, s);

    // get token context
    var tokenContext : tokenContextType := case s.tokenContext[token_id] of [
            Some (_context) -> _context
        |   None            -> failwith(error_TOKEN_CONTEXT_NOT_FOUND)
    ];

    tokenContext.nextSnapshot := (None : option(timestamp));

    s.tokenContext[token_id] := tokenContext;

} with (noOperations, s)



(* deleteSnapshot entrypoint 
    - Deletes a snapshot for the given snapshot lookup key (consisting of token_id = sp.TNat, snapshotTimestamp = sp.TTimestamp). Only token administrator can do this.
*)
function deleteSnapshot(const snapshotLookupKey : snapshotLookupKeyType; var s : securityTokenStorageType) : return is
block{

    const administratorLedgerKey : ledgerKeyType = record [
        owner       = Tezos.get_sender();
        token_id    = snapshotLookupKey.token_id;
    ];

    // verify is admin
    verifySenderIsAdmin(administratorLedgerKey, s);

    remove snapshotLookupKey from map s.snapshotLookup

} with (noOperations, s)



(* kill entrypoint 
    - Wipes irreversibly the storage and ultimately kills the contract such that it can no longer be used. All tokens on it will be affected. Only special admin of token id 0 can do this.
*)
function kill(var s : securityTokenStorageType) : return is
block{

    const administratorLedgerKey : ledgerKeyType = record [
        owner       = Tezos.get_sender();
        token_id    = 0n;
    ];

    // verify is admin
    verifySenderIsAdmin(administratorLedgerKey, s);

    s.ledger            := (big_map[] : ledgerType);
    s.administrators    := (big_map[] : administratorsType);
    s.token_metadata    := (big_map[] : tokenMetadataLedgerType);
    s.totalSupply       := (big_map[] : totalSupplyType);
    s.operators         := (big_map[] : operatorsType);
    s.tokenContext      := (big_map[] : tokenContextLedgerType);
    s.identities        := (big_map[] : identityType);

} with (noOperations, s)

// ------------------------------------------------------------------------------
// Owner Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Open Entrypoints Begin
// ------------------------------------------------------------------------------

(* setIdentity entrypoint 
    - Allows a user to set the own identity
*)
function setIdentity(const identity : bytes; var s : securityTokenStorageType) : return is
block{

    s.identities[Tezos.get_sender()] := identity;

} with (noOperations, s)



(* transfer entrypoint *)
function transfer(const transfers : fa2TransferType; var s : securityTokenStorageType) : return is
block{

    function makeTransfer(const account : return; const transfer : transferType) : return is
        block {

            const owner : ownerType  = transfer.from_;
            const txs : list(txType) = transfer.txs;
            
            function transferTokens(var accumulator : securityTokenStorageType; const tx : txType) : securityTokenStorageType is
            block {

                const token_id      : tokenIdType       = tx.token_id;
                const tokenAmount  : tokenBalanceType   = tx.amount;
                const receiver      : ownerType         = tx.to_;

                const from_user : ledgerKeyType = record [
                    owner       = owner;
                    token_id    = token_id;
                ];

                const to_user : ledgerKeyType = record [
                    owner       = receiver;
                    token_id    = token_id;
                ];

                var tokenContext : tokenContextType := case accumulator.tokenContext[token_id] of [
                        Some(_v) -> _v
                    |   None     -> failwith(error_TOKEN_CONTEXT_NOT_FOUND)
                ];

                // verify if transfer is valid based on rule contract
                case tokenContext.validateTransferRuleContract of [
                        Some(_ruleContract) -> {
                            
                            const validationTransfer : validationTransferType = record [
                                from_       = owner;
                                to_         = receiver;
                                token_id    = token_id;
                                amount      = tokenAmount;
                            ];

                            const is_transfer_valid_view : option (option (bool)) = Tezos.call_view("view_is_transfer_valid", validationTransfer, _ruleContract);
                            const _is_transfer_valid : bool = case is_transfer_valid_view of [
                                    Some (_view) -> case _view of [
                                            Some(_bool) -> if _bool = False then failwith("error_CANNOT_TRANSFER") else True
                                        |   None        -> failwith("error_VIEW_IS_TRANSFER_VALID_BOOLEAN_NOT_FOUND")
                                    ]
                                |   None         -> failwith("error_VIEW_IS_TRANSFER_VALID_NOT_FOUND")
                            ];
                            
                        }
                    |   None     -> skip
                ];

                verifySenderIsOwnerOrOperator(owner, token_id, account.1.operators);

                verifyTokenIsDefined(token_id, accumulator);

                verifyTokenContextIsNotPaused(tokenContext);

                if tokenAmount > 0n then block {
                    
                    verifySufficientBalance(from_user, tokenAmount, accumulator);

                    const bootstrapSnapshot : (tokenContextType * securityTokenStorageType) = bootstrapSnapshot((tokenContext, token_id), accumulator);
                    tokenContext  := bootstrapSnapshot.0;
                    accumulator    := bootstrapSnapshot.1;

                    accumulator    := setSnapshotLedger((tokenContext, token_id, receiver), accumulator);
                    accumulator    := setSnapshotLedger((tokenContext, token_id, owner), accumulator);

                    if tokenAmount >= 0n then block {
                        
                        accumulator.ledger[from_user] := case accumulator.ledger[from_user] of [
                                Some (_balance) -> abs(_balance - tx.amount)
                            |   None            -> failwith(error_USER_NOT_FOUND)
                        ]; 

                        accumulator.ledger[to_user] := case accumulator.ledger[to_user] of [
                                Some (_balance) -> _balance + tx.amount
                            |   None            -> tx.amount
                        ]; 
                    };

                    const fromUserBalance : nat = case accumulator.ledger[from_user] of [
                            Some (_balance) -> _balance
                        |   None            -> 0n
                    ]; 

                    if fromUserBalance = 0n then remove from_user from map accumulator.ledger else skip;

                } else skip;

            } with accumulator with record[ledger = accumulator.ledger];

            const updatedOperations : list(operation) = (nil: list(operation));
            const updatedStorage : securityTokenStorageType = List.fold(transferTokens, txs, account.1);

        } with (mergeOperations(updatedOperations,account.0), updatedStorage)

} with List.fold(makeTransfer, transfers, ((nil: list(operation)), s))

// ------------------------------------------------------------------------------
// Open Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// FA2 Entrypoints Begin
// ------------------------------------------------------------------------------

(* balance_of entrypoint *)
function balance_of(const balance_of_requests : balanceOfType; const s : securityTokenStorageType) : return is
block{

    function retrieveBalance(const request : balanceOfRequestType) : balanceOfResponse is
        block{

            const ledgerKey : ledgerKeyType = record [
                token_id    = request.token_id;
                owner       = request.owner;
            ];

            verifyTokenIsDefined(request.token_id, s);

            const tokenBalance : tokenBalanceType = case Big_map.find_opt(ledgerKey, s.ledger) of [
                    Some (b) -> b
                |   None     -> 0n
            ];

            const response : balanceOfResponse = record[
                request = request;
                balance = tokenBalance
            ];

        } with (response);

      const requests   : list(balanceOfRequestType) = balance_of_requests.requests;
      const callback   : contract(list(balanceOfResponse)) = balance_of_requests.callback;
      const responses  : list(balanceOfResponse) = List.map(retrieveBalance, requests);
      const operation  : operation = Tezos.transaction(responses, 0tez, callback);

} with (list[operation],s)



(* update_operators entrypoint
    - As per FA2 standard, allows a token owner to set an operator who will be allowed to perform transfers on her/his behalf
 *)
function update_operators(const updateOperatorsParams : updateOperatorsType; const s : securityTokenStorageType) : return is
block{

    var updatedOperators : operatorsType := List.fold(
        function(const operators : operatorsType; const updateOperator : updateOperatorVariantType) : operatorsType is
            case updateOperator of [
                    Add_operator (param)    -> addOperator(param, operators, s)
                |   Remove_operator (param) -> removeOperator(param, operators, s)
            ]
        ,
        updateOperatorsParams,
        s.operators
    )

} with (noOperations, s with record[operators = updatedOperators])

// ------------------------------------------------------------------------------
// FA2 Entrypoints End
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
//
// Entrypoints End
//
// ------------------------------------------------------------------------------

(* main entrypoint *)
function main (const action : action; const s : securityTokenStorageType) : return is

    case action of [

            // Admin Entrypoints
            SetSuperAdmin(parameters)           -> setSuperAdmin(parameters, s)
        |   ClaimSuperAdmin(_parameters)        -> claimSuperAdmin(s)
        |   SetAdmin(parameters)                -> setAdmin(parameters, s)
        |   RemoveAdmin(parameters)             -> removeAdmin(parameters, s)
        
            // Housekeeping Entrypoints
        |   SetTokenMetadata (params)           -> setTokenMetadata(params, s)
        |   UpdateWhitelistContracts (params)   -> updateWhitelistContracts(params, s)
        |   MistakenTransfer (params)           -> mistakenTransfer(params, s)
        
            // Owner Entrypoints
        |   InitialiseToken (params)            -> initialiseToken(params, s)
        |   Mint (params)                       -> mint(params, s)
        |   Burn (params)                       -> burn(params, s)
        |   Pause (params)                      -> pause(params, s)
        |   Unpause (params)                    -> unpause(params, s)
        |   SetRuleEngines (params)             -> setRuleEngines(params, s)
        |   ScheduleSnapshot (params)           -> scheduleSnapshot(params.0, params.1, s)
        |   UnscheduleSnapshot (params)         -> unscheduleSnapshot(params, s)
        |   DeleteSnapshot (params)             -> deleteSnapshot(params, s)
        |   Kill (_params)                      -> kill(s)

            // Open Entrypoints
        |   SetIdentity (params)                -> setIdentity(params, s)
        |   Transfer (params)                   -> transfer(params, s)

            // Base FA2 Entrypoints
        |   Update_operators (params)           -> update_operators(params, s)
        |   Balance_of (params)                 -> balance_of(params, s)
    ]

