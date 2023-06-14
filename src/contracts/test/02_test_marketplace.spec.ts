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
    signerFactory, 
    getStorageMapValue,
    makeTimestamp,
    showMillisecondsDateFormat,
    updateOperators,
    getTokenInfo,
    calculateRoyaltyFee,
    currencyType
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

    // config
    let royalty
    let treasuryAddress

    // misc defaults
    let tokenId = 0
    let tokenAmount
    let tokenDecimals
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

    let securityTokenAddress 
    let securityTokenInstance
    let securityTokenStorage
    
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
    let thirdListingId

    let offerId
    let firstOfferId
    let secondOfferId
    let thirdOfferId

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

        tokenDecimals   = 6;

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

        securityTokenAddress            = contractDeployments.securityToken.address;
        securityTokenInstance           = await utils.tezos.contract.at(securityTokenAddress);
        securityTokenStorage            = await securityTokenInstance.storage()

        console.log('-- -- -- -- -- -- -- -- -- -- -- -- --')

        // marketplace config 
        royalty = marketplaceStorage.config.royalty;

        const marketplaceGeneralContracts   = await marketplaceInstance.contractViews.getGeneralContracts().executeView({ viewCaller : eve.pkh});
        treasuryAddress                     = marketplaceGeneralContracts.get('treasury');

        // Set Token Metadata and Initialise Security Token

        const checkTokenMetadataExists = await securityTokenInstance.contractViews.token_metadata(0).executeView({ viewCaller : eve.pkh});
        
        if(checkTokenMetadataExists == undefined){

            await signerFactory(tezos, eve.sk);
            const setTokenMetadataOperation = await securityTokenInstance.methods.setTokenMetadata([
                {
                    token_id : 0,
                    token_info : new MichelsonMap()
                }
            ]).send();
            await setTokenMetadataOperation.confirmation();

            const initialiseTokenOperation = await securityTokenInstance.methods.initialiseToken([0]).send();
            await initialiseTokenOperation.confirmation();

            // Mint Security Tokens to Alice, Eve, Mallory
            await signerFactory(tezos, eve.sk);
            let mintOperation = await securityTokenInstance.methods.mint([
                {
                    token_id : 0,
                    amount : 500,
                    address : mallory.pkh 
                },
                {
                    token_id : 0,
                    amount : 500,
                    address : eve.pkh 
                },
                {
                    token_id : 0,
                    amount : 500,
                    address : alice.pkh 
                }
            ]).send();
            await mintOperation.confirmation();
        }

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

                // assert.equal(currencyRecord, null);
            
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

        it('user (mallory) should be able to set create a new Security Token listing [no expiry, currency: tez]', async () => {
            try {

                listingId                   = marketplaceStorage.nextListingId;
                firstListingId              = listingId;

                const amount                = 22;
                const price                 = 3000000;
                const expiryTime            = null;
                const listTokenType         = "fa2Token";
                const listToken             = securityTokenAddress;
                const listTokenId           = 0;
                const currencyTokenType     = "fa2";
                const currencyTokenAddress  = mockFa2TokenAddress;
                const currencyTokenId       = 0;

                // update operators operation
                updateOperatorsOperation = await updateOperators(mockFa2TokenInstance, user, marketplaceAddress, currencyTokenId);
                await updateOperatorsOperation.confirmation();

                updateOperatorsOperation = await updateOperators(securityTokenInstance, user, marketplaceAddress, listTokenId);
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
                    currencyTokenAddress,
                    currencyTokenId
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

        it('user (mallory) should be able to set create a new Security Token listing [expiry in 3 mins, currency: tez]', async () => {
            try {

                listingId                   = marketplaceStorage.nextListingId;
                secondListingId             = listingId;

                const amount                = 22;
                const price                 = 3000000;
                const listTokenType         = "fa2Token";
                const listToken             = securityTokenAddress;
                const listTokenId           = 0;
                const currencyTokenType     = "fa2";
                const currencyTokenAddress  = mockFa2TokenAddress;
                const currencyTokenId       = 0;

                // get timestamp in 3mins
                const expiryTime = makeTimestamp(180);

                // update operators operation
                updateOperatorsOperation = await updateOperators(mockFa2TokenInstance, user, marketplaceAddress, currencyTokenId);
                await updateOperatorsOperation.confirmation();

                updateOperatorsOperation = await updateOperators(securityTokenInstance, user, marketplaceAddress, listTokenId);
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
                    currencyTokenAddress,
                    currencyTokenId
                ).send()
                await createListingOperation.confirmation();

                marketplaceStorage    = await marketplaceInstance.storage()
                listingRecord         = await marketplaceStorage.listingLedger.get(listingId);

                assert.notEqual(listingRecord                       , null);
                assert.equal(listingRecord.initiator                , user);
                assert.equal(listingRecord.price                    , price);
                assert.equal(listingRecord.amount                   , amount);
                assert.equal(listingRecord.expiryTime               , showMillisecondsDateFormat(expiryTime));

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
                assert.notEqual(listingRecord, null);

                // remove listing operation
                const removeListingOperation = await marketplaceInstance.methods.removeListing(
                    secondListingId
                );
                await chai.expect(removeListingOperation.send()).to.be.rejected;

                // check listing record is not removed
                marketplaceStorage    = await marketplaceInstance.storage()
                listingRecord         = await marketplaceStorage.listingLedger.get(secondListingId);
                assert.notEqual(listingRecord, null);

            } catch (e) {
                console.log(e)
            }
        })

    })
    
    describe('%purchase', function () {
        
        beforeEach("Set signer to user (alice)", async () => {
            user    = alice.pkh;
            userSk  = alice.sk;
            await signerFactory(tezos, userSk);

            marketplaceStorage    = await marketplaceInstance.storage()
        });

        it(`user (alice) should be able to purchase mallory's listing`, async () => {
            try {

                const buyer     = alice.pkh;
                const buyerSk   = alice.sk;
                await signerFactory(tezos, buyerSk);

                // check listing record exists
                listingRecord = await marketplaceStorage.listingLedger.get(secondListingId);
                assert.notEqual(listingRecord, null);

                const seller      = listingRecord.initiator;
                const amount      = listingRecord.amount;
                const price       = listingRecord.price;
                const currency    = listingRecord.currency;

                const royaltyFee            = calculateRoyaltyFee(price, royalty);
                const priceLessRoyalty      = price - royaltyFee

                const currencyTokenAddress  = getTokenInfo(currency, "tokenContractAddress");
                const currencyTokenId       = getTokenInfo(currency, "tokenId");

                // get current user balance for currency 
                let tokenStorage                           = await mockFa2TokenInstance.storage()
                const initialBuyerCurrencyTokenBalance     = await tokenStorage.ledger.get(buyer);
                const initialSellerCurrencyTokenBalance    = await tokenStorage.ledger.get(seller);
                const initialTreasuryCurrencyTokenBalance  = await tokenStorage.ledger.get(treasuryAddress);

                let securityTokenStorage                = await securityTokenInstance.storage()
                const initialBuyerSecurityTokenBalance   = await securityTokenStorage.ledger.get({owner : buyer, token_id : 0});
                
                // update operators operation
                updateOperatorsOperation = await updateOperators(mockFa2TokenInstance, user, marketplaceAddress, currencyTokenId);
                await updateOperatorsOperation.confirmation();

                // purhcase operation
                const purchaseOperation = await marketplaceInstance.methods.purchase(
                    secondListingId
                ).send();
                await purchaseOperation.confirmation();

                // check listing record is removed (purchased)
                marketplaceStorage    = await marketplaceInstance.storage()
                listingRecord         = await marketplaceStorage.listingLedger.get(secondListingId);
                assert.equal(listingRecord, null);

                tokenStorage                              = await mockFa2TokenInstance.storage()
                const updatedBuyerCurrencyTokenBalance    = await tokenStorage.ledger.get(buyer);
                const updatedSellerCurrencyTokenBalance   = await tokenStorage.ledger.get(seller);
                const updatedTreasuryCurrencyTokenBalance = await tokenStorage.ledger.get(treasuryAddress);

                securityTokenStorage                      = await securityTokenInstance.storage()
                const updatedBuyerSecurityTokenBalance    = await securityTokenStorage.ledger.get({owner : buyer, token_id : 0});

                // buyer receives correct amount of security token in listing 
                assert.equal(+updatedBuyerSecurityTokenBalance, +initialBuyerSecurityTokenBalance + +amount);
                
                // buyer pays the price listed by seller
                assert.equal(+updatedBuyerCurrencyTokenBalance, +initialBuyerCurrencyTokenBalance - +price);

                // seller receives the price less royalty
                assert.equal(+updatedSellerCurrencyTokenBalance, +initialSellerCurrencyTokenBalance + +priceLessRoyalty);

                // treasury receives royalty fee
                assert.equal(+updatedTreasuryCurrencyTokenBalance, +initialTreasuryCurrencyTokenBalance + +royaltyFee);

            } catch (e) {
                console.log(e)
            }
        })

        it(`user (eve) should not be able to purchase mallory's listing if it has already been purchased`, async () => {
            try {

                const buyer     = eve.pkh;
                const buyerSk   = eve.sk;
                await signerFactory(tezos, buyerSk);

                // check listing record exists
                listingRecord = await marketplaceStorage.listingLedger.get(secondListingId);
                assert.equal(listingRecord, null);

                // purhcase operation
                const purchaseOperation = await marketplaceInstance.methods.purchase(
                    secondListingId
                );
                await chai.expect(purchaseOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

    })

    describe('%offer', function () {
        
        before("Setup another listing", async () => {
            user    = mallory.pkh;
            userSk  = mallory.sk;
            await signerFactory(tezos, userSk);

            marketplaceStorage    = await marketplaceInstance.storage()
            listingId                   = marketplaceStorage.nextListingId;
            thirdListingId              = listingId;

            const amount                = 20;
            const price                 = 3000000;
            const expiryTime            = null;
            const listTokenType         = "fa2Token";
            const listToken             = securityTokenAddress;
            const listTokenId           = 0;
            const currencyTokenType     = "fa2";
            const currencyTokenAddress  = mockFa2TokenAddress;
            const currencyTokenId       = 0;

            // update operators operation
            updateOperatorsOperation = await updateOperators(mockFa2TokenInstance, user, marketplaceAddress, currencyTokenId);
            await updateOperatorsOperation.confirmation();

            updateOperatorsOperation = await updateOperators(securityTokenInstance, user, marketplaceAddress, listTokenId);
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
                currencyTokenAddress,
                currencyTokenId
            ).send()
            await createListingOperation.confirmation();

            marketplaceStorage    = await marketplaceInstance.storage()
            listingRecord         = await marketplaceStorage.listingLedger.get(listingId);

            assert.notEqual(listingRecord                       , null);
            assert.equal(listingRecord.initiator                , user);
            assert.equal(listingRecord.price                    , price);
            assert.equal(listingRecord.amount                   , amount);
            assert.equal(listingRecord.expiryTime               , null);
            
        });

        beforeEach("Set signer to user (alice)", async () => {
            user    = alice.pkh;
            userSk  = alice.sk;
            await signerFactory(tezos, userSk);

            marketplaceStorage    = await marketplaceInstance.storage()
        });

        it('user (alice) should be able to make an offer on a listing [no expiry | currency: Mock FA2 Token]', async () => {
            try {

                listingId       = thirdListingId
                offerId         = marketplaceStorage.nextOfferId;
                firstOfferId    = offerId // for subsequent test

                // check listing record exists
                listingRecord         = await marketplaceStorage.listingLedger.get(listingId);
                assert.notEqual(listingRecord, null);

                const offerPrice            = 1000000;
                const expiryTime            = null;
                const currencyTokenType     = "fa2";
                const currencyTokenAddress  = mockFa2TokenAddress;
                const currencyTokenId       = 0;

                // make offer operation
                const makeOfferOperation = await marketplaceInstance.methods.offer(
                    listingId,
                    offerPrice,
                    expiryTime,
                    currencyTokenType,
                    currencyTokenAddress,
                    currencyTokenId
                ).send()
                await makeOfferOperation.confirmation();

                // check offer record is created
                marketplaceStorage    = await marketplaceInstance.storage()
                offerRecord           = await marketplaceStorage.offerLedger.get(offerId);
                assert.notEqual(offerRecord, null);

                assert.equal(offerRecord.initiator   , user);
                assert.equal(+offerRecord.listingId  , +listingId);
                assert.equal(offerRecord.price       , offerPrice);
                assert.equal(offerRecord.expiryTime  , expiryTime);

                assert.equal(getTokenInfo(offerRecord.currency, "tokenContractAddress"), currencyTokenAddress);
                assert.equal(getTokenInfo(offerRecord.currency, "tokenId"), currencyTokenId);

            } catch (e) {
                console.log(e)
            }
        })

        it('multiple users (eve, oscar) should be able to make an offer on a listing [no expiry | currency: Mock FA2 Token]', async () => {
            try {

                listingId = thirdListingId
                offerId   = marketplaceStorage.nextOfferId;
                secondOfferId = offerId;

                // check listing record exists
                listingRecord         = await marketplaceStorage.listingLedger.get(listingId);
                assert.notEqual(listingRecord, null);

                // make offer by first user
                const firstUser     = eve.pkh;
                const firstUserSk   = eve.sk;
                await signerFactory(tezos, firstUserSk);

                let offerPrice            = 500000;
                let expiryTime            = null;
                let currencyTokenType     = "fa2";
                let currencyTokenAddress  = mockFa2TokenAddress;
                let currencyTokenId       = 0;

                // update operators operation
                updateOperatorsOperation = await updateOperators(mockFa2TokenInstance, firstUser, marketplaceAddress, currencyTokenId);
                await updateOperatorsOperation.confirmation();

                // make offer operation
                let makeOfferOperation = await marketplaceInstance.methods.offer(
                    listingId,
                    offerPrice,
                    expiryTime,
                    currencyTokenType,
                    currencyTokenAddress,
                    currencyTokenId
                ).send()
                await makeOfferOperation.confirmation();

                // check offer record is created
                marketplaceStorage    = await marketplaceInstance.storage()
                offerRecord           = await marketplaceStorage.offerLedger.get(offerId);
                assert.notEqual(offerRecord, null);

                assert.equal(offerRecord.initiator   , firstUser);
                assert.equal(+offerRecord.listingId  , +listingId);
                assert.equal(offerRecord.price       , offerPrice);
                assert.equal(offerRecord.expiryTime  , expiryTime);

                assert.equal(getTokenInfo(offerRecord.currency, "tokenContractAddress"), currencyTokenAddress);
                assert.equal(getTokenInfo(offerRecord.currency, "tokenId"), currencyTokenId);

                // make offer by second user
                const secondUser     = eve.pkh;
                const secondUserSk   = eve.sk;
                await signerFactory(tezos,secondUserSk);

                marketplaceStorage    = await marketplaceInstance.storage()
                offerId               = marketplaceStorage.nextOfferId;
                thirdOfferId          = offerId;

                offerPrice            = 750000;
                expiryTime            = makeTimestamp(180);
                currencyTokenType     = "fa2";
                currencyTokenAddress  = mockFa2TokenAddress;
                currencyTokenId       = 0;

                // update operators operation
                updateOperatorsOperation = await updateOperators(mockFa2TokenInstance, secondUser, marketplaceAddress, currencyTokenId);
                await updateOperatorsOperation.confirmation();

                // make offer operation
                makeOfferOperation = await marketplaceInstance.methods.offer(
                    listingId,
                    offerPrice,
                    expiryTime,
                    currencyTokenType,
                    currencyTokenAddress,
                    currencyTokenId
                ).send()
                await makeOfferOperation.confirmation();

                // check offer record is created
                marketplaceStorage    = await marketplaceInstance.storage()
                offerRecord           = await marketplaceStorage.offerLedger.get(offerId);
                assert.notEqual(offerRecord, null);

                assert.equal(offerRecord.initiator   , secondUser);
                assert.equal(+offerRecord.listingId  , +listingId);
                assert.equal(offerRecord.price       , offerPrice);
                assert.equal(offerRecord.expiryTime  , showMillisecondsDateFormat(expiryTime));

                assert.equal(getTokenInfo(offerRecord.currency, "tokenContractAddress"), currencyTokenAddress);
                assert.equal(getTokenInfo(offerRecord.currency, "tokenId"), currencyTokenId);

            } catch (e) {
                console.log(e)
            }
        })

    })

    describe('%acceptOffer', function () {
        
        beforeEach("Set signer to lister (mallory)", async () => {
            user    = mallory.pkh;
            userSk  = mallory.sk;
            await signerFactory(tezos, userSk);

            marketplaceStorage    = await marketplaceInstance.storage()
        });

        it('user (mallory) should not be able to accept a non-existent offer', async () => {
            try {

                listingId       = thirdListingId
                offerId         = marketplaceStorage.nextOfferId;

                // check listing record exists
                listingRecord         = await marketplaceStorage.listingLedger.get(listingId);
                assert.notEqual(listingRecord, null);

                // accept offer operation
                const acceptOfferOperation = await marketplaceInstance.methods.acceptOffer(
                    offerId
                );
                await chai.expect(acceptOfferOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

        it('user (mallory) should be able to accept an offer on his listing', async () => {
            try {

                const lister     = mallory.pkh;
                const listerSk   = mallory.sk;
                await signerFactory(tezos, listerSk);
                
                listingId       = thirdListingId
                offerId         = firstOfferId;

                // check listing record exists
                listingRecord         = await marketplaceStorage.listingLedger.get(listingId);
                assert.notEqual(listingRecord, null);

                // security token amount
                const amount = listingRecord.amount;

                // check offer record exists
                offerRecord           = await marketplaceStorage.offerLedger.get(offerId);
                assert.notEqual(offerRecord, null);

                const offerer               = offerRecord.initiator
                const price                 = offerRecord.price
                const currency              = offerRecord.currency
                const currencyTokenAddress  = getTokenInfo(currency, "tokenContractAddress")
                const currencyTokenId       = getTokenInfo(currency, "tokenId")

                const royaltyFee            = calculateRoyaltyFee(price, royalty);
                const priceLessRoyalty      = price - royaltyFee

                // get current user balance for currency 
                let tokenStorage                           = await mockFa2TokenInstance.storage()
                const initialListerCurrencyTokenBalance    = await tokenStorage.ledger.get(lister);
                const initialTreasuryCurrencyTokenBalance  = await tokenStorage.ledger.get(treasuryAddress);

                let securityTokenStorage                   = await securityTokenInstance.storage()
                const initialOffererSecurityTokenBalance   = await securityTokenStorage.ledger.get({owner : offerer, token_id : 0});
                
                // accept offer operation
                const acceptOfferOperation = await marketplaceInstance.methods.acceptOffer(
                    offerId
                ).send();
                await acceptOfferOperation.confirmation();

                // check listing record is removed (purchased)
                marketplaceStorage    = await marketplaceInstance.storage()
                listingRecord         = await marketplaceStorage.listingLedger.get(listingId);
                assert.equal(listingRecord, null);

                tokenStorage                              = await mockFa2TokenInstance.storage()
                const updatedListerCurrencyTokenBalance   = await tokenStorage.ledger.get(lister);
                const updatedTreasuryCurrencyTokenBalance = await tokenStorage.ledger.get(treasuryAddress);

                securityTokenStorage                      = await securityTokenInstance.storage()
                const updatedOffererSecurityTokenBalance  = await securityTokenStorage.ledger.get({owner : offerer, token_id : 0});

                console.log(`amount: ${amount}`);
                console.log(`price: ${price}`);

                console.log(`royaltyFee: ${royaltyFee}`);
                console.log(`priceLessRoyalty: ${priceLessRoyalty}`);
                
                console.log(`initialOffererSecurityTokenBalance: ${initialOffererSecurityTokenBalance}`);
                console.log(`updatedOffererSecurityTokenBalance: ${updatedOffererSecurityTokenBalance}`);
                console.log(`updatedOffererSecurityTokenBalance - initialOffererSecurityTokenBalance: ${updatedOffererSecurityTokenBalance - initialOffererSecurityTokenBalance}`);

                console.log(`initialListerCurrencyTokenBalance: ${initialListerCurrencyTokenBalance}`);
                console.log(`updatedListerCurrencyTokenBalance: ${updatedListerCurrencyTokenBalance}`);
                console.log(`updatedListerCurrencyTokenBalance - initialListerCurrencyTokenBalance: ${+updatedListerCurrencyTokenBalance - +initialListerCurrencyTokenBalance}`);
                console.log(`initialListerCurrencyTokenBalance + priceLessRoyalty: ${+initialListerCurrencyTokenBalance + +priceLessRoyalty}`);

                // offerer receives correct amount of security token in listing 
                assert.equal(+updatedOffererSecurityTokenBalance, +initialOffererSecurityTokenBalance + +amount);

                // lister receives the price less royalty
                assert.equal(+updatedListerCurrencyTokenBalance, +initialListerCurrencyTokenBalance + +priceLessRoyalty);

                // treasury receives royalty fee
                assert.equal(+updatedTreasuryCurrencyTokenBalance, +initialTreasuryCurrencyTokenBalance + +royaltyFee);

            } catch (e) {
                console.log(e)
            }
        })

        it('user (mallory) should not be able to accept another offer on his listing', async () => {
            try {

                listingId       = thirdListingId
                offerId         = secondListingId

                // listing record should no longer exist
                listingRecord         = await marketplaceStorage.listingLedger.get(listingId);
                assert.equal(listingRecord, null);

                // accept offer operation
                const acceptOfferOperation = await marketplaceInstance.methods.acceptOffer(
                    offerId
                );
                await chai.expect(acceptOfferOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

    })
    
})
