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


// verify sender is admin or super admin
function verifySenderIsAdminOrSuperAdmin(const superAdminAddress : address; const admins : set(address)) : unit is
block {

    const senderIsSuperAdmin : bool = superAdminAddress = Tezos.get_sender();
    const senderIsAdmin : bool = admins contains Tezos.get_sender();
    if senderIsSuperAdmin or senderIsAdmin then skip else failwith(error_ONLY_ADMINISTRATOR_OR_SUPER_ADMINISTRATOR_ALLOWED);

} with unit



function checkInBountyCreators(const userAddress : address; var bountyCreators : bountyCreatorsLedgerType) : bool is 
block {

    const inBountyCreatorsMap : bool = Big_map.mem(userAddress, bountyCreators);

} with inBountyCreatorsMap


// verify sender is admin or bounty creator
function verifySenderIsAdminOrBountyCreator(const s : bountyStorageType) : unit is
block {

    const senderIsAdmin : bool = s.admins contains Tezos.get_sender();
    const senderIsBountyCreator : bool = checkInBountyCreators(Tezos.get_sender(), s.bountyCreators);
    if senderIsAdmin or senderIsBountyCreator then skip else failwith(error_ONLY_ADMINISTRATOR_OR_BOUNTY_CREATOR_ALLOWED);

} with unit



// verify sender is bounty creator or whitelisted
function verifySenderIsAdminOrCreatorOrWhitelisted(const creator : address; const whitelisted : set(address); const s : bountyStorageType) : unit is
block {

    const senderIsAdmin : bool = s.admins contains Tezos.get_sender();
    const senderIsBountyCreator : bool = creator = Tezos.get_sender();
    const senderIsWhitelisted : bool = whitelisted contains Tezos.get_sender();
    if senderIsAdmin or senderIsBountyCreator or senderIsWhitelisted then skip else failwith(error_ONLY_ADMIN_OR_CREATOR_OR_WHITELISTED_ALLOWED);

} with unit



function verifySenderIsGroupCreator(const groupCreator : address; const sender : address) : unit is
block {

    if groupCreator = sender
    then skip
    else failwith(error_SENDER_IS_NOT_GROUP_CREATOR);

} with unit


function verifySenderIsApplicant(const applicant : address; const sender : address) : unit is
block {

    if applicant = sender
    then skip
    else failwith(error_SENDER_IS_NOT_APPLICANT);

} with unit

// ------------------------------------------------------------------------------
// Admin Helper Functions End
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

function getBountyCreatorRecord(const bountyCreatorAddress : address; const s : bountyStorageType) : bountyCreatorRecordType is
block {

    const bountyCreatorRecord : bountyCreatorRecordType = case s.bountyCreators[bountyCreatorAddress] of [
            Some(_record) -> _record
        |   None          -> failwith(error_BOUNTY_CREATOR_RECORD_NOT_FOUND)
    ];

} with bountyCreatorRecord



function getBountyRecord(const bountyId : nat; const s : bountyStorageType) : bountyRecordType is
block {

    const bountyRecord : bountyRecordType = case s.bountyLedger[bountyId] of [
            Some(_record) -> _record
        |   None          -> failwith(error_BOUNTY_RECORD_NOT_FOUND)
    ];

} with bountyRecord



function getApplicationRecord(const bountyId : nat; const applicant : applicantType; const s : bountyStorageType) : applicationRecordType is
block {

    const applicationRecord : applicationRecordType = case s.applicationLedger[(bountyId, applicant)] of [
            Some(_record) -> _record
        |   None          -> failwith(error_APPLICATION_RECORD_NOT_FOUND)
    ];

} with applicationRecord



function getBountyMilestoneRecord(const bountyRecord : bountyRecordType; const milestoneId : nat) : milestoneRecordType is
block {

    const milestoneRecord : milestoneRecordType = case bountyRecord.milestones of [
            Some(_milestones) -> case _milestones[milestoneId] of [
                    Some(_record) -> _record
                |   None          -> failwith(error_MILESTONE_RECORD_FOR_BOUNTY_NOT_FOUND)
            ]
        |   None          -> failwith(error_MILESTONES_FOR_BOUNTY_NOT_FOUND)
    ];

} with milestoneRecord



