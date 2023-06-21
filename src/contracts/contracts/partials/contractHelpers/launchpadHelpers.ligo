// ------------------------------------------------------------------------------
//
// Helper Functions Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Admin Helper Functions Begin
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Admin Helper Functions End
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Pause / BreakGlass Helper Functions Begin
// ------------------------------------------------------------------------------

// helper function to pause all entrypoints
function pauseAllLaunchpadEntrypoints(var s : launchpadStorageType) : launchpadStorageType is 
block {

    // set all pause configs to True
    if s.breakGlassConfig.createTokenLaunchIsPaused then skip
    else s.breakGlassConfig.createTokenLaunchIsPaused := True;

    if s.breakGlassConfig.startLaunchIsPaused then skip
    else s.breakGlassConfig.startLaunchIsPaused := True;

    if s.breakGlassConfig.closeLaunchIsPaused then skip
    else s.breakGlassConfig.closeLaunchIsPaused := True;

    if s.breakGlassConfig.setLaunchWhitelistIsPaused then skip
    else s.breakGlassConfig.setLaunchWhitelistIsPaused := True;

    if s.breakGlassConfig.editTokenLaunchIsPaused then skip
    else s.breakGlassConfig.editTokenLaunchIsPaused := True;

    if s.breakGlassConfig.pauseLaunchIsPaused then skip
    else s.breakGlassConfig.pauseLaunchIsPaused := True;

    if s.breakGlassConfig.unpauseLaunchIsPaused then skip
    else s.breakGlassConfig.unpauseLaunchIsPaused := True;

    if s.breakGlassConfig.distributeTokensIsPaused then skip
    else s.breakGlassConfig.distributeTokensIsPaused := True;

    if s.breakGlassConfig.purchaseIsPaused then skip
    else s.breakGlassConfig.purchaseIsPaused := True;

} with s



// helper function to unpause all entrypoints
function unpauseAllLaunchpadEntrypoints(var s : launchpadStorageType) : launchpadStorageType is 
block {

    // set all pause configs to False
    if s.breakGlassConfig.createTokenLaunchIsPaused then s.breakGlassConfig.createTokenLaunchIsPaused := False
    else skip;

    if s.breakGlassConfig.createTokenLaunchIsPaused then s.breakGlassConfig.createTokenLaunchIsPaused := False
    else skip;

    if s.breakGlassConfig.closeLaunchIsPaused then s.breakGlassConfig.closeLaunchIsPaused := False
    else skip;

    if s.breakGlassConfig.setLaunchWhitelistIsPaused then s.breakGlassConfig.setLaunchWhitelistIsPaused := False
    else skip;
    
    if s.breakGlassConfig.editTokenLaunchIsPaused then s.breakGlassConfig.editTokenLaunchIsPaused := False
    else skip;

    if s.breakGlassConfig.pauseLaunchIsPaused then s.breakGlassConfig.pauseLaunchIsPaused := False
    else skip;

    if s.breakGlassConfig.unpauseLaunchIsPaused then s.breakGlassConfig.unpauseLaunchIsPaused := False
    else skip;

    if s.breakGlassConfig.distributeTokensIsPaused then s.breakGlassConfig.distributeTokensIsPaused := False
    else skip;

    if s.breakGlassConfig.purchaseIsPaused then s.breakGlassConfig.purchaseIsPaused := False
    else skip;

} with s

// ------------------------------------------------------------------------------
// Pause / BreakGlass Helper Functions End
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Entrypoint Helper Functions Begin
// ------------------------------------------------------------------------------

// helper function to get transfer entrypoint
function getTransferEntrypointFromTokenAddress(const tokenAddress : address) : contract(fa2TransferType) is
    case (Tezos.get_entrypoint_opt(
        "%transfer",
        tokenAddress) : option(contract(fa2TransferType))) of [
                Some(contr) -> contr
            |   None -> (failwith(error_TRANSFER_ENTRYPOINT_IN_FA2_CONTRACT_NOT_FOUND) : contract(fa2TransferType))
        ];


