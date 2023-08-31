import { MichelsonMap } from "@taquito/michelson-encoder";
import { mock } from 'node:test';

import { alice, bob, eve, ivan, mallory, oscar, susie, trudy } from "../../scripts/sandbox/accounts";
// ------------------------------------------------------------------------------
// Contract Address
// ------------------------------------------------------------------------------

import contractDeployments from './../contractDeployments.json'

export const mvkTokenDecimals = 9

let mockFa12TokenAddress 
let mockFa2TokenAddress 

mockFa12TokenAddress  = contractDeployments.mockFa12Token.address;
mockFa2TokenAddress   = contractDeployments.mockFa2Token.address;

// ------------------------------------------------------------------------------
// Mock Data
// ------------------------------------------------------------------------------


// ------------------------------------
// Bounty and Milestone Rewards
// ------------------------------------

// Note on Bounty and Milestone Rewards:
// ---------------
// BountyOneReward   tallies with MilestoneGroupOneReward total
// BountyTwoReward   tallies with MilestoneGroupTwoReward total 
// BountyThreeReward tallies with MilestoneGroupThreeReward total


export const mockMilestoneRewardAmounts = {

    'milestoneGroupOne' : {
        'milestoneOneReward': {
            'tez'       : 1000000,
            'mockFa12'  : 1000000,
            'mockFa2'   : 1000000
        }
    },


    'milestoneGroupTwo' : {
        'milestoneOneReward': {
            'tez'       : 1000000,
            'mockFa12'  : 1000000,
            'mockFa2'   : 1000000
        },
    
        'milestoneTwoReward': {
            'tez'       : 2000000,
            'mockFa12'  : 2000000,
            'mockFa2'   : 2000000
        }
    },


    'milestoneGroupThree' : {
        'milestoneOneReward': {
            'tez'       : 1000000,
            'mockFa12'  : 1000000,
            'mockFa2'   : 1000000
        },
    
        'milestoneTwoReward': {
            'tez'       : 2000000,
            'mockFa12'  : 2000000,
            'mockFa2'   : 2000000
        },

        'milestoneThreeReward': {
            'tez'       : 3000000,
            'mockFa12'  : 3000000,
            'mockFa2'   : 3000000
        }
    }

}


export const mockBountyRewardAmounts = {

    'bountyOneReward': {
        'tez'       : mockMilestoneRewardAmounts.milestoneGroupOne.milestoneOneReward.tez ,
        'mockFa12'  : mockMilestoneRewardAmounts.milestoneGroupOne.milestoneOneReward.mockFa12,
        'mockFa2'   : mockMilestoneRewardAmounts.milestoneGroupOne.milestoneOneReward.mockFa2
    },


    'bountyTwoReward': {
        'tez'       : mockMilestoneRewardAmounts.milestoneGroupTwo.milestoneOneReward.tez 
                      + mockMilestoneRewardAmounts.milestoneGroupTwo.milestoneTwoReward.tez,
        'mockFa12'  : mockMilestoneRewardAmounts.milestoneGroupTwo.milestoneOneReward.mockFa12 
                      + mockMilestoneRewardAmounts.milestoneGroupTwo.milestoneTwoReward.mockFa12,
        'mockFa2'   : mockMilestoneRewardAmounts.milestoneGroupTwo.milestoneOneReward.mockFa2 
                      + mockMilestoneRewardAmounts.milestoneGroupTwo.milestoneTwoReward.mockFa2,
    },


    'bountyThreeReward': {
        'tez'       : mockMilestoneRewardAmounts.milestoneGroupThree.milestoneOneReward.tez 
                      + mockMilestoneRewardAmounts.milestoneGroupThree.milestoneTwoReward.tez
                      + mockMilestoneRewardAmounts.milestoneGroupThree.milestoneThreeReward.tez,
        'mockFa12'  : mockMilestoneRewardAmounts.milestoneGroupThree.milestoneOneReward.mockFa12 
                      + mockMilestoneRewardAmounts.milestoneGroupThree.milestoneTwoReward.mockFa12
                      + mockMilestoneRewardAmounts.milestoneGroupThree.milestoneThreeReward.mockFa12,
        'mockFa2'   : mockMilestoneRewardAmounts.milestoneGroupThree.milestoneOneReward.mockFa2 
                      + mockMilestoneRewardAmounts.milestoneGroupThree.milestoneTwoReward.mockFa2
                      + mockMilestoneRewardAmounts.milestoneGroupThree.milestoneThreeReward.mockFa2,
    },
}


// ------------------------------------
// Reward Map Helper Function
// ------------------------------------


const DEFAULT_FA12_TOKEN_ADDRESS = mockFa12TokenAddress;
const DEFAULT_FA2_TOKEN_ADDRESS  = mockFa2TokenAddress;

function generateRewardMap(tezAmount, mockFa12Amount, mockFa2Amount, mockFa12TokenAddress = DEFAULT_FA12_TOKEN_ADDRESS, mockFa2TokenAddress = DEFAULT_FA2_TOKEN_ADDRESS) {
    
    let reward : any = {};

    if (mockFa12Amount && mockFa12Amount !== 0) {
        reward.mockFa12 = {
            amount: mockFa12Amount,
            rewardTokenType: {
                "fa12": mockFa12TokenAddress
            }
        };
    }

    if (mockFa2Amount && mockFa2Amount !== 0) {
        reward.mockFa2 = {
            amount: mockFa2Amount,
            rewardTokenType: {
                "fa2": {
                    tokenContractAddress: mockFa2TokenAddress,
                    tokenId: "0"
                }
            }
        };
    }

    if (tezAmount && tezAmount !== 0) {
        reward.tez = {
            amount: tezAmount,
            rewardTokenType: {
                "tez": null
            }
        };
    }

    return MichelsonMap.fromLiteral(reward);
}


