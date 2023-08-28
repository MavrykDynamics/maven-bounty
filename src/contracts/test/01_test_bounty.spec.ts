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

import { bob, alice, eve, mallory, oscar, trudy, isaac, david } from '../scripts/sandbox/accounts'

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
    mapsAreEqual,
    almostEqual
} from './helpers/helperFunctions'
import { group } from 'console'
import { sign } from 'crypto'


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
    let inactiveBountyId
    let bountyWithNoMilestonesId
    let bountyWithOneMilestoneId
    let bountyWithTwoMilestonesId
    let bountyWithThreeMilestonesId

    // reference groups
    let firstGroupId
    let secondGroupId
    let thirdGroupId

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

    let bountyCreator 
    let bountyCreatorSk 

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

        bountyCreator   = alice.pkh
        bountyCreatorSk = alice.sk

        user            = mallory.pkh;
        userSk          = mallory.sk;

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
        storageMap              = "bountyCreators";
        initialContractMapValue = await getStorageMapValue(bountyStorage, storageMap, bountyCreator);
        
        // remove alice as bounty creator 
        if(initialContractMapValue !== undefined){

            const updateType = "removeBountyCreator";
            const updateBountyCreatorOperation  = await bountyInstance.methods.setBountyCreator(updateType, bountyCreator).send();
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
                
                const updateBountyCreatorOperation  = await bountyInstance.methods.setBountyCreator(updateType, bountyCreator).send();
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
                const updateType    = "removeBountyCreator";
                storageMap          = "bountyCreators";

                initialContractMapValue = await getStorageMapValue(bountyStorage, storageMap, bountyCreator);
                assert.notStrictEqual(initialContractMapValue, undefined, 'Alice (key) should be in the Bounty Creators map')
                
                const updateBountyCreatorOperation  = await bountyInstance.methods.setBountyCreator(updateType, bountyCreator).send();
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
                const updateType    = "setNewBountyCreator";
                storageMap          = "bountyCreators";

                initialContractMapValue = await getStorageMapValue(bountyStorage, storageMap, bountyCreator);
                assert.strictEqual(initialContractMapValue, undefined, 'Alice (key) should not be in the Bounty Creators map')
                
                const updateBountyCreatorOperation  = await bountyInstance.methods.setBountyCreator(updateType, bountyCreator).send();
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
                const updateType    = "removeBountyCreator";
                storageMap          = "bountyCreators";

                initialContractMapValue = await getStorageMapValue(bountyStorage, storageMap, bountyCreator);
                assert.notStrictEqual(initialContractMapValue, undefined, 'Alice (key) should be in the Bounty Creators map')
                
                const updateBountyCreatorOperation  = await bountyInstance.methods.setBountyCreator(updateType, bountyCreator).send();
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
            const updateType    = "setNewBountyCreator";
            storageMap          = "bountyCreators";

            initialContractMapValue = await getStorageMapValue(bountyStorage, storageMap, bountyCreator);
            
            // set alice as bounty creator 
            if(initialContractMapValue == undefined){
                const updateBountyCreatorOperation  = await bountyInstance.methods.setBountyCreator(updateType, bountyCreator).send();
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
                inactiveBountyId            = bountyId;
                bountyWithTwoMilestonesId   = bountyId;

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

        it('bounty creator (alice) should be able to create a new bounty (active with whitelisted, image, 0 milestones, and rewards)', async () => {
            try {
                
                // set signer to bounty creator (alice)
                await signerFactory(tezos, alice.sk);

                const user                  = alice.pkh;
                const bountyId              = bountyStorage.nextBountyId;
                
                // set bounty for tests below
                bountyWithNoMilestonesId     = bountyId;

                const setBountyType         = "createBounty";
                const whitelisted           = [bob.pkh, alice.pkh, eve.pkh];
                const name                  = "Bounty 5 Name - no milestones";
                const description           = "Bounty 5 Desc (active with whitelisted, image, 0 milestones, and rewards)";
                const image                 = "Bounty 5 image IPFS link";
                const status                = "ACTIVE";
                const maxApprovedApplicants = 2;
                const milestones : any      = null;
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
                assert.equal(bountyRecord.milestones                        , null);

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


    describe(`
    -----------
    Group Membership test: `, function () {

        describe('%formGroup', function () {
            
            beforeEach("Set signer to user (mallory)", async () => {
                bountyStorage = await bountyInstance.storage()
                await signerFactory(tezos, userSk);
            });

            it('user (mallory) should be able to form a group (no name, desc, image provided)', async () => {
                try {

                    const groupId = bountyStorage.nextGroupId;
                    firstGroupId  = groupId;
                    
                    const formGroupOperation  = await bountyInstance.methods.formGroup().send();
                    await formGroupOperation.confirmation();

                    bountyStorage       = await bountyInstance.storage()
                    const groupRecord   = await bountyStorage.groupLedger.get(groupId);

                    assert.equal(groupRecord.creator, user);
                    assert.equal(groupRecord.status, "ACTIVE");
                    assert.equal(groupRecord.bountyInProgress, false);

                    assert.equal(groupRecord.name, null);
                    assert.equal(groupRecord.description, null);
                    assert.equal(groupRecord.image, null);

                    assert.equal(groupRecord.activeBountyCount, 0);
                    assert.equal(groupRecord.currentApplicationCount, 0);

                } catch (e) {
                    console.log(e)
                }
            })

            it('user (mallory) should be able to form a group (with name, desc, image provided)', async () => {
                try {

                    const groupId = bountyStorage.nextGroupId;
                    secondGroupId = groupId;

                    const name    = "New Group name 2"
                    const desc    = "New Group desc 2"
                    const image   = "Group image 2"
                    
                    const formGroupOperation  = await bountyInstance.methods.formGroup(
                        name,
                        desc,
                        image
                    ).send();
                    await formGroupOperation.confirmation();

                    bountyStorage       = await bountyInstance.storage()
                    const groupRecord   = await bountyStorage.groupLedger.get(groupId);

                    assert.equal(groupRecord.creator, user);
                    assert.equal(groupRecord.status, "ACTIVE");
                    assert.equal(groupRecord.bountyInProgress, false);

                    assert.equal(groupRecord.name           , name);
                    assert.equal(groupRecord.description    , desc);
                    assert.equal(groupRecord.image          , image);

                    assert.equal(groupRecord.activeBountyCount, 0);
                    assert.equal(groupRecord.currentApplicationCount, 0);

                } catch (e) {
                    console.log(e)
                }
            })

            it('user (mallory) should be able to form a group (with partial details: name, desc provided, image not provided)', async () => {
                try {

                    const groupId = bountyStorage.nextGroupId;
                    thirdGroupId  = groupId;

                    const name    = "New Group name 2"
                    const desc    = "New Group desc 2"
                    const image   = null;
                    
                    const formGroupOperation  = await bountyInstance.methods.formGroup(
                        name,
                        desc,
                        image
                    ).send();
                    await formGroupOperation.confirmation();

                    bountyStorage       = await bountyInstance.storage()
                    const groupRecord   = await bountyStorage.groupLedger.get(groupId);

                    assert.equal(groupRecord.creator, user);
                    assert.equal(groupRecord.status, "ACTIVE");
                    assert.equal(groupRecord.bountyInProgress, false);

                    assert.equal(groupRecord.name           , name);
                    assert.equal(groupRecord.description    , desc);
                    assert.equal(groupRecord.image          , image);

                    assert.equal(groupRecord.activeBountyCount, 0);
                    assert.equal(groupRecord.currentApplicationCount, 0);

                } catch (e) {
                    console.log(e)
                }
            })

        })


        describe('%setGroupMember - invite', function () {
            
            beforeEach("Set signer to group leader (mallory)", async () => {
                bountyStorage = await bountyInstance.storage()
                await signerFactory(tezos, userSk);
            });

            it('group leader (mallory) should be able to invite members to join his group (trudy, david)', async () => {
                try {

                    const groupId            = firstGroupId;
                    const setGroupMemberType = "invite";
                    
                    let inviteToGroupOperation  = await bountyInstance.methods.setGroupMember(
                        groupId,
                        trudy.pkh,
                        setGroupMemberType
                    ).send();
                    await inviteToGroupOperation.confirmation();

                    inviteToGroupOperation  = await bountyInstance.methods.setGroupMember(
                        groupId,
                        david.pkh,
                        setGroupMemberType
                    ).send();
                    await inviteToGroupOperation.confirmation();

                    bountyStorage           = await bountyInstance.storage()

                    const userRecord        = await bountyStorage.userLedger.get(trudy.pkh);
                    const groupInvites      = userRecord.groupInvites.map(b => b.toNumber());

                    const davidUserRecord   = await bountyStorage.userLedger.get(david.pkh);
                    const davidGroupInvites = davidUserRecord.groupInvites.map(b => b.toNumber());

                    assert.equal(groupInvites.includes(groupId.toNumber())     , true);
                    assert.equal(davidGroupInvites.includes(groupId.toNumber())     , true);

                } catch (e) {
                    console.log(e)
                }
            })

            it('non-group leader (eve) should not be able to invite members to join a group she did not create', async () => {
                try {

                    await signerFactory(tezos, eve.sk);

                    const groupId            = firstGroupId;
                    const setGroupMemberType = "invite";
                    
                    let failInviteToGroupOperation  = await bountyInstance.methods.setGroupMember(
                        groupId,
                        alice.pkh,
                        setGroupMemberType
                    );
                    await chai.expect(failInviteToGroupOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })
        
        })

        describe('%groupMembership - confirmGroupMembership', function () {

            it('user (trudy) should be able to confirm group membership after being invited to join', async () => {
                try {

                    const user = trudy.pkh;
                    await signerFactory(tezos, trudy.sk);

                    const groupId            = firstGroupId;
                    const groupMembershipType = "confirmGroupMembership";
                    
                    let confirmGroupMembershipOperation  = await bountyInstance.methods.groupMembership(
                        groupMembershipType,
                        groupId
                    ).send();
                    await confirmGroupMembershipOperation.confirmation();

                    const userRecord   = await bountyStorage.userLedger.get(user);
                    const groupInvites = userRecord.groupInvites.map(b => b.toNumber());
                    const groups       = userRecord.groups.map(b => b.toNumber());

                    assert.equal(groupInvites.includes(groupId.toNumber())     , false);
                    assert.equal(groups.includes(groupId.toNumber())           , true);

                } catch (e) {
                    console.log(e)
                }
            })

            it('user (david) should not be able to confirm group membership if he was not invited', async () => {
                try {

                    const user = david.pkh;
                    await signerFactory(tezos, david.sk);

                    const groupId             = secondGroupId;
                    const groupMembershipType = "confirmGroupMembership";
                    
                    let failConfirmGroupMembershipOperation  = await bountyInstance.methods.groupMembership(
                        groupMembershipType,
                        groupId
                    );
                    await chai.expect(failConfirmGroupMembershipOperation.send()).to.be.rejected;

                    const userRecord   = await bountyStorage.userLedger.get(user);
                    const groupInvites = userRecord.groupInvites.map(b => b.toNumber());
                    const groups       = userRecord.groups.map(b => b.toNumber());

                    assert.equal(groupInvites.includes(groupId.toNumber())     , false);
                    assert.equal(groups.includes(groupId.toNumber())           , false);

                } catch (e) {
                    console.log(e)
                }
            })

        })

        describe('%groupMembership - applyForGroup', function () {

            it('user (oscar) should be able to apply to group', async () => {
                try {

                    const user = oscar.pkh;
                    await signerFactory(tezos, oscar.sk);

                    const groupId             = firstGroupId;
                    const groupMembershipType = "applyForGroup";
                    
                    let confirmGroupMembershipOperation  = await bountyInstance.methods.groupMembership(
                        groupMembershipType,
                        groupId
                    ).send();
                    await confirmGroupMembershipOperation.confirmation();

                    bountyStorage = await bountyInstance.storage();

                    const userRecord           = await bountyStorage.userLedger.get(user);

                    const groupInvites         = userRecord.groupInvites.map(b => b.toNumber());
                    const groupApplications    = userRecord.groupApplications.map(b => b.toNumber());
                    const groups               = userRecord.groups.map(b => b.toNumber());

                    assert.equal(groupApplications.includes(groupId.toNumber())    , true);
                    assert.equal(groupInvites.includes(groupId.toNumber())         , false);
                    assert.equal(groups.includes(groupId.toNumber())               , false);

                } catch (e) {
                    console.log(e)
                }
            })

            it('user (david) should be able to apply to group even if he was already invited to it', async () => {
                try {

                    const user = david.pkh;
                    await signerFactory(tezos, david.sk);

                    const groupId             = firstGroupId;
                    const groupMembershipType = "applyForGroup";
                    
                    let confirmGroupMembershipOperation  = await bountyInstance.methods.groupMembership(
                        groupMembershipType,
                        groupId
                    ).send();
                    await confirmGroupMembershipOperation.confirmation();

                    bountyStorage = await bountyInstance.storage();

                    const userRecord           = await bountyStorage.userLedger.get(user);

                    const groupInvites         = userRecord.groupInvites.map(b => b.toNumber());
                    const groupApplications    = userRecord.groupApplications.map(b => b.toNumber());
                    const groups               = userRecord.groups.map(b => b.toNumber());

                    assert.equal(groupApplications.includes(groupId.toNumber())    , true);
                    assert.equal(groupInvites.includes(groupId.toNumber())         , true);
                    assert.equal(groups.includes(groupId.toNumber())               , false);

                } catch (e) {
                    console.log(e)
                }
            })

            it('user (trudy) should not be able to apply to a group if she is already a member in it', async () => {
                try {

                    const user = trudy.pkh;
                    await signerFactory(tezos, trudy.sk);

                    const groupId             = firstGroupId;
                    const groupMembershipType = "applyForGroup";
                    
                    let failConfirmGroupMembershipOperation  = await bountyInstance.methods.groupMembership(
                        groupMembershipType,
                        groupId
                    );
                    await chai.expect(failConfirmGroupMembershipOperation.send()).to.be.rejected;

                    bountyStorage = await bountyInstance.storage();

                    const userRecord           = await bountyStorage.userLedger.get(user);
                    const groupInvites         = userRecord.groupInvites.map(b => b.toNumber());
                    const groupApplications    = userRecord.groupApplications.map(b => b.toNumber());
                    const groups               = userRecord.groups.map(b => b.toNumber());

                    assert.equal(groupInvites.includes(groupId.toNumber())         , false);
                    assert.equal(groupApplications.includes(groupId.toNumber())    , false);
                    assert.equal(groups.includes(groupId.toNumber())               , true);

                } catch (e) {
                    console.log(e)
                }
            })

        })

        describe('%setGroupMember - approve', function () {
            
            beforeEach("Set signer to group leader (mallory)", async () => {
                bountyStorage = await bountyInstance.storage()
                await signerFactory(tezos, userSk);
            });

            it('group leader (mallory) should be able to approve members (david) to join her group', async () => {
                try {

                    const user               = david.pkh;
                    const groupId            = firstGroupId;
                    const setGroupMemberType = "approve";
                    
                    let approveGroupApplicationOperation  = await bountyInstance.methods.setGroupMember(
                        groupId,
                        user,
                        setGroupMemberType
                    ).send();
                    await approveGroupApplicationOperation.confirmation();

                    bountyStorage           = await bountyInstance.storage()

                    const userRecord        = await bountyStorage.userLedger.get(user);
                    const groupInvites      = userRecord.groupInvites.map(b => b.toNumber());
                    const groupApplications = userRecord.groupApplications.map(b => b.toNumber());
                    const groups            = userRecord.groups.map(b => b.toNumber());

                    assert.equal(groupInvites.includes(groupId.toNumber())          , false);
                    assert.equal(groupApplications.includes(groupId.toNumber())     , false);
                    assert.equal(groups.includes(groupId.toNumber())                , true);

                } catch (e) {
                    console.log(e)
                }
            })

            it('user (alice) should not be able to approve members (oscar) to join a group she is not the leader of', async () => {
                try {

                    await signerFactory(tezos, alice.sk);

                    const user               = oscar.pkh;
                    const groupId            = firstGroupId;
                    const setGroupMemberType = "approve";
                    
                    let failApproveGroupApplicationOperation  = await bountyInstance.methods.setGroupMember(
                        groupId,
                        user,
                        setGroupMemberType
                    );
                    await chai.expect(failApproveGroupApplicationOperation.send()).to.be.rejected;

                    bountyStorage           = await bountyInstance.storage()

                    const userRecord        = await bountyStorage.userLedger.get(user);
                    const groups            = userRecord.groups.map(b => b.toNumber());

                    assert.equal(groups.includes(groupId.toNumber())                , false);

                } catch (e) {
                    console.log(e)
                }
            })

            it('admin (eve) should not be able to approve members (oscar) to join a group', async () => {
                try {

                    await signerFactory(tezos, adminSk);

                    const user               = oscar.pkh;
                    const groupId            = firstGroupId;
                    const setGroupMemberType = "approve";
                    
                    let failApproveGroupApplicationOperation  = await bountyInstance.methods.setGroupMember(
                        groupId,
                        user,
                        setGroupMemberType
                    );
                    await chai.expect(failApproveGroupApplicationOperation.send()).to.be.rejected;

                    bountyStorage           = await bountyInstance.storage()

                    const userRecord        = await bountyStorage.userLedger.get(user);
                    const groups            = userRecord.groups.map(b => b.toNumber());

                    assert.equal(groups.includes(groupId.toNumber())                , false);

                } catch (e) {
                    console.log(e)
                }
            })

        })


        describe('%setGroupMember - remove', function () {
            
            beforeEach("Set signer to group leader (mallory)", async () => {
                bountyStorage = await bountyInstance.storage()
                await signerFactory(tezos, userSk);
            });

            it('user (alice) should not be able to remove members (david) from a group she is not the leader of', async () => {
                try {

                    await signerFactory(tezos, alice.sk);

                    const user               = david.pkh;
                    const groupId            = firstGroupId;
                    const setGroupMemberType = "remove";
                    
                    let failRemoveGroupApplicationOperation  = await bountyInstance.methods.setGroupMember(
                        groupId,
                        user,
                        setGroupMemberType
                    );
                    await chai.expect(failRemoveGroupApplicationOperation.send()).to.be.rejected;

                    bountyStorage           = await bountyInstance.storage()

                    const userRecord        = await bountyStorage.userLedger.get(user);
                    const groups            = userRecord.groups.map(b => b.toNumber());

                    assert.equal(groups.includes(groupId.toNumber()), true);

                } catch (e) {
                    console.log(e)
                }
            })

            it('admin (eve) should not be able to remove members (oscar) from a group she is not the leader of', async () => {
                try {

                    await signerFactory(tezos, adminSk);

                    const user               = david.pkh;
                    const groupId            = firstGroupId;
                    const setGroupMemberType = "remove";
                    
                    let failRemoveGroupApplicationOperation  = await bountyInstance.methods.setGroupMember(
                        groupId,
                        user,
                        setGroupMemberType
                    );
                    await chai.expect(failRemoveGroupApplicationOperation.send()).to.be.rejected;

                    bountyStorage           = await bountyInstance.storage()

                    const userRecord        = await bountyStorage.userLedger.get(user);
                    const groups            = userRecord.groups.map(b => b.toNumber());

                    assert.equal(groups.includes(groupId.toNumber()), true);

                } catch (e) {
                    console.log(e)
                }
            })

            it('group leader (mallory) should be able to remove members (david) from her group', async () => {
                try {

                    const user               = david.pkh;
                    const groupId            = firstGroupId;
                    const setGroupMemberType = "remove";
                    
                    let approveGroupApplicationOperation  = await bountyInstance.methods.setGroupMember(
                        groupId,
                        user,
                        setGroupMemberType
                    ).send();
                    await approveGroupApplicationOperation.confirmation();

                    bountyStorage           = await bountyInstance.storage()

                    const userRecord        = await bountyStorage.userLedger.get(user);
                    const groupInvites      = userRecord.groupInvites.map(b => b.toNumber());
                    const groupApplications = userRecord.groupApplications.map(b => b.toNumber());
                    const groups            = userRecord.groups.map(b => b.toNumber());

                    assert.equal(groupInvites.includes(groupId.toNumber())          , false);
                    assert.equal(groupApplications.includes(groupId.toNumber())     , false);
                    assert.equal(groups.includes(groupId.toNumber())                , false);

                } catch (e) {
                    console.log(e)
                }
            })

        })
        
    })


    describe(`
    -----------
    Bounty Application: `, function () {

        describe('%applyForBounty - applicant: user', function () {
            
            beforeEach("Set signer to user (mallory)", async () => {
                bountyStorage = await bountyInstance.storage()
                user    = mallory.pkh;
                userSk  = mallory.sk;
                await signerFactory(tezos, userSk);
            });

            it('user (mallory) can apply to a bounty', async () => {
                try {

                    const applicantType                  = "user";
                    const bountyId                       = bountyWithOneMilestoneId

                    const initialUserRecord              = await bountyStorage.userLedger.get(user);
                    const initialActiveBountyCount       = initialUserRecord == undefined ? 0 : initialUserRecord.activeBountyCount.toNumber();
                    const initialCurrentApplicationCount = initialUserRecord == undefined ? 0 : initialUserRecord.currentApplicationCount.toNumber();                
                    
                    const applyForBountyOperation = await bountyInstance.methods.applyForBounty(
                        bountyId,
                        applicantType,
                        user
                    ).send();
                    await applyForBountyOperation.confirmation();

                    bountyStorage = await bountyInstance.storage();

                    const applicationRecord = await bountyStorage.applicationLedger.get([bountyId, { "user": user}]);
                    const userRecord        = await bountyStorage.userLedger.get(user);
                    const appliedBounties   = userRecord.appliedBounties.map(b => b.toNumber());
                    const activeBounties    = userRecord.activeBounties.map(b => b.toNumber());
                    
                    // check applicant record
                    assert.equal(applicationRecord.status             , 'PENDING');
                    assert.equal(applicationRecord.completed          , false);
                    assert.equal(applicationRecord.reviewed           , false);
                    assert.equal(applicationRecord.review             , null);
                    assert.equal(applicationRecord.currentMilestone   , 1);
                    assert.equal(applicationRecord.milestoneLog       , null);
                    assert.equal(applicationRecord.fullyRewarded      , false);
                    assert.equal(applicationRecord.lastRewardTimestamp, null);

                    // check user record
                    assert.equal(userRecord.activeBountyCount.toNumber()        , initialActiveBountyCount);
                    assert.equal(userRecord.currentApplicationCount.toNumber()  , initialCurrentApplicationCount + 1);
                    assert.equal(appliedBounties.includes(bountyId.toNumber())  , true); // should return true now
                    assert.equal(activeBounties.includes(bountyId.toNumber())   , false);

                } catch (e) {
                    console.log(e)
                }
            })

            it('user (mallory) cannot apply again to the same bounty', async () => {
                try {

                    const applicantType                 = "user";
                    const bountyId                      = bountyWithOneMilestoneId

                    const applyForBountyOperation = await bountyInstance.methods.applyForBounty(
                        bountyId,
                        applicantType,
                        user
                    );
                    await chai.expect(applyForBountyOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it('user (mallory) cannot apply to an inactive bounty', async () => {
                try {

                    const applicantType                 = "user";
                    const bountyId                      = inactiveBountyId

                    const applyForBountyOperation = await bountyInstance.methods.applyForBounty(
                        bountyId,
                        applicantType,
                        user
                    );
                    await chai.expect(applyForBountyOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it('user (mallory) cannot apply to a bounty for another person (oscar)', async () => {
                try {

                    const applicantType                 = "user";
                    const bountyId                      = bountyWithThreeMilestonesId

                    const applyForBountyOperation = await bountyInstance.methods.applyForBounty(
                        bountyId,
                        applicantType,
                        oscar.pkh
                    );
                    await chai.expect(applyForBountyOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it('user (mallory) can apply to multiple bounties (bounty with three milstones)', async () => {
                try {

                    const applicantType                  = "user";
                    const bountyId                       = bountyWithThreeMilestonesId

                    const initialUserRecord              = await bountyStorage.userLedger.get(user);
                    const initialActiveBountyCount       = initialUserRecord == undefined ? 0 : initialUserRecord.activeBountyCount.toNumber();
                    const initialCurrentApplicationCount = initialUserRecord == undefined ? 0 : initialUserRecord.currentApplicationCount.toNumber();
                    
                    const applyForBountyOperation = await bountyInstance.methods.applyForBounty(
                        bountyId,
                        applicantType,
                        user
                    ).send();
                    await applyForBountyOperation.confirmation();

                    bountyStorage = await bountyInstance.storage();

                    const applicationRecord = await bountyStorage.applicationLedger.get([bountyId, { "user": user}]);
                    const userRecord        = await bountyStorage.userLedger.get(user);
                    const appliedBounties   = userRecord.appliedBounties.map(b => b.toNumber());
                    const activeBounties    = userRecord.activeBounties.map(b => b.toNumber());
                    const groupInvites      = userRecord.groupInvites.map(b => b.toNumber());
                    const groupApplications = userRecord.groupApplications.map(b => b.toNumber());
                    const groupsCreated     = userRecord.groupsCreated.map(b => b.toNumber());
                    const groups            = userRecord.groups.map(b => b.toNumber());

                    // check applicant record
                    assert.equal(applicationRecord.status             , 'PENDING');
                    assert.equal(applicationRecord.completed          , false);
                    assert.equal(applicationRecord.reviewed           , false);
                    assert.equal(applicationRecord.review             , null);
                    assert.equal(applicationRecord.currentMilestone   , 1);
                    assert.equal(applicationRecord.milestoneLog       , null);
                    assert.equal(applicationRecord.fullyRewarded      , false);
                    assert.equal(applicationRecord.lastRewardTimestamp, null);

                    // check user record
                    assert.equal(userRecord.activeBountyCount.toNumber()        , initialActiveBountyCount);
                    assert.equal(userRecord.currentApplicationCount.toNumber()  , initialCurrentApplicationCount + 1);
                    assert.equal(appliedBounties.includes(bountyId.toNumber())  , true); // should return true now
                    assert.equal(activeBounties.includes(bountyId.toNumber())   , false);
                    assert.equal(groupInvites.includes(bountyId.toNumber())     , false);
                    assert.equal(groupApplications.includes(bountyId.toNumber()), false);
                    assert.equal(groupsCreated.includes(bountyId.toNumber())    , false);
                    assert.equal(groups.includes(bountyId.toNumber())           , false);

                } catch (e) {
                    console.log(e)
                }
            })

            it('user (mallory) can apply to multiple bounties (bounty with no milstones)', async () => {
                try {

                    const applicantType                  = "user";
                    const bountyId                       = bountyWithNoMilestonesId

                    const initialUserRecord              = await bountyStorage.userLedger.get(user);
                    const initialActiveBountyCount       = initialUserRecord == undefined ? 0 : initialUserRecord.activeBountyCount.toNumber();
                    const initialCurrentApplicationCount = initialUserRecord == undefined ? 0 : initialUserRecord.currentApplicationCount.toNumber();
                    
                    const applyForBountyOperation = await bountyInstance.methods.applyForBounty(
                        bountyId,
                        applicantType,
                        user
                    ).send();
                    await applyForBountyOperation.confirmation();

                    bountyStorage = await bountyInstance.storage();

                    const applicationRecord = await bountyStorage.applicationLedger.get([bountyId, { "user": user}]);
                    const userRecord        = await bountyStorage.userLedger.get(user);
                    const appliedBounties   = userRecord.appliedBounties.map(b => b.toNumber());
                    const activeBounties    = userRecord.activeBounties.map(b => b.toNumber());
                    const groupInvites      = userRecord.groupInvites.map(b => b.toNumber());
                    const groupApplications = userRecord.groupApplications.map(b => b.toNumber());
                    const groupsCreated     = userRecord.groupsCreated.map(b => b.toNumber());
                    const groups            = userRecord.groups.map(b => b.toNumber());

                    // check applicant record
                    assert.equal(applicationRecord.status             , 'PENDING');
                    assert.equal(applicationRecord.completed          , false);
                    assert.equal(applicationRecord.reviewed           , false);
                    assert.equal(applicationRecord.review             , null);
                    assert.equal(applicationRecord.currentMilestone   , null);
                    assert.equal(applicationRecord.milestoneLog       , null);
                    assert.equal(applicationRecord.fullyRewarded      , false);
                    assert.equal(applicationRecord.lastRewardTimestamp, null);

                    // check user record
                    assert.equal(userRecord.activeBountyCount.toNumber()        , initialActiveBountyCount);
                    assert.equal(userRecord.currentApplicationCount.toNumber()  , initialCurrentApplicationCount + 1);
                    assert.equal(appliedBounties.includes(bountyId.toNumber())  , true); // should return true now
                    assert.equal(activeBounties.includes(bountyId.toNumber())   , false);
                    assert.equal(groupInvites.includes(bountyId.toNumber())     , false);
                    assert.equal(groupApplications.includes(bountyId.toNumber()), false);
                    assert.equal(groupsCreated.includes(bountyId.toNumber())    , false);
                    assert.equal(groups.includes(bountyId.toNumber())           , false);

                } catch (e) {
                    console.log(e)
                }
            })

        })


        describe('%cancelApplication - applicant: user', function () {
            
            beforeEach("Set signer to user (mallory)", async () => {
                bountyStorage = await bountyInstance.storage()
                user    = mallory.pkh;
                userSk  = mallory.sk;
                await signerFactory(tezos, userSk);
            });

            it('user (mallory) can cancel her bounty application', async () => {
                try {

                    const applicantType                  = "user";
                    const bountyId                       = bountyWithOneMilestoneId

                    const initialUserRecord              = await bountyStorage.userLedger.get(user);
                    const initialActiveBountyCount       = initialUserRecord == undefined ? 0 : initialUserRecord.activeBountyCount.toNumber();
                    const initialCurrentApplicationCount = initialUserRecord == undefined ? 0 : initialUserRecord.currentApplicationCount.toNumber();                
                    
                    const cancelBountyBountyOperation = await bountyInstance.methods.cancelApplication(
                        bountyId,
                        applicantType,
                        user
                    ).send();
                    await cancelBountyBountyOperation.confirmation();

                    bountyStorage = await bountyInstance.storage();

                    const applicationRecord = await bountyStorage.applicationLedger.get([bountyId, { "user": user}]);
                    const userRecord        = await bountyStorage.userLedger.get(user);
                    const appliedBounties   = userRecord.appliedBounties.map(b => b.toNumber());
                    const activeBounties    = userRecord.activeBounties.map(b => b.toNumber());
                    
                    // check applicant record
                    assert.equal(applicationRecord.status             , 'CANCELED');
                    assert.equal(applicationRecord.completed          , false);
                    assert.equal(applicationRecord.reviewed           , false);
                    assert.equal(applicationRecord.review             , null);
                    assert.equal(applicationRecord.currentMilestone   , 1);
                    assert.equal(applicationRecord.milestoneLog       , null);
                    assert.equal(applicationRecord.fullyRewarded      , false);
                    assert.equal(applicationRecord.lastRewardTimestamp, null);

                    // check user record
                    assert.equal(userRecord.activeBountyCount.toNumber()        , initialActiveBountyCount);
                    assert.equal(userRecord.currentApplicationCount.toNumber()  , initialCurrentApplicationCount - 1);
                    assert.equal(appliedBounties.includes(bountyId.toNumber())  , false); // true to false
                    assert.equal(activeBounties.includes(bountyId.toNumber())   , false);
                    
                } catch (e) {
                    console.log(e)
                }
            })

            it('user (mallory) cannot cancel a bounty application that has already been canceled', async () => {
                try {

                    const applicantType                 = "user";
                    const bountyId                      = bountyWithOneMilestoneId

                    const cancelBountyOperation = await bountyInstance.methods.cancelApplication(
                        bountyId,
                        applicantType,
                        user
                    );
                    await chai.expect(cancelBountyOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it('user (oscar) cannot cancel a bounty application from another user (mallory)', async () => {
                try {

                    await signerFactory(tezos, oscar.sk);
                    
                    const applicantType                 = "user";
                    const bountyId                      = bountyWithThreeMilestonesId

                    const cancelBountyOperation = await bountyInstance.methods.cancelApplication(
                        bountyId,
                        applicantType,
                        mallory.pkh
                    );
                    await chai.expect(cancelBountyOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

        })

        describe('%applyForBounty - applicant: group', function () {
            
            beforeEach("Set signer to user (mallory)", async () => {
                bountyStorage = await bountyInstance.storage()
                user    = mallory.pkh;
                userSk  = mallory.sk;
                await signerFactory(tezos, userSk);
            });

            it('group leader (mallory) can apply to a bounty for her group (Group 1)', async () => {
                try {

                    const applicantType                  = "group";
                    const groupId                        = firstGroupId;
                    const bountyId                       = bountyWithOneMilestoneId

                    const initialGroupRecord             = await bountyStorage.groupLedger.get(groupId);
                    const initialActiveBountyCount       = initialGroupRecord == undefined ? 0 : initialGroupRecord.activeBountyCount.toNumber();
                    const initialCurrentApplicationCount = initialGroupRecord == undefined ? 0 : initialGroupRecord.currentApplicationCount.toNumber();                
                    
                    const applyForBountyOperation = await bountyInstance.methods.applyForBounty(
                        bountyId,
                        applicantType,
                        groupId
                    ).send();
                    await applyForBountyOperation.confirmation();

                    bountyStorage = await bountyInstance.storage();

                    const applicationRecord = await bountyStorage.applicationLedger.get([bountyId, { "group": groupId}]);
                    const groupRecord       = await bountyStorage.groupLedger.get(groupId);
                    const appliedBounties   = groupRecord.appliedBounties.map(b => b.toNumber());
                    const activeBounties    = groupRecord.activeBounties.map(b => b.toNumber());

                    // check applicant record
                    assert.equal(applicationRecord.status             , 'PENDING');
                    assert.equal(applicationRecord.completed          , false);
                    assert.equal(applicationRecord.reviewed           , false);
                    assert.equal(applicationRecord.review             , null);
                    assert.equal(applicationRecord.currentMilestone   , 1);
                    assert.equal(applicationRecord.milestoneLog       , null);
                    assert.equal(applicationRecord.fullyRewarded      , false);
                    assert.equal(applicationRecord.lastRewardTimestamp, null);

                    // check user record
                    assert.equal(groupRecord.activeBountyCount.toNumber()       , initialActiveBountyCount);
                    assert.equal(groupRecord.currentApplicationCount.toNumber() , initialCurrentApplicationCount + 1);
                    assert.equal(appliedBounties.includes(bountyId.toNumber())  , true); // should return true now
                    assert.equal(activeBounties.includes(bountyId.toNumber())   , false);

                } catch (e) {
                    console.log(e)
                }
            })

            it('group leader (mallory) cannot apply again to the same bounty for the same group', async () => {
                try {

                    const applicantType                 = "group";
                    const groupId                       = firstGroupId;
                    const bountyId                      = bountyWithOneMilestoneId

                    const applyForBountyOperation = await bountyInstance.methods.applyForBounty(
                        bountyId,
                        applicantType,
                        groupId
                    );
                    await chai.expect(applyForBountyOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it('group leader (mallory) cannot apply to an inactive bounty', async () => {
                try {

                    const applicantType                 = "group";
                    const groupId                       = firstGroupId;
                    const bountyId                      = inactiveBountyId

                    const applyForBountyOperation = await bountyInstance.methods.applyForBounty(
                        bountyId,
                        applicantType,
                        groupId
                    );
                    await chai.expect(applyForBountyOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it('group leader (mallory) cannot apply to a bounty for a non-existent group', async () => {
                try {

                    const applicantType                 = "group";
                    const groupId                       = 999;
                    const bountyId                      = bountyWithThreeMilestonesId

                    const applyForBountyOperation = await bountyInstance.methods.applyForBounty(
                        bountyId,
                        applicantType,
                        groupId
                    );
                    await chai.expect(applyForBountyOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it('group leader (mallory) can apply to multiple bounties (bounty with three milstones) for Group 1', async () => {
                try {

                    const applicantType                  = "group";
                    const groupId                        = firstGroupId;
                    const bountyId                       = bountyWithThreeMilestonesId

                    const initialGroupRecord             = await bountyStorage.groupLedger.get(groupId);
                    const initialActiveBountyCount       = initialGroupRecord == undefined ? 0 : initialGroupRecord.activeBountyCount.toNumber();
                    const initialCurrentApplicationCount = initialGroupRecord == undefined ? 0 : initialGroupRecord.currentApplicationCount.toNumber();
                    
                    const applyForBountyOperation = await bountyInstance.methods.applyForBounty(
                        bountyId,
                        applicantType,
                        groupId
                    ).send();
                    await applyForBountyOperation.confirmation();

                    bountyStorage = await bountyInstance.storage();

                    const applicationRecord = await bountyStorage.applicationLedger.get([bountyId, { "group": groupId}]);
                    const groupRecord       = await bountyStorage.groupLedger.get(groupId);
                    const appliedBounties   = groupRecord.appliedBounties.map(b => b.toNumber());
                    const activeBounties    = groupRecord.activeBounties.map(b => b.toNumber());

                    // check applicant record
                    assert.equal(applicationRecord.status             , 'PENDING');
                    assert.equal(applicationRecord.completed          , false);
                    assert.equal(applicationRecord.reviewed           , false);
                    assert.equal(applicationRecord.review             , null);
                    assert.equal(applicationRecord.currentMilestone   , 1);
                    assert.equal(applicationRecord.milestoneLog       , null);
                    assert.equal(applicationRecord.fullyRewarded      , false);
                    assert.equal(applicationRecord.lastRewardTimestamp, null);

                    // check user record
                    assert.equal(groupRecord.activeBountyCount.toNumber()       , initialActiveBountyCount);
                    assert.equal(groupRecord.currentApplicationCount.toNumber() , initialCurrentApplicationCount + 1);
                    assert.equal(appliedBounties.includes(bountyId.toNumber())  , true); // should return true now
                    assert.equal(activeBounties.includes(bountyId.toNumber())   , false);

                } catch (e) {
                    console.log(e)
                }
            })

            it('group leader (mallory) can apply to multiple bounties (bounty with no milstones) for Group 1', async () => {
                try {

                    const applicantType                  = "group";
                    const groupId                        = firstGroupId;
                    const bountyId                       = bountyWithNoMilestonesId

                    const initialGroupRecord             = await bountyStorage.groupLedger.get(groupId);
                    const initialActiveBountyCount       = initialGroupRecord == undefined ? 0 : initialGroupRecord.activeBountyCount.toNumber();
                    const initialCurrentApplicationCount = initialGroupRecord == undefined ? 0 : initialGroupRecord.currentApplicationCount.toNumber();
                    
                    const applyForBountyOperation = await bountyInstance.methods.applyForBounty(
                        bountyId,
                        applicantType,
                        groupId
                    ).send();
                    await applyForBountyOperation.confirmation();

                    bountyStorage = await bountyInstance.storage();

                    const applicationRecord = await bountyStorage.applicationLedger.get([bountyId, { "group": groupId}]);
                    const groupRecord       = await bountyStorage.groupLedger.get(groupId);
                    const appliedBounties   = groupRecord.appliedBounties.map(b => b.toNumber());
                    const activeBounties    = groupRecord.activeBounties.map(b => b.toNumber());

                    // check applicant record
                    assert.equal(applicationRecord.status             , 'PENDING');
                    assert.equal(applicationRecord.completed          , false);
                    assert.equal(applicationRecord.reviewed           , false);
                    assert.equal(applicationRecord.review             , null);
                    assert.equal(applicationRecord.currentMilestone   , null);
                    assert.equal(applicationRecord.milestoneLog       , null);
                    assert.equal(applicationRecord.fullyRewarded      , false);
                    assert.equal(applicationRecord.lastRewardTimestamp, null);

                    // check user record
                    assert.equal(groupRecord.activeBountyCount.toNumber()       , initialActiveBountyCount);
                    assert.equal(groupRecord.currentApplicationCount.toNumber() , initialCurrentApplicationCount + 1);
                    assert.equal(appliedBounties.includes(bountyId.toNumber())  , true); // should return true now
                    assert.equal(activeBounties.includes(bountyId.toNumber())   , false);

                } catch (e) {
                    console.log(e)
                }
            })

            it('group leader (mallory) can apply to multiple bounties (bounty with no milestones) for Group 2', async () => {
                try {

                    const applicantType                  = "group";
                    const groupId                        = secondGroupId;
                    const bountyId                       = bountyWithNoMilestonesId

                    const initialGroupRecord             = await bountyStorage.groupLedger.get(groupId);
                    const initialActiveBountyCount       = initialGroupRecord == undefined ? 0 : initialGroupRecord.activeBountyCount.toNumber();
                    const initialCurrentApplicationCount = initialGroupRecord == undefined ? 0 : initialGroupRecord.currentApplicationCount.toNumber();
                    
                    const applyForBountyOperation = await bountyInstance.methods.applyForBounty(
                        bountyId,
                        applicantType,
                        groupId
                    ).send();
                    await applyForBountyOperation.confirmation();

                    bountyStorage = await bountyInstance.storage();

                    const applicationRecord = await bountyStorage.applicationLedger.get([bountyId, { "group": groupId}]);
                    const groupRecord        = await bountyStorage.groupLedger.get(groupId);
                    const appliedBounties   = groupRecord.appliedBounties.map(b => b.toNumber());
                    const activeBounties    = groupRecord.activeBounties.map(b => b.toNumber());

                    // check applicant record
                    assert.equal(applicationRecord.status             , 'PENDING');
                    assert.equal(applicationRecord.completed          , false);
                    assert.equal(applicationRecord.reviewed           , false);
                    assert.equal(applicationRecord.review             , null);
                    assert.equal(applicationRecord.currentMilestone   , null);
                    assert.equal(applicationRecord.milestoneLog       , null);
                    assert.equal(applicationRecord.fullyRewarded      , false);
                    assert.equal(applicationRecord.lastRewardTimestamp, null);

                    // check user record
                    assert.equal(groupRecord.activeBountyCount.toNumber()        , initialActiveBountyCount);
                    assert.equal(groupRecord.currentApplicationCount.toNumber()  , initialCurrentApplicationCount + 1);
                    assert.equal(appliedBounties.includes(bountyId.toNumber())  , true); // should return true now
                    assert.equal(activeBounties.includes(bountyId.toNumber())   , false);

                } catch (e) {
                    console.log(e)
                }
            })

        })

        describe('%cancelApplication - applicant: group', function () {
            
            beforeEach("Set signer to user (mallory)", async () => {
                bountyStorage = await bountyInstance.storage()
                user    = mallory.pkh;
                userSk  = mallory.sk;
                await signerFactory(tezos, userSk);
            });

            it('non-group leader (oscar) cannot cancel a bounty application for a group he is not the leader of', async () => {
                try {

                    await signerFactory(tezos, oscar.sk);
                    
                    const applicantType                 = "group";
                    const groupId                       = firstGroupId;
                    const bountyId                      = bountyWithThreeMilestonesId

                    const cancelBountyOperation = await bountyInstance.methods.cancelApplication(
                        bountyId,
                        applicantType,
                        groupId
                    );
                    await chai.expect(cancelBountyOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it(`group-leader (mallory) can cancel her group's bounty application`, async () => {
                try {

                    const applicantType                  = "group";
                    const groupId                        = secondGroupId;
                    const bountyId                       = bountyWithNoMilestonesId;

                    const initialGroupRecord              = await bountyStorage.groupLedger.get(groupId);
                    const initialActiveBountyCount       = initialGroupRecord == undefined ? 0 : initialGroupRecord.activeBountyCount.toNumber();
                    const initialCurrentApplicationCount = initialGroupRecord == undefined ? 0 : initialGroupRecord.currentApplicationCount.toNumber();                
                    
                    const cancelBountyBountyOperation = await bountyInstance.methods.cancelApplication(
                        bountyId,
                        applicantType,
                        groupId
                    ).send();
                    await cancelBountyBountyOperation.confirmation();

                    bountyStorage = await bountyInstance.storage();

                    const applicationRecord = await bountyStorage.applicationLedger.get([bountyId, { "group": groupId}]);
                    const groupRecord       = await bountyStorage.groupLedger.get(groupId);
                    const appliedBounties   = groupRecord.appliedBounties.map(b => b.toNumber());
                    const activeBounties    = groupRecord.activeBounties.map(b => b.toNumber());

                    // check applicant record
                    assert.equal(applicationRecord.status             , 'CANCELED');
                    assert.equal(applicationRecord.completed          , false);
                    assert.equal(applicationRecord.reviewed           , false);
                    assert.equal(applicationRecord.review             , null);
                    assert.equal(applicationRecord.currentMilestone   , null);
                    assert.equal(applicationRecord.milestoneLog       , null);
                    assert.equal(applicationRecord.fullyRewarded      , false);
                    assert.equal(applicationRecord.lastRewardTimestamp, null);

                    // check user record
                    assert.equal(groupRecord.activeBountyCount.toNumber()       , initialActiveBountyCount);
                    assert.equal(groupRecord.currentApplicationCount.toNumber() , initialCurrentApplicationCount - 1);
                    assert.equal(appliedBounties.includes(bountyId.toNumber())  , false); // true to false
                    assert.equal(activeBounties.includes(bountyId.toNumber())   , false);

                } catch (e) {
                    console.log(e)
                }
            })

            it('group leader (mallory) cannot cancel a bounty application that has already been canceled', async () => {
                try {

                    const applicantType                 = "group";
                    const groupId                       = secondGroupId;
                    const bountyId                      = bountyWithNoMilestonesId;

                    const cancelBountyOperation = await bountyInstance.methods.cancelApplication(
                        bountyId,
                        applicantType,
                        groupId
                    );
                    await chai.expect(cancelBountyOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

        })

    })

    describe(`
    -----------
    Before Bounty Application has been approved: `, function () {

        beforeEach("Set signer to user (mallory)", async () => {
            bountyStorage = await bountyInstance.storage()
            user    = mallory.pkh;
            userSk  = mallory.sk;
            await signerFactory(tezos, userSk);
        });

        describe('%completeBounty', function () {
            
            beforeEach("Set signer to user (mallory)", async () => {
                bountyStorage = await bountyInstance.storage()
                await signerFactory(tezos, userSk);
            });

            it('user (mallory) cannot complete a bounty if the application has not been approved', async () => {
                try {
                    
                    const applicantType                 = "user";
                    const bountyId                      = bountyWithThreeMilestonesId

                    const completeBountyOperation = await bountyInstance.methods.completeBounty(
                        bountyId,
                        applicantType,
                        mallory.pkh
                    );
                    await chai.expect(completeBountyOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it('group leader (mallory) cannot complete a bounty for her group if the application has not been approved', async () => {
                try {
                    
                    const applicantType                 = "group";
                    const groupId                       = firstGroupId;
                    const bountyId                      = bountyWithThreeMilestonesId

                    const completeBountyOperation = await bountyInstance.methods.completeBounty(
                        bountyId,
                        applicantType,
                        groupId
                    );
                    await chai.expect(completeBountyOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it('non-group leader (trudy) cannot complete a bounty for a group (she is not the leader of) if the application has not been approved', async () => {
                try {

                    await signerFactory(tezos, trudy.sk);
                    
                    const applicantType                 = "group";
                    const groupId                       = firstGroupId;
                    const bountyId                      = bountyWithThreeMilestonesId

                    const completeBountyOperation = await bountyInstance.methods.completeBounty(
                        bountyId,
                        applicantType,
                        groupId
                    );
                    await chai.expect(completeBountyOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

        })

        describe('%stopBounty', function () {
            
            beforeEach("Set signer to user (mallory)", async () => {
                bountyStorage = await bountyInstance.storage()
                await signerFactory(tezos, userSk);
            });

            it('user (mallory) cannot stop a bounty if the application has not been approved', async () => {
                try {
                    
                    const applicantType                 = "user";
                    const bountyId                      = bountyWithThreeMilestonesId

                    const stopBountyOperation = await bountyInstance.methods.stopBounty(
                        bountyId,
                        applicantType,
                        mallory.pkh
                    );
                    await chai.expect(stopBountyOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it('group leader (mallory) cannot stop a bounty if the application has not been approved', async () => {
                try {
                    
                    const applicantType                 = "group";
                    const groupId                       = firstGroupId;
                    const bountyId                      = bountyWithThreeMilestonesId

                    const stopBountyOperation = await bountyInstance.methods.stopBounty(
                        bountyId,
                        applicantType,
                        groupId
                    );
                    await chai.expect(stopBountyOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it('non-group leader (trudy) cannot stop a bounty (she is not leader of) if the application has not been approved', async () => {
                try {
                    
                    await signerFactory(tezos, trudy.sk);

                    const applicantType                 = "group";
                    const groupId                       = firstGroupId;
                    const bountyId                      = bountyWithThreeMilestonesId

                    const stopBountyOperation = await bountyInstance.methods.stopBounty(
                        bountyId,
                        applicantType,
                        groupId
                    );
                    await chai.expect(stopBountyOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

        })
    })  

    describe(`
    -----------
    Bounty Application has been approved: `, function () {

        describe('%approveOrReject - applicant: user', function () {
            
            beforeEach("Set signer to bounty creator (alice)", async () => {
                bountyStorage = await bountyInstance.storage()
                user          = mallory.pkh;
                await signerFactory(tezos, bountyCreatorSk);
            });

            it('bounty creator (alice) should be able to approve a user bounty application (bounty with three milestones)', async () => {
                try {

                    const bountyId      = bountyWithThreeMilestonesId    
                    const applicantType = "user";
                    const approvalType  = "approve";
                    
                    const approveOrRejectOperation  = await bountyInstance.methods.approveOrReject(
                        bountyId,
                        applicantType,
                        user,
                        approvalType
                    ).send();
                    await approveOrRejectOperation.confirmation();

                    bountyStorage = await bountyInstance.storage();

                    const applicationRecord = await bountyStorage.applicationLedger.get([bountyId, { "user": user}]);                    
                    assert.equal(applicationRecord.status       , "APPROVED");

                } catch (e) {
                    console.log(e)
                }
            })

            it('bounty creator (mallory) should not be able to approve a canceled bounty application', async () => {
                try {
                    
                    const bountyId      = bountyWithOneMilestoneId
                    const applicantType = "user";
                    const approvalType  = "approve";

                    const failOperation = await bountyInstance.methods.approveOrReject(
                        bountyId,
                        applicantType,
                        user,
                        approvalType
                    );
                    await chai.expect(failOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it('admin (eve) should be able to approve a user bounty application (bounty with no milestones)', async () => {
                try {

                    await signerFactory(tezos, adminSk);

                    const bountyId      = bountyWithNoMilestonesId    
                    const applicantType = "user";
                    const approvalType  = "approve";
                    
                    const approveOrRejectOperation  = await bountyInstance.methods.approveOrReject(
                        bountyId,
                        applicantType,
                        user,
                        approvalType
                    ).send();
                    await approveOrRejectOperation.confirmation();

                    bountyStorage = await bountyInstance.storage();

                    const applicationRecord = await bountyStorage.applicationLedger.get([bountyId, { "user": user}]);                    
                    assert.equal(applicationRecord.status       , "APPROVED");
    

                } catch (e) {
                    console.log(e)
                }
            })

        })

        describe('%completeBounty - applicant: user', function () {
            
            beforeEach("Set signer to user (mallory)", async () => {
                bountyStorage = await bountyInstance.storage()
                user          = mallory.pkh;
                await signerFactory(tezos, userSk);
            });

            it('user (mallory) should be able to complete a bounty (with no milestones)', async () => {
                try {

                    const bountyId      = bountyWithNoMilestonesId    
                    const applicantType = "user";
                    
                    const approveOrRejectOperation  = await bountyInstance.methods.completeBounty(
                        bountyId,
                        applicantType,
                        user
                    ).send();
                    await approveOrRejectOperation.confirmation();

                    const applicationRecord = await bountyStorage.applicationLedger.get([bountyId, { "user": user}]);
                    
                    assert.equal(applicationRecord.status       , "REVIEW_PENDING");
                    assert.equal(applicationRecord.completed    , true);
                    assert.equal(applicationRecord.reviewed     , false);

                } catch (e) {
                    console.log(e)
                }
            })

            it('user (mallory) should be able to complete a bounty (with milestones)', async () => {
                try {

                    const bountyId      = bountyWithThreeMilestonesId    
                    const applicantType = "user";
                    
                    const approveOrRejectOperation  = await bountyInstance.methods.completeBounty(
                        bountyId,
                        applicantType,
                        user
                    ).send();
                    await approveOrRejectOperation.confirmation();

                    const applicationRecord = await bountyStorage.applicationLedger.get([bountyId, { "user": user}]);
                    const currentMilestone = applicationRecord.currentMilestone;

                    const milestoneLogRecord = await applicationRecord.milestoneLog.get(currentMilestone);

                    // Application Record
                    assert.equal(applicationRecord.status       , "REVIEW_PENDING")

                    // Milestone Log Record
                    assert.equal(milestoneLogRecord.status      , "REVIEW_PENDING")
                    assert.equal(milestoneLogRecord.completed   , true)
                    assert.equal(milestoneLogRecord.reviewed    , false)

                } catch (e) {
                    console.log(e)
                }
            })

            it('user (mallory) should not be able to complete a bounty again before it has been reviewed', async () => {
                try {

                    const bountyId      = bountyWithThreeMilestonesId    
                    const applicantType = "user";
                    
                    const failOperation  = await bountyInstance.methods.completeBounty(
                        bountyId,
                        applicantType,
                        user
                    );
                    await chai.expect(failOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

        })


        describe('%reviewBounty - applicant: user', function () {
            
            beforeEach("Set signer to bounty creator (alice)", async () => {
                bountyStorage = await bountyInstance.storage()
                await signerFactory(tezos, bountyCreatorSk);
            });

            it('bounty creator (alice) should be able to review and approve a completed bounty (status: REVIEW_APPROVED)', async () => {
                try {

                    const bountyId      = bountyWithThreeMilestonesId    
                    const applicantType = "user";
                    const status        = "REVIEW_APPROVED";
                    
                    const milestoneReview = "Milestone review text: rejected";
                    const bountyReview    = "Bounty review text: rejected";
                    
                    const reviewOperation  = await bountyInstance.methods.reviewBounty(
                        bountyId,
                        applicantType,
                        user,
                        status, 
                        milestoneReview,
                        bountyReview
                    ).send();
                    await reviewOperation.confirmation();

                    bountyStorage = await bountyInstance.storage();

                    const applicationRecord = await bountyStorage.applicationLedger.get([bountyId, { "user": user}]);
                    assert.equal(applicationRecord.status             , status);
                    assert.equal(applicationRecord.reviewed           , true);
                    assert.equal(applicationRecord.review             , bountyReview);

                } catch (e) {
                    console.log(e)
                }
            })

            it('bounty creator (alice) should be able to change a review of a completed bounty (status: REVIEW_REJECTED)', async () => {
                try {

                    const bountyId      = bountyWithThreeMilestonesId    
                    const applicantType = "user";
                    const status        = "REVIEW_REJECTED";
                    
                    const milestoneReview = "Milestone review text: rejected";
                    const bountyReview    = "Bounty review text: rejected";
                    
                    const reviewOperation  = await bountyInstance.methods.reviewBounty(
                        bountyId,
                        applicantType,
                        user,
                        status, 
                        milestoneReview,
                        bountyReview
                    ).send();
                    await reviewOperation.confirmation();

                    bountyStorage = await bountyInstance.storage();

                    const applicationRecord = await bountyStorage.applicationLedger.get([bountyId, { "user": user}]);
                    assert.equal(applicationRecord.status             , status);
                    assert.equal(applicationRecord.reviewed           , true);
                    assert.equal(applicationRecord.review             , bountyReview);

                } catch (e) {
                    console.log(e)
                }
            })

            it('bounty creator (alice) should not be able to set an non-valid status in a review of a completed bounty (status: REVIEW_DONE)', async () => {
                try {

                    const bountyId      = bountyWithThreeMilestonesId    
                    const applicantType = "user";
                    const status        = "REVIEW_DONE";

                    // for reference, valid review statuses are "REVIEW_APPROVED", "REVIEW_DISPUTED", "REVIEW_REJECTED"
                    
                    const milestoneReview = "Milestone review text: should fail";
                    const bountyReview    = "Bounty review text: should fail";
                    
                    const reviewOperation  = await bountyInstance.methods.reviewBounty(
                        bountyId,
                        applicantType,
                        user,
                        status, 
                        milestoneReview,
                        bountyReview
                    );
                    await chai.expect(reviewOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it('admin (eve) should be able to review a completed bounty (status: REVIEW_REJECTED)', async () => {
                try {

                    await signerFactory(tezos, adminSk);

                    const bountyId      = bountyWithNoMilestonesId;
                    const applicantType = "user";
                    const status        = "REVIEW_REJECTED";
                    
                    const milestoneReview = "Milestone review text: rejected";
                    const bountyReview    = "Bounty review text: rejected";
                    
                    const reviewOperation  = await bountyInstance.methods.reviewBounty(
                        bountyId,
                        applicantType,
                        user,
                        status, 
                        milestoneReview,
                        bountyReview
                    ).send();
                    await reviewOperation.confirmation();

                    bountyStorage = await bountyInstance.storage();

                    const applicationRecord = await bountyStorage.applicationLedger.get([bountyId, { "user": user}]);
                    assert.equal(applicationRecord.status             , status);
                    assert.equal(applicationRecord.reviewed           , true);
                    assert.equal(applicationRecord.review             , bountyReview);

                } catch (e) {
                    console.log(e)
                }
            })

            it('admin (eve) should be able to change a review of a completed bounty (status: REVIEW_APPROVED)', async () => {
                try {

                    await signerFactory(tezos, adminSk);

                    const bountyId      = bountyWithNoMilestonesId;
                    const applicantType = "user";
                    const status        = "REVIEW_APPROVED";
                    
                    const milestoneReview = "Milestone review text: approved";
                    const bountyReview    = "Bounty review text: approved";
                    
                    const reviewOperation  = await bountyInstance.methods.reviewBounty(
                        bountyId,
                        applicantType,
                        user,
                        status, 
                        milestoneReview,
                        bountyReview
                    ).send();
                    await reviewOperation.confirmation();

                    bountyStorage = await bountyInstance.storage();

                    const applicationRecord = await bountyStorage.applicationLedger.get([bountyId, { "user": user}]);
                    assert.equal(applicationRecord.status             , status);
                    assert.equal(applicationRecord.reviewed           , true);
                    assert.equal(applicationRecord.review             , bountyReview);

                } catch (e) {
                    console.log(e)
                }
            })

            it('admin (eve) should not be able to set an non-valid status in a review of a completed bounty (status: REVIEW_DONE)', async () => {
                try {

                    await signerFactory(tezos, adminSk);

                    const bountyId      = bountyWithNoMilestonesId    
                    const applicantType = "user";
                    const status        = "REVIEW_DONE";

                    // for reference, valid review statuses are "REVIEW_APPROVED", "REVIEW_DISPUTED", "REVIEW_REJECTED"
                    
                    const milestoneReview = "Milestone review text: should fail";
                    const bountyReview    = "Bounty review text: should fail";
                    
                    const reviewOperation  = await bountyInstance.methods.reviewBounty(
                        bountyId,
                        applicantType,
                        user,
                        status, 
                        milestoneReview,
                        bountyReview
                    );
                    await chai.expect(reviewOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

        })


        describe('%approveOrReject - applicant: group', function () {
            
            beforeEach("Set signer to bounty creator (alice)", async () => {
                bountyStorage = await bountyInstance.storage()
                await signerFactory(tezos, bountyCreatorSk);
            });

            it('bounty creator (alice) should be able to approve a group bounty application', async () => {
                try {

                    const bountyId      = bountyWithThreeMilestonesId    
                    const applicantType = "group";
                    const groupId       = firstGroupId;
                    const approvalType  = "approve";
                    
                    const approveOrRejectOperation  = await bountyInstance.methods.approveOrReject(
                        bountyId,
                        applicantType,
                        groupId,
                        approvalType
                    ).send();
                    await approveOrRejectOperation.confirmation();

                    bountyStorage = await bountyInstance.storage();

                    const applicationRecord = await bountyStorage.applicationLedger.get([bountyId, { "group": groupId}]);                    
                    assert.equal(applicationRecord.status       , "APPROVED");

    

                } catch (e) {
                    console.log(e)
                }
            })

            it('bounty creator (mallory) should not be able to approve a canceled bounty application', async () => {
                try {
                    
                    const bountyId      = bountyWithNoMilestonesId
                    const applicantType = "group";
                    const groupId       = secondGroupId;
                    const approvalType  = "approve";

                    const failOperation = await bountyInstance.methods.approveOrReject(
                        bountyId,
                        applicantType,
                        groupId,
                        approvalType
                    );
                    await chai.expect(failOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })


            it('bounty creator (mallory) should not be able to approve a group bounty application that does not exist', async () => {
                try {
                    
                    const bountyId      = 999;
                    const applicantType = "group";
                    const groupId       = secondGroupId;
                    const approvalType  = "approve";

                    const failOperation = await bountyInstance.methods.approveOrReject(
                        bountyId,
                        applicantType,
                        groupId,
                        approvalType
                    );
                    await chai.expect(failOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it('admin (eve) should be able to approve a group bounty application (bounty with no milestones)', async () => {
                try {

                    await signerFactory(tezos, adminSk);

                    const bountyId      = bountyWithNoMilestonesId    
                    const applicantType = "group";
                    const groupId       = firstGroupId;
                    const approvalType  = "approve";
                    
                    const approveOrRejectOperation  = await bountyInstance.methods.approveOrReject(
                        bountyId,
                        applicantType,
                        groupId,
                        approvalType
                    ).send();
                    await approveOrRejectOperation.confirmation();

                    bountyStorage = await bountyInstance.storage();

                    const applicationRecord = await bountyStorage.applicationLedger.get([bountyId, { "group": groupId}]);                    
                    assert.equal(applicationRecord.status       , "APPROVED");
    
                } catch (e) {
                    console.log(e)
                }
            })

        })

        describe(`---
        Group actions after one bounty has been approved`, function () {
                
            beforeEach("Set signer to group leader (mallory)", async () => {
                bountyStorage = await bountyInstance.storage()
                await signerFactory(tezos, userSk);
            });

            it('%setGroupMember: invite - group leader (mallory) should still be able to invite members (isaac) to join his group after bounty application has been approved', async () => {
                try {

                    const user               = isaac.pkh;
                    const groupId            = firstGroupId;
                    const setGroupMemberType = "invite";

                    // bountyInProgress: True
                    const initialGroupRecord = await bountyStorage.groupLedger.get(groupId);
                    assert.equal(initialGroupRecord.bountyInProgress, true);
                    
                    let inviteToGroupOperation  = await bountyInstance.methods.setGroupMember(
                        groupId,
                        user,
                        setGroupMemberType
                    ).send();
                    await inviteToGroupOperation.confirmation();

                    bountyStorage           = await bountyInstance.storage()

                    const userRecord        = await bountyStorage.userLedger.get(isaac.pkh);
                    const groupInvites      = userRecord.groupInvites.map(b => b.toNumber());

                    assert.equal(groupInvites.includes(groupId.toNumber()), true);

                } catch (e) {
                    console.log(e)
                }
            })

            it('%confirmGroupMembership - user (isaac) should not be able to confirm group membership if group has started on a bounty', async () => {
                try {

                    const user = isaac.pkh;
                    await signerFactory(tezos, isaac.sk);

                    const groupId             = firstGroupId;
                    const groupMembershipType = "confirmGroupMembership";

                    // bountyInProgress: True
                    const initialGroupRecord = await bountyStorage.groupLedger.get(groupId);
                    assert.equal(initialGroupRecord.bountyInProgress, true);
                    
                    let failConfirmGroupMembershipOperation  = await bountyInstance.methods.groupMembership(
                        groupMembershipType,
                        groupId
                    );
                    await chai.expect(failConfirmGroupMembershipOperation.send()).to.be.rejected;

                    const userRecord   = await bountyStorage.userLedger.get(user);
                    const groups       = userRecord.groups.map(b => b.toNumber());
                    
                    assert.equal(groups.includes(groupId.toNumber()), false);

                } catch (e) {
                    console.log(e)
                }
            })

            it('%groupMembership: applyForGroup - user (isaac) should still be able to apply to group even if it has a bounty in progress', async () => {
                try {

                    const user = isaac.pkh;
                    await signerFactory(tezos, isaac.sk);

                    const groupId             = firstGroupId;
                    const groupMembershipType = "applyForGroup";
                    
                    let confirmGroupMembershipOperation  = await bountyInstance.methods.groupMembership(
                        groupMembershipType,
                        groupId
                    ).send();
                    await confirmGroupMembershipOperation.confirmation();

                    bountyStorage = await bountyInstance.storage();

                    const userRecord           = await bountyStorage.userLedger.get(user);
                    const groupApplications    = userRecord.groupApplications.map(b => b.toNumber());
                    const groups               = userRecord.groups.map(b => b.toNumber());

                    assert.equal(groupApplications.includes(groupId.toNumber())    , true);
                    assert.equal(groups.includes(groupId.toNumber())               , false);

                } catch (e) {
                    console.log(e)
                }
            })

            it(`%setGroupMember: approve - group leader (mallory) should not be able to approve members (isaac) to join a group if there's a bounty in progress`, async () => {
                try {

                    const user               = isaac.pkh;
                    const groupId            = firstGroupId;
                    const setGroupMemberType = "approve";
                    
                    let failApproveGroupApplicationOperation  = await bountyInstance.methods.setGroupMember(
                        groupId,
                        user,
                        setGroupMemberType
                    );
                    await chai.expect(failApproveGroupApplicationOperation.send()).to.be.rejected;

                    bountyStorage           = await bountyInstance.storage()

                    const userRecord        = await bountyStorage.userLedger.get(user);
                    const groups            = userRecord.groups.map(b => b.toNumber());

                    assert.equal(groups.includes(groupId.toNumber())                , false);

                } catch (e) {
                    console.log(e)
                }
            })

        })

        describe(`---
      %completeBounty - applicant: group`, function () {
            
            beforeEach("Set signer to group leader (mallory)", async () => {
                bountyStorage = await bountyInstance.storage()
                user          = mallory.pkh;
                await signerFactory(tezos, userSk);
            });

            it('non-group leader (oscar) should not be able to complete a group bounty (with no milestones)', async () => {
                try {

                    await signerFactory(tezos, oscar.sk);

                    const bountyId      = bountyWithNoMilestonesId    
                    const groupId       = firstGroupId;
                    const applicantType = "group";
                    
                    const approveOrRejectOperation  = await bountyInstance.methods.completeBounty(
                        bountyId,
                        applicantType,
                        groupId
                    );
                    await chai.expect(approveOrRejectOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it('group leader (mallory) should be able to complete a group bounty (with no milestones)', async () => {
                try {

                    const bountyId      = bountyWithNoMilestonesId    
                    const groupId       = firstGroupId;
                    const applicantType = "group";
                    
                    const approveOrRejectOperation  = await bountyInstance.methods.completeBounty(
                        bountyId,
                        applicantType,
                        groupId
                    ).send();
                    await approveOrRejectOperation.confirmation();

                    const applicationRecord = await bountyStorage.applicationLedger.get([bountyId, { "group": groupId}]);
                    
                    assert.equal(applicationRecord.status       , "REVIEW_PENDING");
                    assert.equal(applicationRecord.completed    , true);
                    assert.equal(applicationRecord.reviewed     , false);

                } catch (e) {
                    console.log(e)
                }
            })

            it('group leader (mallory) should be able to complete a group bounty (with milestones)', async () => {
                try {

                    const bountyId      = bountyWithThreeMilestonesId    
                    const groupId       = firstGroupId;
                    const applicantType = "group";
                    
                    const approveOrRejectOperation  = await bountyInstance.methods.completeBounty(
                        bountyId,
                        applicantType,
                        groupId
                    ).send();
                    await approveOrRejectOperation.confirmation();

                    const applicationRecord = await bountyStorage.applicationLedger.get([bountyId, { "group": groupId}]);
                    const currentMilestone = applicationRecord.currentMilestone;

                    const milestoneLogRecord = await applicationRecord.milestoneLog.get(currentMilestone);

                    // Application Record
                    assert.equal(applicationRecord.status       , "REVIEW_PENDING")

                    // Milestone Log Record
                    assert.equal(milestoneLogRecord.status      , "REVIEW_PENDING")
                    assert.equal(milestoneLogRecord.completed   , true)
                    assert.equal(milestoneLogRecord.reviewed    , false)

                } catch (e) {
                    console.log(e)
                }
            })

            it('group leader (mallory) should not be able to complete a group bounty again before it has been reviewed', async () => {
                try {

                    const bountyId      = bountyWithThreeMilestonesId    
                    const groupId       = firstGroupId;
                    const applicantType = "group";
                    
                    const failOperation  = await bountyInstance.methods.completeBounty(
                        bountyId,
                        applicantType,
                        groupId
                    );
                    await chai.expect(failOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

        })

        describe('%reviewBounty - applicant: group', function () {
            
            beforeEach("Set signer to bounty creator (alice)", async () => {
                bountyStorage = await bountyInstance.storage()
                await signerFactory(tezos, bountyCreatorSk);
            });

            it('bounty creator (alice) should be able to review and approve a completed bounty (status: REVIEW_APPROVED)', async () => {
                try {

                    const bountyId      = bountyWithThreeMilestonesId    
                    const groupId       = firstGroupId;
                    const applicantType = "group";
                    const status        = "REVIEW_APPROVED";
                    
                    const milestoneReview = "Milestone review text: rejected";
                    const bountyReview    = "Bounty review text: rejected";
                    
                    const reviewOperation  = await bountyInstance.methods.reviewBounty(
                        bountyId,
                        applicantType,
                        groupId,
                        status, 
                        milestoneReview,
                        bountyReview
                    ).send();
                    await reviewOperation.confirmation();

                    bountyStorage = await bountyInstance.storage();

                    const applicationRecord = await bountyStorage.applicationLedger.get([bountyId, { "group": groupId}]);
                    assert.equal(applicationRecord.status             , status);
                    assert.equal(applicationRecord.reviewed           , true);
                    assert.equal(applicationRecord.review             , bountyReview);

                } catch (e) {
                    console.log(e)
                }
            })

            it('bounty creator (alice) should be able to change a review of a completed bounty (status: REVIEW_REJECTED)', async () => {
                try {

                    const bountyId      = bountyWithThreeMilestonesId    
                    const groupId       = firstGroupId;
                    const applicantType = "group";
                    const status        = "REVIEW_REJECTED";
                    
                    const milestoneReview = "Milestone review text: rejected";
                    const bountyReview    = "Bounty review text: rejected";
                    
                    const reviewOperation  = await bountyInstance.methods.reviewBounty(
                        bountyId,
                        applicantType,
                        groupId,
                        status, 
                        milestoneReview,
                        bountyReview
                    ).send();
                    await reviewOperation.confirmation();

                    bountyStorage = await bountyInstance.storage();

                    const applicationRecord = await bountyStorage.applicationLedger.get([bountyId, { "group": groupId}]);
                    assert.equal(applicationRecord.status             , status);
                    assert.equal(applicationRecord.reviewed           , true);
                    assert.equal(applicationRecord.review             , bountyReview);

                } catch (e) {
                    console.log(e)
                }
            })

            it('bounty creator (alice) should not be able to set an non-valid status in a review of a completed bounty (status: REVIEW_DONE)', async () => {
                try {

                    const bountyId      = bountyWithThreeMilestonesId    
                    const groupId       = firstGroupId;
                    const applicantType = "group";
                    const status        = "REVIEW_DONE";

                    // for reference, valid review statuses are "REVIEW_APPROVED", "REVIEW_DISPUTED", "REVIEW_REJECTED"
                    
                    const milestoneReview = "Milestone review text: should fail";
                    const bountyReview    = "Bounty review text: should fail";
                    
                    const reviewOperation  = await bountyInstance.methods.reviewBounty(
                        bountyId,
                        applicantType,
                        groupId,
                        status, 
                        milestoneReview,
                        bountyReview
                    );
                    await chai.expect(reviewOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

        })

    })


    describe(`
    -----------
    Bounty Rewards test: `, function () {

        describe('%sendBountyReward - partial bounty milestone completion', function () {
            
            beforeEach("Set signer to bounty creator (alice)", async () => {
                bountyStorage = await bountyInstance.storage()
                user          = mallory.pkh;
                await signerFactory(tezos, bountyCreatorSk);
            });

            it('bounty creator (alice) should not be able to send rewards for completed bounty (zero or wrong milestone specified)', async () => {
                try {

                    const bountyId      = bountyWithThreeMilestonesId    
                    let   milestoneId   = 0;
                    const applicantType = "user";   

                    let failSendBountyRewardOperation  = await bountyInstance.methods.sendBountyReward(
                        bountyId,
                        milestoneId,
                        applicantType,
                        user
                    );
                    await chai.expect(failSendBountyRewardOperation.send()).to.be.rejected;

                    milestoneId = 999;
                    failSendBountyRewardOperation  = await bountyInstance.methods.sendBountyReward(
                        bountyId,
                        milestoneId,
                        applicantType,
                        user
                    );
                    await chai.expect(failSendBountyRewardOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it('non-bounty creator (oscar) should not be able to send rewards for completed bounty', async () => {
                try {
                    
                    await signerFactory(tezos, oscar.sk);

                    const bountyId      = bountyWithThreeMilestonesId    
                    const milestoneId   = 1;
                    const applicantType = "user";   

                    let failSendBountyRewardOperation  = await bountyInstance.methods.sendBountyReward(
                        bountyId,
                        milestoneId,
                        applicantType,
                        user
                    );
                    await chai.expect(failSendBountyRewardOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it('bounty creator (alice) should be able to send rewards to user (mallory) for completed bounty', async () => {
                try {

                    const bountyId      = bountyWithThreeMilestonesId    
                    const milestoneId   = 1;
                    const applicantType = "user";   

                    const sendBountyRewardOperation  = await bountyInstance.methods.sendBountyReward(
                        bountyId,
                        milestoneId,
                        applicantType,
                        user
                    ).send();
                    await sendBountyRewardOperation.confirmation();

                } catch (e) {
                    console.log(e)
                }
            })

        })


        describe('%sendBountyReward - full bounty completion', function () {
            
            beforeEach("Set signer to bounty creator (alice)", async () => {
                bountyStorage = await bountyInstance.storage()
                user          = mallory.pkh;
                await signerFactory(tezos, bountyCreatorSk);
            });

            it('non-bounty creator (oscar) should not be able to send rewards for completed bounty', async () => {
                try {
                    
                    await signerFactory(tezos, oscar.sk);

                    const bountyId      = bountyWithNoMilestonesId    
                    const milestoneId   = null;
                    const applicantType = "user";   

                    let failSendBountyRewardOperation  = await bountyInstance.methods.sendBountyReward(
                        bountyId,
                        milestoneId,
                        applicantType,
                        user
                    );
                    await chai.expect(failSendBountyRewardOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it('bounty creator (alice) should be able to send rewards to user (mallory) for completed bounty', async () => {
                try {

                    const bountyId      = bountyWithNoMilestonesId    
                    const milestoneId   = null;
                    const applicantType = "user";   

                    // get initial balances
                    const userMockFa12Ledger                 = await mockFa12TokenStorage.ledger.get(user);            
                    const userMockFa2Ledger                  = await mockFa2TokenStorage.ledger.get(user);       

                    const userInitialMockFa12TokenBalance    = userMockFa12Ledger == undefined ? 0 : userMockFa12Ledger.balance.toNumber();     
                    const userInitialMockFa2TokenBalance     = userMockFa2Ledger == undefined ? 0 : userMockFa2Ledger.toNumber();
                    const userInitialTezBalance              = await utils.tezos.tz.getBalance(user);

                    const mockFa12TokenRewards  = mockBountyRewardAmounts.bountyOneReward.mockFa12;
                    const mockFa2TokenRewards   = mockBountyRewardAmounts.bountyOneReward.mockFa2;
                    const mutezRewards          = mockBountyRewardAmounts.bountyOneReward.tez;

                    const sendBountyRewardOperation  = await bountyInstance.methods.sendBountyReward(
                        bountyId,
                        milestoneId,
                        applicantType,
                        user
                    ).send();
                    await sendBountyRewardOperation.confirmation();

                    bountyStorage           = await bountyInstance.storage();
                    mockFa12TokenStorage    = await mockFa12TokenInstance.storage();
                    mockFa2TokenStorage     = await mockFa2TokenInstance.storage();

                    const userUpdatedMockFa12Ledger          = await mockFa12TokenStorage.ledger.get(user);            
                    const userUpdatedMockFa2Ledger           = await mockFa2TokenStorage.ledger.get(user);       

                    const userUpdatedMockFa12TokenBalance    = userUpdatedMockFa12Ledger == undefined ? 0 : userUpdatedMockFa12Ledger.balance.toNumber();     
                    const userUpdatedMockFa2TokenBalance     = userUpdatedMockFa2Ledger == undefined ? 0 : userUpdatedMockFa2Ledger.toNumber();
                    const userUpdatedTezBalance              = await utils.tezos.tz.getBalance(user);

                    assert.equal(userUpdatedMockFa12TokenBalance    , userInitialMockFa12TokenBalance + mockFa12TokenRewards);
                    assert.equal(userUpdatedMockFa2TokenBalance     , userInitialMockFa2TokenBalance + mockFa2TokenRewards);
                    assert.equal(almostEqual(userUpdatedTezBalance  , userInitialTezBalance.toNumber() + mutezRewards, 0.001), true);

                } catch (e) {
                    console.log(e)
                }
            })

        })

    })

})
