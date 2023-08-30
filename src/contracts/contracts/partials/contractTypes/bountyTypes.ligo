// ------------------------------------------------------------------------------
// Storage Types
// ------------------------------------------------------------------------------

type bountyIdType is nat

type bountyConfigType is [@layout:comb] record [
    maxActiveBounties           : nat;
    maxApplications             : nat;
    
    maxMembersPerGroup          : nat;
    maxGroupsCreatedPerUser     : nat;
    maxGroupsPerUser            : nat;
];


type milestoneLogRecordType is [@layout:comb] record [
    status               : string;               // PENDING / APPROVED / REJECTED / COMPLETED / REVIEW_PENDING / REVIEW_APPROVED / REVIEW_DISPUTED / REVIEW_REJECTED / REWARDED
    isCompleted          : bool;      
    
    submitForReview      : bool;                 // to be set to True by applicant on completeBounty
    reviewed             : bool;                 // to be reviewed by bounty creator
    review               : option(string);       // to be set by bounty creator

    rewarded             : bool;                 // to be rewarded by bounty creator
    rewardTimestamp      : option(timestamp);
]
type milestoneLogType is map(nat, milestoneLogRecordType)



type applicationRecordType is [@layout:comb] record [
    
    status               : string;               // PENDING / APPROVED / REJECTED / CANCELED / STOPPED / REVIEW_PENDING / REVIEW_APPROVED / REVIEW_DISPUTED / REVIEW_REJECTED

    isApproved           : bool;
    isStopped            : bool;
    isCompleted          : bool;                 // set to True if completely done

    submitForReview      : bool;                 // to be set to True by applicant on completeBounty
    reviewed             : bool;                 // to be reviewed by bounty creator
    review               : option(string);       // to be set by bounty creator
    
    currentMilestone     : option(nat);          // milestone counter for bounty if exists
    milestoneLog         : option(milestoneLogType);
    
    fullyRewarded        : bool;
    lastRewardTimestamp  : option(timestamp);
]

type applicantType is 
    |   User      of address
    |   Group     of nat

type applicationLedgerType is big_map((bountyIdType * applicantType), applicationRecordType)



type rewardsDiffRecordType is [@layout:comb] record [
    amount               : int;
    rewardTokenType      : tokenType;
]
type rewardsDiffType is map(string, rewardsDiffRecordType)


type rewardsRecordType is [@layout:comb] record [
    amount               : nat;
    rewardTokenType      : tokenType;
]
type rewardsType is map(string, rewardsRecordType)


type milestoneRecordType is [@layout:comb] record [
    name                 : string;
    description          : string;
    image                : option(string);
    rewards              : rewardsType;
]
type milestonesType is map(nat, milestoneRecordType)


type bountyProgressType is 
    |   Milestone       of nat
    |   NoMilestone 
    |   Completed

type currentApprovedApplicantsType is map(applicantType, bountyProgressType)

type bountyRecordType is [@layout:comb] record [
    creator                     : address;
    whitelisted                 : set(address);

    name                        : string;
    description                 : string;
    image                       : option(string);

    status                      : string;          // ACTIVE / INACTIVE 
    isPaused                    : bool;
    hasMilestones               : bool;
    
    maxApprovedApplicants       : nat;
    currentApprovedApplicants   : currentApprovedApplicantsType;
    completedApplicants         : set(applicantType);

    milestones                  : option(milestonesType); 
    totalRewards                : rewardsType;     // total rewards per applicant if everything is completed successfully - will be used as reference for total rewards if milestones are set (i.e. milestone rewards take precedence)
]
type bountyLedgerType is big_map(bountyIdType, bountyRecordType)



type groupRecordType is [@layout:comb] record [
    creator                     : address;
    status                      : string; 
    bountyInProgress            : bool;

    name                        : option(string);
    description                 : option(string);
    image                       : option(string);

    applicants                  : set(address); // users who are applying to group
    members                     : set(address);

    activeBountyCount           : nat; 
    activeBounties              : set(nat);
    currentApplicationCount     : nat;
    appliedBounties             : set(nat);
]
type groupLedgerType is big_map(nat, groupRecordType)


type userRecordType is [@layout:comb] record [
    activeBountyCount           : nat; 
    activeBounties              : set(nat);
    currentApplicationCount     : nat;
    appliedBounties             : set(nat);
    groupInvites                : set(nat); 
    groupApplications           : set(nat); 
    groupsCreated               : set(nat);
    groups                      : set(nat);
]
type userLedgerType is big_map(address, userRecordType)


type applicantRecordType is 
    |   User    of userRecordType
    |   Group   of groupRecordType


type bountyCreatorRecordType is [@layout:comb] record [
    name            : string; 
    description     : string;
    website         : string;
    image           : option(string);
    bounties        : set(nat);         // loose reference to bounties created for convenience (N.B. may have discrepancies if bounty creator was added, then removed, then added again)
]

type bountyCreatorsLedgerType is big_map(address, bountyCreatorRecordType)

// ------------------------------------------------------------------------------
// Action Types
// ------------------------------------------------------------------------------

type createBountyActionType is [@layout:comb] record [
    whitelisted             : option(set(address));
    name                    : string;
    description             : string;
    image                   : option(string);
    status                  : string; 
    maxApprovedApplicants   : nat;
    milestones              : option(milestonesType);
    totalRewards            : rewardsType;
]


type updateBountyActionType is [@layout:comb] record [
    bountyId                : nat;
    name                    : option(string);
    description             : option(string);
    image                   : option(string);
    maxApprovedApplicants   : option(nat);
    milestones              : option(milestonesType);
    rewards                 : option(rewardsType);
]


type updateBountyWhitelistActionType is [@layout:comb] record [
    bountyId        : nat;
    addresses       : set(address);
    updateType      : updateType;
]