// helper function to get mint entrypoint
function getMintEntrypointFromTokenAddress(const tokenAddress : address) : contract(list(tokenAmountType)) is
    case (Tezos.get_entrypoint_opt(
        "%mint",
        tokenAddress) : option(contract(list(tokenAmountType)))) of [
                Some(contr) -> contr
            |   None -> (failwith(error_MINT_ENTRYPOINT_IN_FA2_CONTRACT_NOT_FOUND) : contract(list(tokenAmountType)))
        ];


// ------------------------------------------------------------------------------
// Entrypoint Helper Functions End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Operations Helper Functions Begin
// ------------------------------------------------------------------------------

function mintFa2Token(const to_ : address; const tokenAmount : nat; const tokenId : nat; const tokenContractAddress : address) : operation is
block{

    const mintParams : list(tokenAmountType) = list[
            record[
                address         = to_;
                token_id        = tokenId;
                amount          = tokenAmount;
            ]
        ];

    const tokenContract : contract(list(tokenAmountType)) =
        case (Tezos.get_entrypoint_opt("%mint", tokenContractAddress) : option(contract(list(tokenAmountType)))) of [
                Some (c) -> c
            |   None     -> (failwith(error_MINT_ENTRYPOINT_IN_FA2_CONTRACT_NOT_FOUND) : contract(list(tokenAmountType)))
        ];
        
} with (Tezos.transaction(mintParams, 0tez, tokenContract))


// ------------------------------------------------------------------------------
// Operations Helper Functions End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// General Helper Functions Begin
// ------------------------------------------------------------------------------

function getLaunchRecord(const launchId : nat; const s : launchpadStorageType) : launchRecordType is 
block {

    const launchRecord : launchRecordType = case s.launchLedger[launchId] of [
            Some(_record) -> _record
        |   None          -> failwith(error_LAUNCH_RECORD_NOT_FOUND)
    ];

} with launchRecord



function getSaleOption(const launchRecord : launchRecordType; const saleOptionName : string) : tokenSaleOptionType is 
block {

    const saleOption : tokenSaleOptionType = case launchRecord.saleOptions[saleOptionName] of [
            Some(_saleOption) -> _saleOption
        |   None              -> failwith(error_SALE_OPTION_NOT_FOUND)
    ];
    
} with saleOption



function getOrCreatePurchaseRecord(const launchUserKey : (nat * address); const s : launchpadStorageType) : purchaseRecordType is 
block {

    const userPurchaseRecord : purchaseRecordType = case s.purchaseLedger[launchUserKey] of [
            Some(_purchaseRecord) -> _purchaseRecord
        |   None -> record [
                purchased           = (map[] : map(string, nat));
                totalPurchased      = 0n;
                totalDistributed    = 0n;
            ]
    ];
    
} with userPurchaseRecord


// helper function to get contract address from general contracts map
function getAddressFromGeneralContracts(const contractName : string; const s : launchpadStorageType; const errorCode : nat) : address is 
block {

    const contractAddress : address = case s.generalContracts[contractName] of [
            Some(_address) -> _address
        |   None           -> failwith(errorCode)
    ];

} with contractAddress



function verifyValidTokenIssuanceType(const tokenIssuanceType : string) : unit is
block {

    if tokenIssuanceType = "MINT" or tokenIssuanceType = "TRANSFER" then skip else failwith (error_INVALID_TOKEN_ISSUANCE_TYPE);

} with unit



function verifyLaunchIsActive(const status : string) : unit is
block {

    if status = "ACTIVE" then skip else failwith(error_LAUNCH_IS_NOT_ACTIVE);

} with unit



function verifyLaunchHasNotEnded(const saleEnd : option(timestamp)) : unit is
block {

    case saleEnd of [
            Some(_saleEndTimestamp) -> {
                if Tezos.get_now() > _saleEndTimestamp then failwith(error_LAUNCH_HAS_ENDED) else skip;
            }
        |   None -> skip
    ]

} with unit



function verifyValidTokenDistributionType(const tokenDistributionType : string) : unit is
block {

    if tokenDistributionType = "MANUAL" or tokenDistributionType = "AUTO" then skip else failwith (error_INVALID_TOKEN_DISTRIBUTION_TYPE);

} with unit



