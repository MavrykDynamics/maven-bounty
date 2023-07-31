// ------------------------------------------------------------------------------
// Contract Types
// ------------------------------------------------------------------------------

// Transfer Controller Types
#include "../partials/contractTypes/transferControllerTypes.ligo"


// ------------------------------------------------------------------------------

type action is

        SetUser        of address
    |   SetRule        of address
        
    
type return is list (operation) * transferControllerStorageType
const noOperations : list (operation) = nil;


// ------------------------------------------------------------------------------
// Errors Begin
// ------------------------------------------------------------------------------

[@inline] const error_ADMINISTRATOR_NOT_FOUND                   = 0n;
[@inline] const error_NOT_ADMIN                                 = 1n;

// ------------------------------------------------------------------------------
// Errors End
// ------------------------------------------------------------------------------


function verifySenderIsAdmin(const s : transferControllerStorageType) : unit is 
block {

    if Tezos.get_sender() = s.administrator then skip else failwith(error_NOT_ADMIN);

} with unit



(* view_is_transfer_valid *)
[@view] function view_is_transfer_valid(const validation_transfer : validationTransferType; var s : transferControllerStorageType) : option(bool) is
block {

    const from_is_frozen : bool = case s.frozen_accounts[validation_transfer.from_] of [
            Some (_v) -> True
        |   None      -> False
    ];

    const to_is_frozen : bool = case s.frozen_accounts[validation_transfer.to_] of [
            Some (_v) -> True
        |   None      -> False
    ];

    const is_transfer_valid : bool = if from_is_frozen = True or to_is_frozen = True then False else True;

} with Some(is_transfer_valid)





(* setUser entrypoint *)
function setUser(const account : address; var s : transferControllerStorageType) : return is
block{

    skip

} with (noOperations, s)



(* setRule entrypoint *)
function setRule(const account : address; var s : transferControllerStorageType) : return is
block{

    skip

} with (noOperations, s)



(* main entrypoint *)
function main (const action : action; const s : transferControllerStorageType) : return is
case action of [

        SetUser (params)             -> setUser(params, s)
    |   SetRule (params)             -> setRule(params, s)
]