function getApplicantMilestoneRecord(const applicationRecord : applicationRecordType; const milestoneId : nat) : milestoneLogRecordType is
block {

    const milestoneLogRecord : milestoneLogRecordType = case applicationRecord.milestoneLog of [
            Some(_milestoneLog) -> case _milestoneLog[milestoneId] of [
                    Some(_record) -> _record
                |   None          -> failwith(error_MILESTONE_RECORD_FOR_APPLICANT_NOT_FOUND)
            ]
        |   None          -> failwith(error_MILESTONE_LOG_FOR_APPLICANT_NOT_FOUND)
    ];

} with milestoneLogRecord



function getUserRecord(const userAddress : address; const s : bountyStorageType) : userRecordType is
block {

    const userRecord : userRecordType = case s.userLedger[userAddress] of [
            Some(_record) -> _record
        |   None          -> failwith(error_USER_RECORD_NOT_FOUND)
    ];

} with userRecord



function getGroupRecord(const groupId : nat; const s : bountyStorageType) : groupRecordType is
block {

    const groupRecord : groupRecordType = case s.groupLedger[groupId] of [
            Some(_record) -> _record
        |   None          -> failwith(error_GROUP_RECORD_NOT_FOUND)
    ];

} with groupRecord



function getOrCreateUserRecord(const userAddress : address; const s : bountyStorageType) : userRecordType is
block {

    const userRecord : userRecordType = case s.userLedger[userAddress] of [
            Some(_record) -> _record
        |   None          -> record [
                activeBountyCount       = 0n;
                activeBounties          = (set[] : set(nat));
                currentApplicationCount = 0n;
                appliedBounties         = (set[] : set(nat));
                groupInvites            = (set[] : set(nat));
                groupApplications       = (set[] : set(nat));
                groupsCreated           = (set[] : set(nat));
                groups                  = (set[] : set(nat));   
            ]
    ];

} with userRecord



function createGroupRecord(const creator : address) : groupRecordType is 
block {

    const groupRecord : groupRecordType = record [
        creator                     = creator;
        status                      = "ACTIVE";
        bountyInProgress            = False;

        name                        = (None : option(string));
        description                 = (None : option(string));
        image                       = (None : option(string));

        applicants                  = (set[] : set(address));
        members                     = (set[] : set(address));

        activeBountyCount           = 0n;
        activeBounties              = (set[] : set(nat));
        currentApplicationCount     = 0n;
        appliedBounties             = (set[] : set(nat));
    ];

} with groupRecord

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



