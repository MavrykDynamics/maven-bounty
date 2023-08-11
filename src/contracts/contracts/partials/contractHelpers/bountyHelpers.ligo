// ------------------------------------------------------------------------------
//
// Helper Functions Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Admin Helper Functions Begin
// ------------------------------------------------------------------------------

// verify sender is admin
function verifySenderIsAdmin(const admins : set(address)) : unit is
block {

    const senderIsAdmin : bool = admins contains Tezos.get_sender();
    if senderIsAdmin then skip else failwith(error_ONLY_ADMINISTRATOR_ALLOWED);

} with unit



// verify sender is admin or bounty creator
function verifySenderIsAdminOrBountyCreator(const s : bountyStorageType) : unit is
block {

    const senderIsAdmin : bool = s.admins contains Tezos.get_sender();
    const senderIsBountyCreator : bool = checkInWhitelistContracts(Tezos.get_sender(), s.bountyCreators);
    if senderIsAdmin OR senderIsBountyCreator then skip else failwith(error_ONLY_ADMINISTRATOR_OR_BOUNTY_CREATOR_ALLOWED);

} with unit



// verify sender is bounty creator or whitelisted
function verifySenderIsAdminOrBountyCreator(const creator : address; const whitelisted : set(address)) : unit is
block {

    const senderIsBountyCreator : bool = creator = Tezos.get_sender();
    const senderIsWhitelisted : bool = whitelisted contains Tezos.get_sender();
    if senderIsBountyCreator OR senderIsWhitelisted then skip else failwith(error_ONLY_BOUNTY_CREATOR_OR_WHITELISTED_ALLOWED);

} with unit

// ------------------------------------------------------------------------------
// Admin Helper Functions End
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Pause / BreakGlass Helper Functions Begin
// ------------------------------------------------------------------------------

// helper function to pause all entrypoints
function pauseAllBountyEntrypoints(var s : bountyStorageType) : bountyStorageType is 
block {

    // set all pause configs to True
    if s.breakGlassConfig.createListingIsPaused then skip
    else s.breakGlassConfig.createListingIsPaused := True;

    if s.breakGlassConfig.editListingIsPaused then skip
    else s.breakGlassConfig.editListingIsPaused := True;

    if s.breakGlassConfig.removeListingIsPaused then skip
    else s.breakGlassConfig.removeListingIsPaused := True;

    if s.breakGlassConfig.purchaseIsPaused then skip
    else s.breakGlassConfig.purchaseIsPaused := True;

    if s.breakGlassConfig.offerIsPaused then skip
    else s.breakGlassConfig.offerIsPaused := True;

    if s.breakGlassConfig.acceptOfferIsPaused then skip
    else s.breakGlassConfig.acceptOfferIsPaused := True;

    if s.breakGlassConfig.removeOfferIsPaused then skip
    else s.breakGlassConfig.removeOfferIsPaused := True;

    if s.breakGlassConfig.setCurrencyIsPaused then skip
    else s.breakGlassConfig.setCurrencyIsPaused := True;

} with s