function verifyValidSaleEnd(const saleStart : timestamp; const saleEnd : option(timestamp)) : unit is 
block {

    case saleEnd of [
            Some(_saleEndTimestamp) -> if _saleEndTimestamp < saleStart then failwith(error_SALE_END_SHOULD_BE_AFTER_SALE_START) else skip
        |   None -> skip // no sale end timestamp; sale has to be closed manually
    ];

} with unit



function verifyValidWhitelistSaleEnd(const whitelistSaleStart : option(timestamp); const whitelistSaleEnd : option(timestamp)) : unit is 
block {

    case whitelistSaleStart of [
            Some(_whitelistStartTimestamp) -> {
                // check that whitelist sale end timestamp comes after whitelist start timestamp
                case whitelistSaleEnd of [
                        Some(_whitelistEndTimestamp) -> if _whitelistEndTimestamp < _whitelistStartTimestamp then failwith(error_WHITELIST_SALE_END_SHOULD_BE_AFTER_WHITELIST_SALE_START) else skip
                    |   None -> skip
                ];
            }
        |   None -> {
            
                // check that whitelist sale start timestamp exists if whitelist sale end is specified
                case whitelistSaleEnd of [
                        Some(_whitelistEndTimestamp) -> failwith(error_WHITELIST_SALE_START_NOT_SPECIFIED)
                    |   None -> skip
                ];
            
            }
    ];

} with unit


function verifyValidCustomWhitelistOptions(const whitelistOptions : map(string, nat); const launchRecord : launchRecordType) : unit is
block {

    // verify that whitelist options exist
    for optionName -> _allowedAmount in map whitelistOptions block {
        case launchRecord.saleOptions[optionName] of [
                Some(_v) -> skip
            |   None -> failwith(error_WHITELIST_OPTION_DOES_NOT_EXIST)
        ];
    };
    
} with unit



// function verifyValidCurrency(const currency : tokenType; const s : launchpadStorageType) : unit is 
// block {

//     case currency of [
//             Tez -> skip
//         |   Fa12(_address) -> if Big_map.mem(_address, s.currencyLedger) then skip else failwith(error_INVALID_CURRENCY)
//         |   Fa2(_fa2Token) -> if Big_map.mem(_fa2Token.tokenContractAddress, s.currencyLedger) then skip else failwith(error_INVALID_CURRENCY)
//     ];

// } with unit


function processTokenIssuance(
    const tokenIssuanceType : string; 
    const treasuryAddress : address; 
    const recipient : address; 
    const amount : nat; 
    const tokenId : nat; 
    const tokenContractAddress : address; 
    var operations : list(operation)) : list(operation) is 
block {

    if tokenIssuanceType = "TRANSFER" then block {

        const transferOperation : operation = transferFa2Token(
            treasuryAddress,        // from_
            recipient,              // to_
            amount,                 // amount
            tokenId,                // tokenId
            tokenContractAddress    // tokenContractAddress
        );
        operations := transferOperation # operations;

    } else if tokenIssuanceType = "MINT" then block {

        const mintOperation : operation = mintFa2Token(
            recipient,              // to_
            amount,                 // amount
            tokenId,                // tokenId
            tokenContractAddress    // tokenContractAddress
        );
        operations := mintOperation # operations;

    };

} with operations

// ------------------------------------------------------------------------------
// Contract Helper Functions End
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Lambda Helper Functions Begin
// ------------------------------------------------------------------------------

// helper function to unpack and execute entrypoint logic stored as bytes in lambdaLedger
function unpackLambda(const lambdaBytes : bytes; const launchpadLambdaAction : launchpadLambdaActionType; var s : launchpadStorageType) : return is 
block {

    const res : return = case (Bytes.unpack(lambdaBytes) : option(launchpadUnpackLambdaFunctionType)) of [
            Some(f) -> f(launchpadLambdaAction, s)
        |   None    -> failwith(error_UNABLE_TO_UNPACK_LAMBDA)
    ];

} with (res.0, res.1)

// ------------------------------------------------------------------------------
// Lambda Helper Functions End
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
//
// Helper Functions End
//
// ------------------------------------------------------------------------------