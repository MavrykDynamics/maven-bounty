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
    signerFactory, 
    getStorageMapValue,
    makeTimestamp,
    updateOperators
} from './helpers/helperFunctions'


// ------------------------------------------------------------------------------
// Contract Notes
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Contract Tests
// ------------------------------------------------------------------------------

describe('Test: Marketplace Contract', async () => {

    // default
    let utils: Utils
    let tezos

    // misc defaults
    let tokenId = 0
    let tokenAmount
    let operator
    let operatorKey

    // contract instances 
    let tokenRegistryAddress
    let tokenRegistryInstance
    let tokenRegistryStorage
    
    let marketplaceAddress
    let marketplaceInstance
    let marketplaceStorage

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

    let currencyRecord
    let listingRecord
    let offerRecord

    let listingId
    let firstListingId
    let secondListingId

    // contract map value
    let storageMap
    let contractMapKey
    let initialContractMapValue
    let updatedContractMapValue

    // operations
    let transferOperation
    let mistakenTransferOperation
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

        tokenRegistryAddress            = contractDeployments.tokenRegistry.address
        tokenRegistryInstance           = await utils.tezos.contract.at(tokenRegistryAddress)
        tokenRegistryStorage            = await tokenRegistryInstance.storage()

        marketplaceAddress              = contractDeployments.marketplace.address
        marketplaceInstance             = await utils.tezos.contract.at(marketplaceAddress)
        marketplaceStorage              = await marketplaceInstance.storage()

        mockFa12TokenAddress            = contractDeployments.mockFa12Token.address;
        mockFa12TokenInstance           = await utils.tezos.contract.at(mockFa12TokenAddress)
        mockFa12TokenStorage            = await mockFa12TokenInstance.storage()

        mockFa2TokenAddress             = contractDeployments.mockFa2Token.address;
        mockFa2TokenInstance            = await utils.tezos.contract.at(mockFa2TokenAddress);
        mockFa2TokenStorage             = await mockFa2TokenInstance.storage()

        console.log('-- -- -- -- -- -- -- -- -- -- -- -- --')

    })

    beforeEach('storage', async () => {
        marketplaceStorage            = await marketplaceInstance.storage()
    })

    describe('%setCurrency', function () {
        
        beforeEach("Set signer to admin (eve)", async () => {
            marketplaceStorage = await marketplaceInstance.storage()
            await signerFactory(tezos, adminSk);
        });

        it('admin (eve) should be able to set Mock FA12 token as a currency', async () => {
            try {

                const actionType                = "update";
                const newCurrencyType           = "fa12Token";
                const newCurrencyTokenAddress   = mockFa12TokenAddress;

                currencyRecord = await marketplaceStorage.currencyLedger.get(newCurrencyTokenAddress);

                if(currencyRecord == undefined || currencyRecord == null ) {

                    // set currency operation
                    const setCurrencyOperation = await marketplaceInstance.methods.setCurrency(
                        actionType,
                        newCurrencyType,
                        newCurrencyTokenAddress
                    ).send()
                    await setCurrencyOperation.confirmation();

                    marketplaceStorage    = await marketplaceInstance.storage()
                    currencyRecord        = await marketplaceStorage.currencyLedger.get(newCurrencyTokenAddress);

                    assert.notEqual(currencyRecord                     , null);
                    assert.equal(currencyRecord.tokenType              , "FA12");
                    assert.equal(currencyRecord.tokenIds.length        , 0);
                }

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should be able to remove Mock FA12 token as a currency', async () => {
            try {

                const actionType                = "remove";
                const newCurrencyType           = "fa12Token";
                const newCurrencyTokenAddress   = mockFa12TokenAddress;

                // set currency operation
                const setCurrencyOperation = await marketplaceInstance.methods.setCurrency(
                    actionType,
                    newCurrencyType,
                    newCurrencyTokenAddress
                ).send()
                await setCurrencyOperation.confirmation();

                marketplaceStorage    = await marketplaceInstance.storage()
                currencyRecord        = await marketplaceStorage.currencyLedger.get(newCurrencyTokenAddress);

                assert.equal(currencyRecord, null);
            

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should be able to set Mock FA2 token as a currency', async () => {
            try {

                const actionType                = "update";
                const newCurrencyType           = "fa2Token";
                const newCurrencyTokenAddress   = mockFa2TokenAddress;
                const newCurrencyTokenId        = 22;

                currencyRecord = await marketplaceStorage.currencyLedger.get(newCurrencyTokenAddress);

                if(currencyRecord == undefined || currencyRecord == null ) {

                    // set currency operation
                    const setCurrencyOperation = await marketplaceInstance.methods.setCurrency(
                        actionType,
                        newCurrencyType,
                        newCurrencyTokenAddress,
                        newCurrencyTokenId
                    ).send()
                    await setCurrencyOperation.confirmation();

                    marketplaceStorage    = await marketplaceInstance.storage()
                    currencyRecord        = await marketplaceStorage.currencyLedger.get(newCurrencyTokenAddress);

                    assert.notEqual(currencyRecord                     , null);
                    assert.equal(currencyRecord.tokenType              , "FA2");
                    assert.equal(currencyRecord.tokenIds.length        , 1);
                    assert.equal(currencyRecord.tokenIds[0]            , 22);
                }

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should be able to remove Mock FA2 token as a currency', async () => {
            try {

                const actionType                = "remove";
                const newCurrencyType           = "fa2Token";
                const newCurrencyTokenAddress   = mockFa2TokenAddress;
                const newCurrencyTokenId        = 22;

                // set currency operation
                const setCurrencyOperation = await marketplaceInstance.methods.setCurrency(
                    actionType,
                    newCurrencyType,
                    newCurrencyTokenAddress,
                    newCurrencyTokenId
                ).send()
                await setCurrencyOperation.confirmation();

                marketplaceStorage    = await marketplaceInstance.storage()
                currencyRecord        = await marketplaceStorage.currencyLedger.get(newCurrencyTokenAddress);

                assert.equal(currencyRecord, null);
            

            } catch (e) {
                console.log(e)
            }
        })

        it('setup Mock FA12 token and Mock FA2 token as currency', async () => {
            try {

                let actionType                = "update";
                let newCurrencyType           = "fa12Token";
                let newCurrencyTokenAddress   = mockFa12TokenAddress;

                currencyRecord = await marketplaceStorage.currencyLedger.get(newCurrencyTokenAddress);

                if(currencyRecord == undefined || currencyRecord == null ) {

                    // set currency operation
                    const setCurrencyOperation = await marketplaceInstance.methods.setCurrency(
                        actionType,
                        newCurrencyType,
                        newCurrencyTokenAddress
                    ).send()
                    await setCurrencyOperation.confirmation();

                    marketplaceStorage    = await marketplaceInstance.storage()
                    currencyRecord        = await marketplaceStorage.currencyLedger.get(newCurrencyTokenAddress);

                    assert.notEqual(currencyRecord                     , null);
                    assert.equal(currencyRecord.tokenType              , "FA12");
                    assert.equal(currencyRecord.tokenIds.length        , 0);
                }

                newCurrencyType           = "fa2Token";
                newCurrencyTokenAddress   = mockFa2TokenAddress;
                let newCurrencyTokenId    = 0;

                currencyRecord = await marketplaceStorage.currencyLedger.get(newCurrencyTokenAddress);

                if(currencyRecord == undefined || currencyRecord == null ) {

                    // set currency operation
                    const setCurrencyOperation = await marketplaceInstance.methods.setCurrency(
                        actionType,
                        newCurrencyType,
                        newCurrencyTokenAddress,
                        newCurrencyTokenId
                    ).send()
                    await setCurrencyOperation.confirmation();

                    marketplaceStorage    = await marketplaceInstance.storage()
                    currencyRecord        = await marketplaceStorage.currencyLedger.get(newCurrencyTokenAddress);

                    assert.notEqual(currencyRecord                     , null);
                    assert.equal(currencyRecord.tokenType              , "FA2");
                    assert.equal(currencyRecord.tokenIds.length        , 1);
                    assert.equal(currencyRecord.tokenIds[0]            , newCurrencyTokenId);
                }

            } catch (e) {
                console.log(e)
            }
        })

    })

    describe('%createListing', function () {
        
        beforeEach("Set signer to user (mallory)", async () => {
            user    = mallory.pkh;
            userSk  = mallory.sk;
            await signerFactory(tezos, userSk);

            marketplaceStorage    = await marketplaceInstance.storage()
        });

        it('user (mallory) should be able to set create a new mockFa2 Token listing [no expiry, currency: tez]', async () => {
            try {

                listingId                   = marketplaceStorage.nextListingId;
                firstListingId              = listingId;
                const amount                = 22;
                const price                 = 3;
                const expiryTime            = null;
                const listTokenType         = "fa2Token";
                const listToken             = mockFa2TokenAddress;
                const listTokenId           = 0;
                const currencyTokenType     = "fa12";
                const currencyTokenAddress  = mockFa12TokenAddress;

                // update operators operation
                updateOperatorsOperation = await updateOperators(mockFa2TokenInstance, user, marketplaceAddress, tokenId);
                await updateOperatorsOperation.confirmation();

                // create listing operation
                const createListingOperation = await marketplaceInstance.methods.createListing(
                    amount,
                    price,
                    expiryTime,
                    listTokenType,
                    listToken,
                    listTokenId,
                    currencyTokenType,
                    currencyTokenAddress
                ).send()
                await createListingOperation.confirmation();

                marketplaceStorage    = await marketplaceInstance.storage()
                listingRecord         = await marketplaceStorage.listingLedger.get(listingId);

                assert.notEqual(listingRecord                       , null);
                assert.equal(listingRecord.initiator                , user);
                assert.equal(listingRecord.price                    , price);
                assert.equal(listingRecord.amount                   , amount);
                assert.equal(listingRecord.expiryTime               , null);

            } catch (e) {
                console.log(e)
            }
        })

        it('user (mallory) should be able to set create a new mockFa2 Token listing [expiry in 3 mins, currency: tez]', async () => {
            try {

                listingId                   = marketplaceStorage.nextListingId;
                secondListingId             = listingId;
                const amount                = 22;
                const price                 = 3;
                const listTokenType         = "fa2Token";
                const listToken             = mockFa2TokenAddress;
                const listTokenId           = 0;
                const currencyTokenType     = "fa12";
                const currencyTokenAddress  = mockFa12TokenAddress;

                // get timestamp in 3mins
                const expiryTime = makeTimestamp(180);

                // create listing operation
                const createListingOperation = await marketplaceInstance.methods.createListing(
                    amount,
                    price,
                    expiryTime,
                    listTokenType,
                    listToken,
                    listTokenId,
                    currencyTokenType,
                    currencyTokenAddress
                ).send()
                await createListingOperation.confirmation();

                marketplaceStorage    = await marketplaceInstance.storage()
                listingRecord         = await marketplaceStorage.listingLedger.get(listingId);

                assert.notEqual(listingRecord                       , null);
                assert.equal(listingRecord.initiator                , user);
                assert.equal(listingRecord.price                    , price);
                assert.equal(listingRecord.amount                   , amount);
                assert.equal(listingRecord.expiryTime               , expiryTime);

            } catch (e) {
                console.log(e)
            }
        })

    })


    describe('%removeListing', function () {
        
        beforeEach("Set signer to user (mallory)", async () => {
            user    = mallory.pkh;
            userSk  = mallory.sk;
            await signerFactory(tezos, userSk);

            marketplaceStorage    = await marketplaceInstance.storage()
        });

        it('user (mallory) should be able to remove her listing', async () => {
            try {

                // check listing record exists
                listingRecord         = await marketplaceStorage.listingLedger.get(firstListingId);
                assert.notEqual(listingRecord, null);

                // remove listing operation
                const removeListingOperation = await marketplaceInstance.methods.removeListing(
                    firstListingId
                ).send()
                await removeListingOperation.confirmation();

                // check listing record is removed
                marketplaceStorage    = await marketplaceInstance.storage()
                listingRecord         = await marketplaceStorage.listingLedger.get(firstListingId);
                assert.equal(listingRecord, null);

            } catch (e) {
                console.log(e)
            }
        })

        it('user (mallory) should not be able to remove her listing twice', async () => {
            try {

                // check listing record exists
                listingRecord         = await marketplaceStorage.listingLedger.get(firstListingId);
                assert.equal(listingRecord, null);

                // remove listing operation
                const removeListingOperation = await marketplaceInstance.methods.removeListing(
                    firstListingId
                );
                await chai.expect(removeListingOperation.send()).to.be.rejected;

                // check listing record is removed
                marketplaceStorage    = await marketplaceInstance.storage()
                listingRecord         = await marketplaceStorage.listingLedger.get(firstListingId);
                assert.equal(listingRecord, null);

            } catch (e) {
                console.log(e)
            }
        })

        it('user (alice) should not be able to remove a listing that she does not own', async () => {
            try {

                await signerFactory(tezos, alice.sk);

                // check listing record exists
                listingRecord         = await marketplaceStorage.listingLedger.get(secondListingId);
                assert.equal(listingRecord, null);

                // remove listing operation
                const removeListingOperation = await marketplaceInstance.methods.removeListing(
                    secondListingId
                );
                await chai.expect(removeListingOperation.send()).to.be.rejected;

                // check listing record is removed
                marketplaceStorage    = await marketplaceInstance.storage()
                listingRecord         = await marketplaceStorage.listingLedger.get(secondListingId);
                assert.equal(listingRecord, null);

            } catch (e) {
                console.log(e)
            }
        })

    })
    
    describe('%removeListing', function () {
        
        beforeEach("Set signer to user (mallory)", async () => {
            user    = mallory.pkh;
            userSk  = mallory.sk;
            await signerFactory(tezos, userSk);

            marketplaceStorage    = await marketplaceInstance.storage()
        });

    })
    
})