function verifyValidBountyReviewStatus(const status : string) : unit is 
block {

    if status = "REVIEW_APPROVED" or status = "REVIEW_DISPUTED" or status = "REVIEW_REJECTED" 
    then skip 
    else failwith(error_INVALID_STATUS_FOR_BOUNTY_REVIEW);

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


function verifyBountyHasMilestones(const hasMilestones : bool) : unit is
block {
    
    if hasMilestones = True
    then skip
    else failwith(error_BOUNTY_HAS_NO_MILESTONES);

} with unit


function verifyBountyHasSpaceForNewApplicants(const maxApprovedApplicants : nat; const currentApprovedApplicants : nat) : unit is
block {

    if currentApprovedApplicants < maxApprovedApplicants 
    then skip
    else failwith(error_BOUNTY_HAS_NO_SPACE_FOR_NEW_APPLICANTS);

} with unit



function verifyMaxApplicationsNotReached(const currentApplicationCount : nat; const maxApplications : nat) : unit is 
block {

    if currentApplicationCount < maxApplications 
    then skip
    else failwith(error_USER_HAS_REACHED_MAX_APPLICATIONS_ALLOWED);

} with unit



function verifyMaxActiveBountiesNotReached(const activeBountyCount : nat; const maxActiveBounties : nat) : unit is 
block {

    if activeBountyCount < maxActiveBounties 
    then skip
    else failwith(error_USER_HAS_NO_SPACE_FOR_NEW_BOUNTIES);

} with unit



function verifyUserHasNotAlreadyAppliedForBounty(const bountyId : nat; const applicant : applicantType; const s : bountyStorageType) : unit is
block {

    case s.applicationLedger[(bountyId, applicant)] of [
            Some(_v) -> failwith(error_USER_HAS_ALREADY_APPLIED_FOR_THIS_BOUNTY)
        |   None     -> skip
    ];

} with unit



function verifyMaxGroupsCreatedPerUserNotReached(const groups : set(nat); const maxGroupsCreatedPerUser : nat) : unit is 
block {

    if Set.cardinal(groups) < maxGroupsCreatedPerUser 
    then skip
    else failwith(error_MAX_GROUPS_CREATED_PER_USER_REACHED);

} with unit



function verifyUserIsInGroup(const user : address; const groupMembers : set(address)) : unit is
block {

    if groupMembers contains user 
    then skip
    else failwith(error_USER_IS_NOT_IN_GROUP);

} with unit



function verifyUserIsInvitedToGroup(const groupInvites : set(nat); const groupId : nat) : unit is
block {

    if groupInvites contains groupId 
    then skip
    else failwith(error_USER_IS_NOT_INVITED_TO_JOIN_GROUP);

} with unit



function verifyMaxMembersPerGroupNotReached(const groupMembers : set(address); const maxMembersPerGroup : nat) : unit is
block{

    if Set.cardinal(groupMembers) < maxMembersPerGroup 
    then skip 
    else failwith(error_MAX_MEMBERS_PER_GROUP_REACHED);

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

    if status = "REVIEW_APPROVED" or status = "REWARDED"
    then skip
    else failwith(error_BOUNTY_HAS_ALREADY_BEEN_COMPLETED_AND_APPROVED);

} with unit



function verifyCorrectMilestoneReviewed(const milestoneToReview : nat; const currentMilestone : nat) : unit is 
block {

    if milestoneToReview = currentMilestone 
    then skip 
    else failwith(error_MILESTONE_TO_REVIEW_NEEDS_TO_BE_THE_SAME_AS_CURRENT_MILESTONE)

} with unit



function verifyMilestoneAndTotalRewardsTally(const totalRewards : rewardsType; const milestones : option(milestonesType)) : unit is 
block {

    const milestones : milestonesType = case milestones of [
            Some(_v) -> _v
        |   None     -> failwith(error_BOUNTY_HAS_NO_MILESTONES)
    ];

    var milestoneRewardTally: map(string, nat) := map [];
    
    for _key -> milestone in map milestones block {

        for _tokenName -> reward in map milestone.rewards block {
            
            const currentRewardAmount : nat = case milestoneRewardTally[_tokenName] of [
                    Some(_amount) -> _amount
                |   None          -> 0n
            ];

            milestoneRewardTally[_tokenName] := currentRewardAmount + reward.amount;
        };

    };

    // Now compare the tally with the totalRewards of the bounty
    for tokenName -> tallyAmount in map milestoneRewardTally block {
        
        const expectedTotalAmount : nat = case totalRewards[tokenName] of [
                Some(_token)  -> _token.amount
            |   None          -> 0n
        ];

        if expectedTotalAmount = tallyAmount 
        then skip
        else failwith(error_MILESTONE_REWARDS_AND_TOTAL_REWARDS_DO_NOT_TALLY);

    };

} with unit



function getNewTotalRewards(const milestones : milestonesType) : rewardsType is 
block {

    var newTotalRewards : rewardsType := map [];
    
    for _key -> milestone in map milestones block {

        for _tokenName -> reward in map milestone.rewards block {
            
            const currentRewardAmount : nat = case newTotalRewards[_tokenName] of [
                    Some(_token) -> _token.amount 
                |   None         -> 0n
            ];

            newTotalRewards[_tokenName] := record [
                amount          = currentRewardAmount + reward.amount;
                rewardTokenType = reward.rewardTokenType;
            ];
        };

    };

} with newTotalRewards



function differenceBetweenRewards(
    const initialRewards : rewardsType; 
    const initialMaxApprovedApplicants : nat; 
    const updatedRewards : rewardsType;
    const updatedMaxApprovedApplicants : nat
) : rewardsDiffType is
block {

    var diffMap : rewardsDiffType := map [];

    // Loop through the initial rewards
    for tokenName -> initialReward in map initialRewards block {

        const updatedRewardsAmount : nat = case updatedRewards[tokenName] of [
                Some(_v) -> _v.amount
            |   None     -> 0n
        ];
        
        const diffAmount : int = (updatedRewardsAmount * updatedMaxApprovedApplicants) - (initialReward.amount * initialMaxApprovedApplicants);

        diffMap[tokenName] := record [
            rewardTokenType = initialReward.rewardTokenType;
            amount          = diffAmount;
        ];
    };

    // Now, handle tokens present only in the updated rewards
    for tokenName -> updatedReward in map updatedRewards block {
        
        if not (Map.mem(tokenName, initialRewards)) then {
            
            diffMap[tokenName] := record [
                rewardTokenType = updatedReward.rewardTokenType;
                amount          = int(updatedReward.amount * updatedMaxApprovedApplicants);
            ];

        } else skip; 
    };

} with diffMap;



function createNewBountyCreatorRecord(
    const nameOpt : option(string); 
    const descOpt : option(string);
    const websiteOpt : option(string); 
    const imageOpt : option(string)
) : bountyCreatorRecordType is
block {

    var bountyCreatorRecord : bountyCreatorRecordType := record [
        name        = "";
        description = "";
        website     = "";
        image       = Some("");
        bounties    = (set[] : set(nat));
    ];

    case nameOpt of [
            Some(_newName) -> bountyCreatorRecord.name := _newName
        |   None -> skip
    ];

    case descOpt of [
            Some(_newDescription) -> bountyCreatorRecord.description := _newDescription
        |   None -> skip
    ];

    case websiteOpt of [
            Some(_newWebsite) -> bountyCreatorRecord.website := _newWebsite
        |   None -> skip
    ];

    case imageOpt of [
            Some(_newImage) -> bountyCreatorRecord.image := imageOpt
        |   None -> skip
    ];

} with bountyCreatorRecord



function updateBountyCreatorRecord(
    var bountyCreatorRecord : bountyCreatorRecordType;
    const nameOpt : option(string); 
    const descOpt : option(string);
    const websiteOpt : option(string); 
    const imageOpt : option(string)
) : bountyCreatorRecordType is
block {

    case nameOpt of [
            Some(_newName) -> bountyCreatorRecord.name := _newName
        |   None -> skip
    ];

    case descOpt of [
            Some(_newDescription) -> bountyCreatorRecord.description := _newDescription
        |   None -> skip
    ];

    case websiteOpt of [
            Some(_newWebsite) -> bountyCreatorRecord.website := _newWebsite
        |   None -> skip
    ];

    case imageOpt of [
            Some(_newImage) -> bountyCreatorRecord.image := imageOpt
        |   None -> skip
    ];

} with bountyCreatorRecord



function createNewBountyRecord(const createBountyParams : createBountyActionType) : bountyRecordType is 
block {

    verifyValidStatus(createBountyParams.status);

    const hasMilestones : bool = case createBountyParams.milestones of [
            Some(_v) -> True
        |   None     -> False
    ];

    if hasMilestones then {
        verifyMilestoneAndTotalRewardsTally(createBountyParams.totalRewards, createBountyParams.milestones);
    } else skip;

    const whitelisted : set(address) = case createBountyParams.whitelisted of [
            Some(_v) -> _v
        |   None     -> (set[] : set(address))
    ];

    const bountyRecord : bountyRecordType = record [
        creator                     = Tezos.get_sender();
        whitelisted                 = whitelisted;

        name                        = createBountyParams.name;
        description                 = createBountyParams.description;
        image                       = createBountyParams.image;

        status                      = createBountyParams.status;
        isPaused                    = False;
        hasMilestones               = hasMilestones;

        maxApprovedApplicants       = createBountyParams.maxApprovedApplicants;
        currentApprovedApplicants   = (map[] : currentApprovedApplicantsType);
        completedApplicants         = (set[] : set(applicantType));

        milestones                  = createBountyParams.milestones;
        totalRewards                = createBountyParams.totalRewards;
    ];

} with bountyRecord



function createNewApplicationRecord(const _ : unit) : applicationRecordType is 
block {

    const applicationRecord : applicationRecordType = record [
        status              = "PENDING";
        completed           = False;
        reviewed            = False;
        review              = (None : option(string));

        currentMilestone    = (None : option(nat));
        milestoneLog        = (None : option(milestoneLogType));

        fullyRewarded       = False;
        lastRewardTimestamp = (None : option(timestamp));
    ];

} with applicationRecord



function createNewMilestoneLog(const _ : unit) : milestoneLogRecordType is 
block {

    const milestoneLogRecord : milestoneLogRecordType = record [
        status          = "REVIEW_PENDING";
        completed       = False;
        reviewed        = False;
        review          = (None : option(string));

        rewarded        = False;
        rewardTimestamp = (None : option(timestamp));
    ];

} with milestoneLogRecord

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