// helper function to unpause all entrypoints
function unpauseAllBountyEntrypoints(var s : bountyStorageType) : bountyStorageType is 
block {

    // set all pause configs to False
    if s.breakGlassConfig.createListingIsPaused then s.breakGlassConfig.createListingIsPaused := False
    else skip;

    if s.breakGlassConfig.editListingIsPaused then s.breakGlassConfig.editListingIsPaused := False
    else skip;

    if s.breakGlassConfig.removeListingIsPaused then s.breakGlassConfig.removeListingIsPaused := False
    else skip;

    if s.breakGlassConfig.purchaseIsPaused then s.breakGlassConfig.purchaseIsPaused := False
    else skip;

    if s.breakGlassConfig.offerIsPaused then s.breakGlassConfig.offerIsPaused := False
    else skip;
    
    if s.breakGlassConfig.acceptOfferIsPaused then s.breakGlassConfig.acceptOfferIsPaused := False
    else skip;

    if s.breakGlassConfig.removeOfferIsPaused then s.breakGlassConfig.removeOfferIsPaused := False
    else skip;

    if s.breakGlassConfig.setCurrencyIsPaused then s.breakGlassConfig.setCurrencyIsPaused := False
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

// ------------------------------------------------------------------------------
// Entrypoint Helper Functions End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Operations Helper Functions Begin
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Operations Helper Functions End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Getter Functions Begin
// ------------------------------------------------------------------------------

function getBountyRecord(const bountyId : nat; const s : bountyStorageType) : bountyRecordType is
block {

    const bountyRecord : bountyRecordType = case s.bountyLedger[bountyId] of [
            Some(_record) -> _record
        |   None          -> failwith(error_BOUNTY_RECORD_NOT_FOUND)
    ];

} with bountyRecord



function getApplicantRecord(const bountyId : nat; const applicant : address; const s : bountyStorageType) : applicantRecordType is
block {

    const applicantRecord : applicantRecordType = case s.applicantLedger[(bountyId, applicant)] of [
            Some(_record) -> _record
        |   None          -> failwith(error_APPLICANT_RECORD_NOT_FOUND)
    ];

} with applicantRecord



function getUserRecord(const userAddress : address; const s : bountyStorageType) : userRecordType is
block {

    const userRecord : userRecordType = case s.userLedger[userAddress] of [
            Some(_record) -> _record
        |   None          -> failwith(error_USER_RECORD_NOT_FOUND)
    ];

} with userRecord

// ------------------------------------------------------------------------------
// Getter Functions End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// General Helper Functions Begin
// ------------------------------------------------------------------------------

function verifyValidStatus(const status : string) : unit is
block{

    if status = "ACTIVE" or status = "INACTIVE" 
    then skip 
    else failwith(error_INVALID_STATUS);

} with unit



function verifyBountyIsActive(const status : string) : unit is 
block {

    if status = "ACTIVE" 
    then skip
    else failwith(error_BOUNTY_IS_NOT_ACTIVE);

} with unit



function verifyBountyIsNotPaused(const isPaused : bool) : unit is 
block {

    if isPaused = False
    then skip
    else failwith(error_BOUNTY_IS_PAUSED);

} with unit



function verifyBountyHasSpaceForNewApplicants(const maxApprovedApplicants : nat; const currentApprovedApplicants : nat) : unit is
block {

    if currentApprovedApplicants < maxApprovedApplicants 
    then skip
    else failwith(error_BOUNTY_HAS_NO_SPACE_FOR_NEW_APPLICANTS);

} with unit



function verifyUserCanApplyForNewBounties(const currentApplicationCount : nat; const maxApplications : nat) : unit is 
block {

    if currentApplicationCount < maxApplications 
    then skip
    else failwith(error_USER_CANNOT_APPLY_FOR_NEW_BOUNTIES);

} with unit



function verifyUserHasSpaceForNewBounties(const activeBountyCount : nat; const maxActiveBounties : nat) : unit is 
block {

    if activeBountyCount < maxActiveBounties 
    then skip
    else failwith(error_USER_HAS_NO_SPACE_FOR_NEW_BOUNTIES);

} with unit



function verifyApplicationIsPending(const status : string) : unit is
block {

    if status = "PENDING" 
    then skip
    else failwith(error_APPLICATION_STATUS_IS_NOT_PENDING);

} with unit



function verifyUserCanStopBounty(const status : string) : unit is 
block {

    if status = "APPROVED" or status = "DISPUTED" or status = "COMPLETED"
    then skip
    else failwith(error_BOUNTY_CANNOT_BE_STOPPED_BY_USER);

} with unit



function verifyUserCanCompleteBounty(const status : string) : unit is 
block {

    if status = "APPROVED"
    then skip
    else failwith(error_BOUNTY_CANNOT_BE_COMPLETED_BY_USER);

} with unit



function verifyMilestoneAndTotalRewardsTally(const totalRewards : rewardsType; const milestones : milestonesType) : unit is 
block {

    var milestoneRewardTally: map(string, nat) := map [];
    
    for _key -> milestone in map milestones block {

        for _tokenName -> reward in map milestone.rewards block {
            
            const currentRewardAmount : nat = case milestoneRewardTally[_tokenName] of [
                    Some(_amount) -> _amount
                |   None          -> 0n
            ];

            milestoneRewardTally[_tokenName] := currentRewardAmount + reward.rewardAmount;
        };

    };

    // Now compare the tally with the totalRewards of the bounty
    for tokenName -> tallyAmount in map milestoneRewardTally block {
        
        const expectedTotalAmount : nat = case totalRewards[tokenName] of [
                Some(_amount) -> _amount
            |   None          -> 0n
        ];

        if expectedTotalAmount = tallyAmount 
        then skip
        else failwith(error_MILESTONE_REWARDS_AND_TOTAL_REWARDS_DO_NOT_TALLY);

    };

} with unit


function createNewBountyRecord(const createBountyParams : createBountyActionType; var s : bountyStorageType) : bountyRecordType is 
block {

    verifyValidStatus(createBountyParams.status);

    const hasMilestones : bool = case createBountyParams.milestones of [
            Some(_v) -> True
        |   None     -> False
    ];

    if hasMilestones then {
        verifyMilestoneAndTotalRewardsTally(createBountyParams.totalRewards, createBountyParams.milestones);
    } else skip;

    const bountyRecord : bountyRecordType = record [
        creator                     = Tezos.get_sender();
        whitelisted                 = createBountyParams.whitelisted;

        name                        = createBountyParams.name;
        description                 = createBountyParams.description;
        image                       = createBountyParams.image;

        status                      = createBountyParams.status;
        isPaused                    = False;
        hasMilestones               = hasMilestones;

        maxApprovedApplicants       = createBountyParams.maxApprovedApplicants;
        currentApprovedApplicants   = 0n;

        milestones                  = createBountyParams.milestones;
        totalRewards                = createBountyParams.totalRewards;
    ];

} with bountyRecord



function createNewApplicantRecord(const _ : unit) : applicantRecordType is 
block {

    const applicantRecord : applicantRecordType = record [
        status              = "PENDING";
        reviewed            = False;
        completed           = False;

        currentMilestone    = (None : option(nat));
        milestoneLog        = (None : option(milestoneLogType));

        fullyRewarded       = False;
        lastRewardTimestamp = (None : option(timestamp));
    ];

} with applicantRecord

// ------------------------------------------------------------------------------
// Contract Helper Functions End
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Lambda Helper Functions Begin
// ------------------------------------------------------------------------------

// helper function to unpack and execute entrypoint logic stored as bytes in lambdaLedger
function unpackLambda(const lambdaBytes : bytes; const bountyLambdaAction : bountyLambdaActionType; var s : bountyStorageType) : return is 
block {

    const res : return = case (Bytes.unpack(lambdaBytes) : option(bountyUnpackLambdaFunctionType)) of [
            Some(f) -> f(bountyLambdaAction, s)
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