// ------------------------------------
// Bounty Rewards
// ------------------------------------


export const mockBountyRewards = {

    'bountyOneReward' : generateRewardMap(
                            mockBountyRewardAmounts.bountyOneReward.tez,
                            mockBountyRewardAmounts.bountyOneReward.mockFa12,
                            mockBountyRewardAmounts.bountyOneReward.mockFa2,
                        ),

    'bountyTwoReward' : generateRewardMap(
                            mockBountyRewardAmounts.bountyTwoReward.tez,
                            mockBountyRewardAmounts.bountyTwoReward.mockFa12,
                            mockBountyRewardAmounts.bountyTwoReward.mockFa2,
                        ),

    'bountyThreeReward' : generateRewardMap(
                            mockBountyRewardAmounts.bountyThreeReward.tez,
                            mockBountyRewardAmounts.bountyThreeReward.mockFa12,
                            mockBountyRewardAmounts.bountyThreeReward.mockFa2,
                        )
}


// ------------------------------------
// Bounty Milestone Rewards
// ------------------------------------



// ------------------------------------
// Milestones
// ------------------------------------

export const mockMilestones = {

    'bountyOneMilestoneOne' : {
        name        : 'Bounty One Milestone One',
        description : 'Bounty One Milestone One Desc',
        image       : 'Bounty One Milestone One Image IPFS',
        rewards     : generateRewardMap(
                        mockMilestoneRewardAmounts.milestoneGroupOne.milestoneOneReward.tez,
                        mockMilestoneRewardAmounts.milestoneGroupOne.milestoneOneReward.mockFa12,
                        mockMilestoneRewardAmounts.milestoneGroupOne.milestoneOneReward.mockFa2
                    )
    }, 

    'bountyTwoMilestoneOne' : {
        name        : 'Bounty Two Milestone One',
        description : 'Bounty Two Milestone One Desc',
        image       : 'Bounty Two Milestone One Image IPFS',
        rewards     : generateRewardMap(
                        mockMilestoneRewardAmounts.milestoneGroupTwo.milestoneOneReward.tez,
                        mockMilestoneRewardAmounts.milestoneGroupTwo.milestoneOneReward.mockFa12,
                        mockMilestoneRewardAmounts.milestoneGroupTwo.milestoneOneReward.mockFa2
                    )
    }, 

    'bountyTwoMilestoneTwo' : {
        name        : 'Bounty Two Milestone Two',
        description : 'Bounty Two Milestone Two Desc',
        image       : 'Bounty Two Milestone Two Image IPFS',
        rewards     : generateRewardMap(
                        mockMilestoneRewardAmounts.milestoneGroupTwo.milestoneTwoReward.tez,
                        mockMilestoneRewardAmounts.milestoneGroupTwo.milestoneTwoReward.mockFa12,
                        mockMilestoneRewardAmounts.milestoneGroupTwo.milestoneTwoReward.mockFa2
                    )
    }, 

    'bountyThreeMilestoneOne' : {
        name        : 'Bounty Three Milestone One',
        description : 'Bounty Three Milestone One Desc',
        image       : 'Bounty Three Milestone One Image IPFS',
        rewards     : generateRewardMap(
                        mockMilestoneRewardAmounts.milestoneGroupThree.milestoneOneReward.tez,
                        mockMilestoneRewardAmounts.milestoneGroupThree.milestoneOneReward.mockFa12,
                        mockMilestoneRewardAmounts.milestoneGroupThree.milestoneOneReward.mockFa2
                    )
    }, 

    'bountyThreeMilestoneTwo' : {
        name        : 'Bounty Three Milestone Two',
        description : 'Bounty Three Milestone Two Desc',
        image       : 'Bounty Three Milestone Two Image IPFS',
        rewards     : generateRewardMap(
                        mockMilestoneRewardAmounts.milestoneGroupThree.milestoneTwoReward.tez,
                        mockMilestoneRewardAmounts.milestoneGroupThree.milestoneTwoReward.mockFa12,
                        mockMilestoneRewardAmounts.milestoneGroupThree.milestoneTwoReward.mockFa2
                    )
    }, 

    'bountyThreeMilestoneThree' : {
        name        : 'Bounty Three Milestone Three',
        description : 'Bounty Three Milestone Three Desc',
        image       : 'Bounty Three Milestone Three Image IPFS',
        rewards     : generateRewardMap(
                        mockMilestoneRewardAmounts.milestoneGroupThree.milestoneThreeReward.tez,
                        mockMilestoneRewardAmounts.milestoneGroupThree.milestoneThreeReward.mockFa12,
                        mockMilestoneRewardAmounts.milestoneGroupThree.milestoneThreeReward.mockFa2
                    )
    }
}


export const mockMilestoneGroups = {

    'milestoneGroupOne' : MichelsonMap.fromLiteral({
        1 : mockMilestones.bountyOneMilestoneOne
    }),

    'milestoneGroupTwo' : MichelsonMap.fromLiteral({
        1 : mockMilestones.bountyTwoMilestoneOne,
        2 : mockMilestones.bountyTwoMilestoneTwo
    }),

    'milestoneGroupThree' : MichelsonMap.fromLiteral({
        1 : mockMilestones.bountyThreeMilestoneOne,
        2 : mockMilestones.bountyThreeMilestoneTwo,
        3 : mockMilestones.bountyThreeMilestoneThree
    })
}