import { UnitValue } from '@taquito/taquito'
import { MichelsonMap } from "@taquito/michelson-encoder"
import { Utils } from './helpers/Utils'

const chai = require('chai')
const assert = require('chai').assert
const chaiAsPromised = require('chai-as-promised')
chai.use(chaiAsPromised)
chai.should()

// ------------------------------------------------------------------------------
// Contract Address
// ------------------------------------------------------------------------------

import contractDeployments from './contractDeployments.json'

// ------------------------------------------------------------------------------
// Contract Helpers
// ------------------------------------------------------------------------------

import { bob, alice, eve, mallory } from '../scripts/sandbox/accounts'

import { 
    mockBountyRewards, 
    mockBountyRewardAmounts,
    mockMilestones, 
    mockMilestoneGroups 
} from "./helpers/mockSampleData"

import { 
    signerFactory, 
    getStorageMapValue,
    updateOperators,
    mapsAreEqual
} from './helpers/helperFunctions'


// ------------------------------------------------------------------------------
// Contract Notes
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Contract Tests
// ------------------------------------------------------------------------------

describe('Test: Bounty Contract', async () => {

    // default
    let utils: Utils
    let tezos

    let emptyArray = [] 

    // config
    let maxActiveBounties
    let maxApplications

    // misc defaults
    let tokenId = "0"
    let tokenAmount
    let tokenDecimals
    let operator
    let operatorKey

    // reference bounties
    let emptyBountyId
    let bountyWithOneMilestoneId
    let bountyWithTwoMilestonesId
    let bountyWithThreeMilestonesId

    // contract instances 
    let bountyAddress
    let bountyInstance
    let bountyStorage
    
    let mockFa12TokenAddress 
    let mockFa12TokenInstance
    let mockFa12TokenStorage

    let mockFa2TokenAddress 
    let mockFa2TokenInstance
    let mockFa2TokenStorage

    // user accounts
    let user
    let userSk

    let admin 
    let adminSk 

    let superAdmin 
    let superAdminSk

    let sender
    let receiver 

    // contract map value
    let storageMap
    let contractMapKey
    let initialContractMapValue
    let updatedContractMapValue

    // operations
    let transferOperation
    let mistakenTransferOperation
    let approveOperation
    let updateOperatorsOperation
    let removeOperatorsOperation
    let setAdminOperation
    let resetAdminOperation
    let updateWhitelistContractsOperation
    let updateGeneralContractsOperation

    before('setup', async () => {
        
        utils = new Utils()
        await utils.init(bob.sk)
        tezos = utils.tezos;

        superAdmin      = bob.pkh
        superAdminSk    = bob.sk 

        admin           = eve.pkh 
        adminSk         = eve.sk 

        tokenDecimals   = 6;

        bountyAddress                   = contractDeployments.bounty.address
        bountyInstance                  = await utils.tezos.contract.at(bountyAddress)
        bountyStorage                   = await bountyInstance.storage()

        mockFa12TokenAddress            = contractDeployments.mockFa12Token.address;
        mockFa12TokenInstance           = await utils.tezos.contract.at(mockFa12TokenAddress)
        mockFa12TokenStorage            = await mockFa12TokenInstance.storage()

        mockFa2TokenAddress             = contractDeployments.mockFa2Token.address;
        mockFa2TokenInstance            = await utils.tezos.contract.at(mockFa2TokenAddress);
        mockFa2TokenStorage             = await mockFa2TokenInstance.storage()

        console.log('-- -- -- -- -- -- -- -- -- -- -- -- --')

        // bounty config 
        maxActiveBounties = bountyStorage.config.maxActiveBounties;
        maxApplications   = bountyStorage.config.maxApplications;

        // reset state if required
        const bountyCreator = alice.pkh;
        const updateType    = "remove";
        storageMap          = "bountyCreators";

        initialContractMapValue = await getStorageMapValue(bountyStorage, storageMap, bountyCreator);
        
        // remove alice as bounty creator 
        if(initialContractMapValue !== undefined){
            const updateBountyCreatorOperation  = await bountyInstance.methods.setBountyCreator(bountyCreator, updateType).send();
            await updateBountyCreatorOperation.confirmation();

            bountyStorage = await bountyInstance.storage();
            updatedContractMapValue = await getStorageMapValue(bountyStorage, storageMap, bountyCreator);
            assert.strictEqual(updatedContractMapValue, undefined,  'Alice (key) should not be in the Bounty Creators map after removing her')
        }

    })

    
    beforeEach('storage', async () => {
        bountyStorage            = await bountyInstance.storage()
    })


    describe('%setBountyCreator', function () {
        
        beforeEach("Set signer to admin (eve)", async () => {
            bountyStorage = await bountyInstance.storage()
            await signerFactory(tezos, adminSk);
        });

        it('superAdmin (bob) should be able to set bounty creator (alice)', async () => {
            try {
                
                await signerFactory(tezos, superAdminSk);
                const bountyCreator = alice.pkh;
                const updateType    = "setNewBountyCreator";
                storageMap          = "bountyCreators";

                initialContractMapValue = await getStorageMapValue(bountyStorage, storageMap, bountyCreator);
                assert.strictEqual(initialContractMapValue, undefined, 'Alice (key) should not be in the Bounty Creators map')
                
                const updateBountyCreatorOperation  = await bountyInstance.methods.setBountyCreator(bountyCreator, updateType).send();
                await updateBountyCreatorOperation.confirmation();

                bountyStorage = await bountyInstance.storage();
                updatedContractMapValue = await getStorageMapValue(bountyStorage, storageMap, bountyCreator);
                assert.notStrictEqual(updatedContractMapValue, undefined,  'Alice (key) should be in the Bounty Creators map')

            } catch (e) {
                console.log(e)
            }
        })

        it('superAdmin (bob) should be able to remove bounty creator (alice)', async () => {
            try {
                
                await signerFactory(tezos, superAdminSk);
                const bountyCreator = alice.pkh;
                const updateType    = "remove";
                storageMap          = "bountyCreators";

                initialContractMapValue = await getStorageMapValue(bountyStorage, storageMap, bountyCreator);
                assert.notStrictEqual(initialContractMapValue, undefined, 'Alice (key) should be in the Bounty Creators map')
                
                const updateBountyCreatorOperation  = await bountyInstance.methods.setBountyCreator(bountyCreator, updateType).send();
                await updateBountyCreatorOperation.confirmation();

                bountyStorage = await bountyInstance.storage();
                updatedContractMapValue = await getStorageMapValue(bountyStorage, storageMap, bountyCreator);
                assert.strictEqual(updatedContractMapValue, undefined,  'Alice (key) should not be in the Bounty Creators map')

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should be able to set bounty creator (alice)', async () => {
            try {
                
                const bountyCreator = alice.pkh;
                const updateType    = "update";
                storageMap          = "bountyCreators";

                initialContractMapValue = await getStorageMapValue(bountyStorage, storageMap, bountyCreator);
                assert.strictEqual(initialContractMapValue, undefined, 'Alice (key) should not be in the Bounty Creators map')
                
                const updateBountyCreatorOperation  = await bountyInstance.methods.setBountyCreator(bountyCreator, updateType).send();
                await updateBountyCreatorOperation.confirmation();

                bountyStorage = await bountyInstance.storage();
                updatedContractMapValue = await getStorageMapValue(bountyStorage, storageMap, bountyCreator);
                assert.notStrictEqual(updatedContractMapValue, undefined,  'Alice (key) should be in the Bounty Creators map')

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should be able to remove bounty creator (alice)', async () => {
            try {
                
                const bountyCreator = alice.pkh;
                const updateType    = "remove";
                storageMap          = "bountyCreators";

                initialContractMapValue = await getStorageMapValue(bountyStorage, storageMap, bountyCreator);
                assert.notStrictEqual(initialContractMapValue, undefined, 'Alice (key) should be in the Bounty Creators map')
                
                const updateBountyCreatorOperation  = await bountyInstance.methods.setBountyCreator(bountyCreator, updateType).send();
                await updateBountyCreatorOperation.confirmation();

                bountyStorage = await bountyInstance.storage();
                updatedContractMapValue = await getStorageMapValue(bountyStorage, storageMap, bountyCreator);
                assert.strictEqual(updatedContractMapValue, undefined,  'Alice (key) should not be in the Bounty Creators map')

            } catch (e) {
                console.log(e)
            }
        })

    })

    describe('%setBounty - createBounty', function () {
        
        before("Set Alice as Bounty Creator", async() => {
            
            await signerFactory(tezos, adminSk);
            const bountyCreator = alice.pkh;
            const updateType    = "update";
            storageMap          = "bountyCreators";

            initialContractMapValue = await getStorageMapValue(bountyStorage, storageMap, bountyCreator);
            
            // set alice as bounty creator 
            if(initialContractMapValue == undefined){
                const updateBountyCreatorOperation  = await bountyInstance.methods.setBountyCreator(bountyCreator, updateType).send();
                await updateBountyCreatorOperation.confirmation();

                bountyStorage = await bountyInstance.storage();
                updatedContractMapValue = await getStorageMapValue(bountyStorage, storageMap, bountyCreator);
                assert.notStrictEqual(updatedContractMapValue, undefined,  'Alice (key) should be in the Bounty Creators map')
            }
        })

        beforeEach("Set signer to admin (eve)", async () => {
            bountyStorage = await bountyInstance.storage()
            await signerFactory(tezos, adminSk);
        });

        it('admin (eve) should be able to create a new bounty (inactive with no whitelisted, no image, no milestones, and no rewards)', async () => {
            try {
                
                const user                  = admin;
                const bountyId              = bountyStorage.nextBountyId;
                // set empty bounty for tests below
                emptyBountyId               = bountyId;

                const setBountyType         = "createBounty";
                const whitelisted           = null;
                const name                  = "Bounty 1 Name";
                const description           = "Bounty 1 Desc (inactive with no whitelisted, no image, no milestones, and no rewards)";
                const image                 = null;
                const status                = "INACTIVE";
                const maxApprovedApplicants = 2;
                const milestones            = null;
                const totalRewards : any    = new MichelsonMap();

                const createBountyOperation  = await bountyInstance.methods.setBounty(
                    setBountyType, 
                    whitelisted,
                    name,
                    description,
                    image,
                    status,
                    maxApprovedApplicants,
                    milestones,
                    totalRewards
                ).send();
                await createBountyOperation.confirmation();

                bountyStorage = await bountyInstance.storage();

                const bountyRecord  = await bountyStorage.bountyLedger.get(bountyId);

                // check record values
                assert.equal(bountyRecord.creator               , user);
                assert.equal(bountyRecord.name                  , name);
                assert.equal(bountyRecord.description           , description);
                assert.equal(bountyRecord.image                 , image);
                assert.equal(bountyRecord.status                , status);
                assert.equal(bountyRecord.maxApprovedApplicants , maxApprovedApplicants);
                assert.equal(bountyRecord.milestones            , milestones);

                // check maps and arrays
                assert.deepEqual(bountyRecord.whitelisted           , emptyArray);
                assert.deepEqual(bountyRecord.totalRewards.valueMap , totalRewards.valueMap);

                // check auto set variables
                assert.equal(bountyRecord.isPaused                  , false);
                assert.deepEqual(bountyRecord.completedApplicants   , emptyArray);
                if(milestones == null){
                    assert.equal(bountyRecord.hasMilestones         , false);
                } else {
                    assert.equal(bountyRecord.hasMilestones         , true);
                }

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should be able to create a new bounty (active with whitelisted, image, 1 milestone, and rewards)', async () => {
            try {
                
                const user                  = admin;
                const bountyId              = bountyStorage.nextBountyId;
                
                // set bounty for tests below
                bountyWithOneMilestoneId    = bountyId;

                const setBountyType         = "createBounty";
                const whitelisted           = [bob.pkh, alice.pkh, eve.pkh];
                const name                  = "Bounty 2 Name";
                const description           = "Bounty 2 Desc (active with whitelisted, image, 1 milestone, and rewards)";
                const image                 = "Bounty 2 image IPFS link";
                const status                = "ACTIVE";
                const maxApprovedApplicants = 2;
                const milestones : any      = mockMilestoneGroups.milestoneGroupOne;
                const totalRewards : any    = mockBountyRewards.bountyOneReward;

                const mutezRewards          = maxApprovedApplicants * mockBountyRewardAmounts.bountyOneReward.tez;
                const mockFa12TokenRewards  = maxApprovedApplicants * mockBountyRewardAmounts.bountyOneReward.mockFa12;

                // update operators operation to transfer mock FA2 tokens
                updateOperatorsOperation = await updateOperators(mockFa2TokenInstance, user, bountyAddress, tokenId);
                await updateOperatorsOperation.confirmation();

                // approve operation to transfer mock FA12 tokens
                approveOperation = await mockFa12TokenInstance.methods.approve(bountyAddress, 0).send();
                await approveOperation.confirmation();

                approveOperation = await mockFa12TokenInstance.methods.approve(bountyAddress, mockFa12TokenRewards).send();
                await approveOperation.confirmation();
                
                const createBountyOperation  = await bountyInstance.methods.setBounty(
                    setBountyType, 
                    whitelisted,
                    name,
                    description,
                    image,
                    status,
                    maxApprovedApplicants,
                    milestones,
                    totalRewards
                ).send({ mutez: true, amount : mutezRewards});
                await createBountyOperation.confirmation();

                bountyStorage = await bountyInstance.storage();

                const bountyRecord = await bountyStorage.bountyLedger.get(bountyId);
                
                // check record values
                assert.equal(bountyRecord.creator               , user);
                assert.equal(bountyRecord.name                  , name);
                assert.equal(bountyRecord.description           , description);
                assert.equal(bountyRecord.image                 , image);
                assert.equal(bountyRecord.status                , status);
                assert.equal(bountyRecord.maxApprovedApplicants , maxApprovedApplicants);

                // check maps and arrays
                assert.deepEqual(bountyRecord.whitelisted                   , whitelisted);
                assert.equal(mapsAreEqual(bountyRecord.totalRewards.valueMap, totalRewards.valueMap), true);
                assert.equal(mapsAreEqual(bountyRecord.milestones.valueMap  , milestones.valueMap), true);

                // check auto set variables
                assert.equal(bountyRecord.isPaused                  , false);
                assert.deepEqual(bountyRecord.completedApplicants   , emptyArray);
                if(milestones == null){
                    assert.equal(bountyRecord.hasMilestones         , false);
                } else {
                    assert.equal(bountyRecord.hasMilestones         , true);
                }

            } catch (e) {
                console.log(e)
            }
        })

        it('bounty creator (alice) should be able to create a new bounty (inactive with whitelisted, image, 2 milestones, and rewards)', async () => {
            try {
                
                // set signer to bounty creator (alice)
                await signerFactory(tezos, alice.sk);

                const user                  = alice.pkh;
                const bountyId              = bountyStorage.nextBountyId;
                
                // set bounty for tests below
                bountyWithThreeMilestonesId   = bountyId;

                const setBountyType         = "createBounty";
                const whitelisted           = [bob.pkh, alice.pkh, eve.pkh];
                const name                  = "Bounty 3 Name";
                const description           = "Bounty 3 Desc (inactive with whitelisted, image, 2 milestones, and rewards)";
                const image                 = "Bounty 3 image IPFS link";
                const status                = "INACTIVE";
                const maxApprovedApplicants = 2;
                const milestones : any      = mockMilestoneGroups.milestoneGroupTwo;
                const totalRewards : any    = mockBountyRewards.bountyTwoReward;

                const mutezRewards          = maxApprovedApplicants * mockBountyRewardAmounts.bountyTwoReward.tez;
                const mockFa12TokenRewards  = maxApprovedApplicants * mockBountyRewardAmounts.bountyTwoReward.mockFa12;

                // update operators operation to transfer mock FA2 tokens
                updateOperatorsOperation = await updateOperators(mockFa2TokenInstance, user, bountyAddress, tokenId);
                await updateOperatorsOperation.confirmation();

                // approve operation to transfer mock FA12 tokens
                approveOperation = await mockFa12TokenInstance.methods.approve(bountyAddress, 0).send();
                await approveOperation.confirmation();

                approveOperation = await mockFa12TokenInstance.methods.approve(bountyAddress, mockFa12TokenRewards).send();
                await approveOperation.confirmation();
                
                const createBountyOperation  = await bountyInstance.methods.setBounty(
                    setBountyType, 
                    whitelisted,
                    name,
                    description,
                    image,
                    status,
                    maxApprovedApplicants,
                    milestones,
                    totalRewards
                ).send({ mutez: true, amount : mutezRewards});
                await createBountyOperation.confirmation();

                bountyStorage = await bountyInstance.storage();

                const bountyRecord = await bountyStorage.bountyLedger.get(bountyId);
                
                // check record values
                assert.equal(bountyRecord.creator               , user);
                assert.equal(bountyRecord.name                  , name);
                assert.equal(bountyRecord.description           , description);
                assert.equal(bountyRecord.image                 , image);
                assert.equal(bountyRecord.status                , status);
                assert.equal(bountyRecord.maxApprovedApplicants , maxApprovedApplicants);

                // check maps and arrays
                assert.deepEqual(bountyRecord.whitelisted                   , whitelisted);
                assert.equal(mapsAreEqual(bountyRecord.totalRewards.valueMap, totalRewards.valueMap), true);
                assert.equal(mapsAreEqual(bountyRecord.milestones.valueMap  , milestones.valueMap), true);

                // check auto set variables
                assert.equal(bountyRecord.isPaused                  , false);
                assert.deepEqual(bountyRecord.completedApplicants   , emptyArray);
                if(milestones == null){
                    assert.equal(bountyRecord.hasMilestones         , false);
                } else {
                    assert.equal(bountyRecord.hasMilestones         , true);
                }

            } catch (e) {
                console.log(e)
            }
        })


        it('bounty creator (alice) should be able to create a new bounty (active with whitelisted, image, 3 milestones, and rewards)', async () => {
            try {
                
                // set signer to bounty creator (alice)
                await signerFactory(tezos, alice.sk);

                const user                  = alice.pkh;
                const bountyId              = bountyStorage.nextBountyId;
                
                // set bounty for tests below
                bountyWithThreeMilestonesId = bountyId;

                const setBountyType         = "createBounty";
                const whitelisted           = [bob.pkh, alice.pkh, eve.pkh];
                const name                  = "Bounty 4 Name";
                const description           = "Bounty 4 Desc (inactive with whitelisted, image, 3 milestones, and rewards)";
                const image                 = "Bounty 4 image IPFS link";
                const status                = "ACTIVE";
                const maxApprovedApplicants = 2;
                const milestones : any      = mockMilestoneGroups.milestoneGroupThree;
                const totalRewards : any    = mockBountyRewards.bountyThreeReward;

                const mutezRewards          = maxApprovedApplicants * mockBountyRewardAmounts.bountyThreeReward.tez;
                const mockFa12TokenRewards  = maxApprovedApplicants * mockBountyRewardAmounts.bountyThreeReward.mockFa12;

                // update operators operation to transfer mock FA2 tokens
                updateOperatorsOperation = await updateOperators(mockFa2TokenInstance, user, bountyAddress, tokenId);
                await updateOperatorsOperation.confirmation();

                // approve operation to transfer mock FA12 tokens
                approveOperation = await mockFa12TokenInstance.methods.approve(bountyAddress, 0).send();
                await approveOperation.confirmation();

                approveOperation = await mockFa12TokenInstance.methods.approve(bountyAddress, mockFa12TokenRewards).send();
                await approveOperation.confirmation();
                
                const createBountyOperation  = await bountyInstance.methods.setBounty(
                    setBountyType, 
                    whitelisted,
                    name,
                    description,
                    image,
                    status,
                    maxApprovedApplicants,
                    milestones,
                    totalRewards
                ).send({ mutez: true, amount : mutezRewards});
                await createBountyOperation.confirmation();

                bountyStorage = await bountyInstance.storage();

                const bountyRecord = await bountyStorage.bountyLedger.get(bountyId);
                
                // check record values
                assert.equal(bountyRecord.creator               , user);
                assert.equal(bountyRecord.name                  , name);
                assert.equal(bountyRecord.description           , description);
                assert.equal(bountyRecord.image                 , image);
                assert.equal(bountyRecord.status                , status);
                assert.equal(bountyRecord.maxApprovedApplicants , maxApprovedApplicants);

                // check maps and arrays
                assert.deepEqual(bountyRecord.whitelisted                   , whitelisted);
                assert.equal(mapsAreEqual(bountyRecord.totalRewards.valueMap, totalRewards.valueMap), true);
                assert.equal(mapsAreEqual(bountyRecord.milestones.valueMap  , milestones.valueMap), true);

                // check auto set variables
                assert.equal(bountyRecord.isPaused                  , false);
                assert.deepEqual(bountyRecord.completedApplicants   , emptyArray);
                if(milestones == null){
                    assert.equal(bountyRecord.hasMilestones         , false);
                } else {
                    assert.equal(bountyRecord.hasMilestones         , true);
                }

            } catch (e) {
                console.log(e)
            }
        })

    })

    describe('%applyForBounty', function () {
        
        beforeEach("Set signer to user (mallory)", async () => {
            bountyStorage = await bountyInstance.storage()
            user    = mallory.pkh;
            userSk  = mallory.sk;
            await signerFactory(tezos, userSk);
        });

        it('user (mallory) can apply to a bounty', async () => {
            try {

                const bountyId                      = bountyWithOneMilestoneId

                const initialUserRecord              = await bountyStorage.userLedger.get(user);
                const initialActiveBountyCount       = initialUserRecord == undefined ? 0 : initialUserRecord.activeBountyCount.toNumber();
                const initialCurrentApplicationCount = initialUserRecord == undefined ? 0 : initialUserRecord.currentApplicationCount.toNumber();
                
                const applyForBountyOperation = await bountyInstance.methods.applyForBounty(
                    bountyId
                ).send();
                await applyForBountyOperation.confirmation();

                bountyStorage = await bountyInstance.storage();

                const applicantRecord = await bountyStorage.applicantLedger.get([bountyId, user]);
                const userRecord      = await bountyStorage.userLedger.get(user);
                const appliedBounties = userRecord.appliedBounties.map(b => b.toNumber());
                const activeBounties  = userRecord.activeBounties.map(b => b.toNumber());

                // check applicant record
                assert.equal(applicantRecord.status             , 'PENDING');
                assert.equal(applicantRecord.completed          , false);
                assert.equal(applicantRecord.reviewed           , false);
                assert.equal(applicantRecord.review             , null);
                assert.equal(applicantRecord.currentMilestone   , null);
                assert.equal(applicantRecord.milestoneLog       , null);
                assert.equal(applicantRecord.fullyRewarded      , false);
                assert.equal(applicantRecord.lastRewardTimestamp, null);

                // check user record
                assert.equal(userRecord.activeBountyCount.toNumber()        , initialActiveBountyCount);
                assert.equal(userRecord.currentApplicationCount.toNumber()  , initialCurrentApplicationCount + 1);
                assert.equal(appliedBounties.includes(bountyId.toNumber())  , true);
                assert.equal(activeBounties.includes(bountyId.toNumber())   , false);

            } catch (e) {
                console.log(e)
            }
        })

        it('user (mallory) can apply to multiple bounties', async () => {
            try {

                const bountyId                      = bountyWithOneMilestoneId

                const initialUserRecord              = await bountyStorage.userLedger.get(user);
                const initialActiveBountyCount       = initialUserRecord == undefined ? 0 : initialUserRecord.activeBountyCount.toNumber();
                const initialCurrentApplicationCount = initialUserRecord == undefined ? 0 : initialUserRecord.currentApplicationCount.toNumber();
                
                const applyForBountyOperation = await bountyInstance.methods.applyForBounty(
                    bountyId
                ).send();
                await applyForBountyOperation.confirmation();

                bountyStorage = await bountyInstance.storage();

                const applicantRecord = await bountyStorage.applicantLedger.get([bountyId, user]);
                const userRecord      = await bountyStorage.userLedger.get(user);
                const appliedBounties = userRecord.appliedBounties.map(b => b.toNumber());
                const activeBounties  = userRecord.activeBounties.map(b => b.toNumber());

                // check applicant record
                assert.equal(applicantRecord.status             , 'PENDING');
                assert.equal(applicantRecord.completed          , false);
                assert.equal(applicantRecord.reviewed           , false);
                assert.equal(applicantRecord.review             , null);
                assert.equal(applicantRecord.currentMilestone   , null);
                assert.equal(applicantRecord.milestoneLog       , null);
                assert.equal(applicantRecord.fullyRewarded      , false);
                assert.equal(applicantRecord.lastRewardTimestamp, null);

                // check user record
                assert.equal(userRecord.activeBountyCount.toNumber()        , initialActiveBountyCount);
                assert.equal(userRecord.currentApplicationCount.toNumber()  , initialCurrentApplicationCount + 1);
                assert.equal(appliedBounties.includes(bountyId.toNumber())  , true);
                assert.equal(activeBounties.includes(bountyId.toNumber())   , false);

            } catch (e) {
                console.log(e)
            }
        })

    })
    
})