type updateMilestoneActionType is [@layout:comb] record [
    bountyId        : nat;
    milestoneId     : nat;
    name            : option(string);
    description     : option(string);
    image           : option(string);
    rewards         : option(rewardsType);
] 

type togglePauseBountyActionType is nat // bountyId



type setNewBountyCreatorActionType is [@layout:comb] record [
    creatorAddress  : address;
    name            : option(string); 
    description     : option(string);
    website         : option(string);
    image           : option(string);
    bounties        : option(set(nat));
]

type updateBountyCreatorProfileActionType is [@layout:comb] record [
    name            : option(string); 
    description     : option(string);
    website         : option(string);
    image           : option(string);
]


type setBountyCreatorActionType is 
    |   SetNewBountyCreator         of setNewBountyCreatorActionType
    |   RemoveBountyCreator         of address
    |   UpdateBountyCreatorProfile  of updateBountyCreatorProfileActionType


type setBountyActionType is 
    |   CreateBounty        of createBountyActionType
    |   UpdateBounty        of updateBountyActionType
    |   UpdateWhitelist     of updateBountyWhitelistActionType
    |   UpdateMilestone     of updateMilestoneActionType


type approvalType is 
    |   Approve of unit
    |   Reject of unit

type approveOrRejectActionType is [@layout:comb] record [
    bountyId    : nat;
    applicant   : applicantType;
    approval    : approvalType;
]


type reviewBountyActionType is [@layout:comb] record [
    bountyId            : nat;
    applicant           : applicantType;
    status              : string;
    milestoneReview     : option(string);
    bountyReview        : option(string);
]


type sendBountyRewardActionType is [@layout:comb] record [
    bountyId     : nat;
    milestoneId  : option(nat);
    applicant    : applicantType;
]


type applyForBountyActionType is [@layout:comb] record [
    bountyId    : nat;
    applicant   : applicantType;
]

type cancelApplicationActionType is [@layout:comb] record [
    bountyId    : nat;
    applicant   : applicantType;
]

type completeBountyActionType is [@layout:comb] record [
    bountyId    : nat;
    applicant   : applicantType;
]

type stopBountyActionType is [@layout:comb] record [
    bountyId    : nat;
    applicant   : applicantType;
]

type bountyUpdateConfigNewValueType is nat
type bountyUpdateConfigActionType is 
        ConfigMaxActiveBounties         of unit
    |   ConfigMaxApplications           of unit
    |   ConfigMaxMembersPerGroup        of unit
    |   ConfigMaxGroupsCreatedPerUser   of unit
    |   ConfigMaxGroupsPerUser          of unit

type bountyUpdateConfigParamsType is [@layout:comb] record [
    updateConfigNewValue    : bountyUpdateConfigNewValueType; 
    updateConfigAction      : bountyUpdateConfigActionType;
]



type formGroupActionType is [@layout:comb] record [
    name            : option(string); 
    description     : option(string);
    image           : option(string);
]


type manageGroupMembersType is 
    |   Invite      of unit
    |   Remove      of unit
    |   Approve     of unit

type setGroupMemberActionType is [@layout:comb] record [
    groupId     : nat;
    member      : address;
    updateType  : manageGroupMembersType;
]

type groupMembershipActionType is 
    |   ApplyForGroup           of nat
    |   ConfirmGroupMembership  of nat


type leaveGroupActionType is nat

// ------------------------------------------------------------------------------
// Lambda Action Types
// ------------------------------------------------------------------------------


type bountyLambdaActionType is 

        // Admin Lambdas
        LambdaSetSuperAdmin               of (address)
    |   LambdaClaimSuperAdmin             of (unit)
    |   LambdaSetAdmin                    of (address)
    |   LambdaRemoveAdmin                 of (address)

        // Housekeeping Lambdas
    |   LambdaUpdateMetadata              of updateMetadataType
    |   LambdaUpdateConfig                of bountyUpdateConfigParamsType
    |   LambdaMistakenTransfer            of transferActionType

        // Bounty Admin and Bounty Creators Lambdas
    |   LambdaSetBountyCreator            of setBountyCreatorActionType
    |   LambdaSetBounty                   of setBountyActionType
    |   LambdaTogglePauseBounty           of togglePauseBountyActionType
    |   LambdaApproveOrReject             of approveOrRejectActionType
    |   LambdaReviewBounty                of reviewBountyActionType
    |   LambdaSendBountyReward            of sendBountyRewardActionType
        
        // Group Lambdas
    |   LambdaFormGroup                   of formGroupActionType
    |   LambdaSetGroupMember              of setGroupMemberActionType
    |   LambdaGroupMembership             of groupMembershipActionType
    |   LambdaLeaveGroup                  of leaveGroupActionType

        // Bounty Lambdas
    |   LambdaApplyForBounty              of applyForBountyActionType
    |   LambdaCancelApplication           of cancelApplicationActionType
    |   LambdaCompleteBounty              of completeBountyActionType
    |   LambdaStopBounty                  of stopBountyActionType
    

// ------------------------------------------------------------------------------
// Storage
// ------------------------------------------------------------------------------


type bountyStorageType is [@layout:comb] record [
    
    superAdmin                : address;
    newSuperAdmin             : option(address);
    admins                    : set(address);

    metadata                  : metadataType;
    config                    : bountyConfigType;

    nextBountyId              : nat;
    nextGroupId               : nat;

    bountyCreators            : bountyCreatorsLedgerType;    
    bountyLedger              : bountyLedgerType;
    applicationLedger         : applicationLedgerType;
    groupLedger               : groupLedgerType;
    userLedger                : userLedgerType;

    lambdaLedger              : lambdaLedgerType;
]

