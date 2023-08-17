// ------------------------------------------------------------------------------
// Storage Types
// ------------------------------------------------------------------------------

type bountyIdType is nat

type bountyBreakGlassConfigType is [@layout:comb] record [
    setBountyIsPaused               : bool;
    togglePauseBountyIsPaused       : bool;
    approveOrRejectIsPaused         : bool;
    reviewBountyIsPaused            : bool;
    sendBountyRewardIsPaused        : bool;
    
    applyForBountyIsPaused          : bool;
    cancelApplicationIsPaused       : bool;
    completeBountyIsPaused          : bool;
    stopBountyIsPaused              : bool;
]

type bountyConfigType is [@layout:comb] record [
    maxActiveBounties       : nat;
    maxApplications         : nat;
];


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

type currentApprovedApplicantsType is map(address, bountyProgressType)

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
    completedApplicants         : set(address);

    milestones                  : option(milestonesType); 
    totalRewards                : rewardsType;     // total rewards per applicant if everything is completed successfully - will be used as reference for total rewards if milestones are set (i.e. milestone rewards take precedence)
]
type bountyLedgerType is big_map(bountyIdType, bountyRecordType)



type milestoneLogRecordType is [@layout:comb] record [
    status               : string;               // PENDING / APPROVED / REJECTED / COMPLETED / REVIEW_PENDING / REVIEW_APPROVED / REVIEW_DISPUTED / REVIEW_REJECTED / REWARDED
    completed            : bool;                 // to be set by applicant
    reviewed             : bool;                 // to be reviewed by bounty creator
    review               : option(string);       // to be set by bounty creator

    rewarded             : bool;                 // to be rewarded by bounty creator
    rewardTimestamp      : option(timestamp);
]
type milestoneLogType is map(nat, milestoneLogRecordType)


type applicantRecordType is [@layout:comb] record [
    status               : string;               // PENDING / APPROVED / REJECTED / CANCELED / STOPPED / REVIEW_PENDING / REVIEW_APPROVED / REVIEW_DISPUTED / REVIEW_REJECTED / REWARDED
    completed            : bool;                 // set to True by applicant (e.g. when all milestones are completed)
    reviewed             : bool;                 // to be reviewed by bounty creator
    review               : option(string);       // to be set by bounty creator
    
    currentMilestone     : option(nat);          // milestone counter for bounty if exists
    milestoneLog         : option(milestoneLogType);
    
    fullyRewarded        : bool;
    lastRewardTimestamp  : option(timestamp);
]
type applicantLedgerType is big_map((bountyIdType * address), applicantRecordType)


type userRecordType is [@layout:comb] record [
    activeBountyCount           : nat; 
    activeBounties              : set(nat);
    currentApplicationCount     : nat;
    appliedBounties             : set(nat);
]
type userLedgerType is big_map(address, userRecordType)


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
    applicant   : address;
    approval    : approvalType;
]


type reviewBountyActionType is [@layout:comb] record [
    bountyId            : nat;
    applicant           : address;
    status              : string;
    milestoneReview     : option(string);
    bountyReview        : option(string);
]


type sendBountyRewardActionType is [@layout:comb] record [
    bountyId     : nat;
    milestoneId  : option(nat);
    applicants   : set(address);
]


type applyForBountyActionType is nat        // bountyId
type completeBountyActionType is nat        // bountyId
type cancelApplicationActionType is nat     // bountyId
type stopBountyActionType is nat            // bountyId

type bountyUpdateConfigNewValueType is nat
type bountyUpdateConfigActionType is 
        ConfigMaxActiveBounties     of unit
    |   ConfigMaxApplications       of unit

type bountyUpdateConfigParamsType is [@layout:comb] record [
    updateConfigNewValue    : bountyUpdateConfigNewValueType; 
    updateConfigAction      : bountyUpdateConfigActionType;
]

type bountyPausableEntrypointType is
        SetBounty                of bool
    |   TogglePauseBounty        of bool
    |   ApproveOrReject          of bool
    |   ReviewBounty             of bool
    |   SendBountyReward         of bool
    |   ApplyForBounty           of bool
    |   CancelApplication        of bool
    |   CompleteBounty           of bool
    |   StopBounty               of bool
    
type bountyTogglePauseEntrypointType is [@layout:comb] record [
    targetEntrypoint  : bountyPausableEntrypointType;
    empty             : unit
];


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
    |   LambdaUpdateWhitelistContracts    of updateWhitelistContractsType
    |   LambdaUpdateGeneralContracts      of updateGeneralContractsType
    |   LambdaMistakenTransfer            of transferActionType

        // Pause / Break Glass Lambdas
    |   LambdaPauseAll                    of (unit)
    |   LambdaUnpauseAll                  of (unit)
    |   LambdaTogglePauseEntrypoint       of bountyTogglePauseEntrypointType

        // Bounty Admin Lambdas
    |   LambdaSetBountyCreator            of setBountyCreatorActionType
    |   LambdaSetBounty                   of setBountyActionType
    |   LambdaTogglePauseBounty           of togglePauseBountyActionType
    |   LambdaApproveOrReject             of approveOrRejectActionType
    |   LambdaReviewBounty                of reviewBountyActionType
    |   LambdaSendBountyReward            of sendBountyRewardActionType
        
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
    breakGlassConfig          : bountyBreakGlassConfigType;

    whitelistContracts        : whitelistContractsType;    
    generalContracts          : generalContractsType;

    nextBountyId              : nat;

    bountyCreators            : bountyCreatorsLedgerType;    
    bountyLedger              : bountyLedgerType;
    applicantLedger           : applicantLedgerType;
    userLedger                : userLedgerType;

    lambdaLedger              : lambdaLedgerType;
]

