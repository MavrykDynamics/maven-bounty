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
    getStorageMapValue
} from './helpers/helperFunctions'

// ------------------------------------------------------------------------------
// Contract Notes
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Contract Tests
// ------------------------------------------------------------------------------

describe('Test: Token Registry Contract', async () => {

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

    let tokenRecord

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

        mockFa12TokenAddress            = contractDeployments.mockFa12Token.address;
        mockFa12TokenInstance           = await utils.tezos.contract.at(mockFa12TokenAddress)
        mockFa12TokenStorage            = await mockFa12TokenInstance.storage()

        mockFa2TokenAddress             = contractDeployments.mockFa2Token.address;
        mockFa2TokenInstance            = await utils.tezos.contract.at(mockFa2TokenAddress);
        mockFa2TokenStorage             = await mockFa2TokenInstance.storage()

        console.log('-- -- -- -- -- -- -- -- -- -- -- -- --')

    })

    beforeEach('storage', async () => {
        tokenRegistryStorage            = await tokenRegistryInstance.storage()
    })

    describe('%setToken', function () {
        
        beforeEach("Set signer to admin (eve)", async () => {
            await signerFactory(tezos, adminSk);
        });

        it('admin (eve) should be able to set mockFA12 token in token registry with no overriding beneficiary or fee', async () => {
            try {

                const newRegisteredTokenAddress = mockFa12TokenAddress;

                // set token operation
                const setTokenOperation = await tokenRegistryInstance.methods.setToken(
                    "fa12",
                    newRegisteredTokenAddress
                ).send()
                await setTokenOperation.confirmation();

                tokenRegistryStorage    = await tokenRegistryInstance.storage()
                tokenRecord             = await tokenRegistryStorage.tokenLedger.get(newRegisteredTokenAddress);

                assert.notEqual(tokenRecord                     , null);
                assert.equal(tokenRecord.tokenType              , "FA12");
                assert.equal(tokenRecord.tokenIds.length        , 0);
                assert.equal(tokenRecord.beneficiaryOverride    , null);
                assert.equal(tokenRecord.feeOverride            , null);

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should be able to update mockFA12 token in token registry with an overriding beneficiary and fee', async () => {
            try {

                const registeredTokenAddress = mockFa12TokenAddress;
                const beneficiaryOverride   = bob.pkh;
                const feeOverride           = 500;

                // set token operation
                const setTokenOperation = await tokenRegistryInstance.methods.setToken(
                    "fa12",
                    registeredTokenAddress,
                    beneficiaryOverride,
                    feeOverride
                ).send()
                await setTokenOperation.confirmation();

                tokenRegistryStorage    = await tokenRegistryInstance.storage()
                tokenRecord             = await tokenRegistryStorage.tokenLedger.get(registeredTokenAddress);

                assert.notEqual(tokenRecord                     , null);
                assert.equal(tokenRecord.tokenType              , "FA12");
                assert.equal(tokenRecord.tokenIds.length        , 0);
                assert.equal(tokenRecord.beneficiaryOverride    , beneficiaryOverride);
                assert.equal(tokenRecord.feeOverride            , feeOverride);

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should be able to set mockFA12 token in token registry with an overriding beneficiary and fee', async () => {
            try {

                const registeredTokenAddress = mockFa12TokenAddress;
                const beneficiaryOverride   = bob.pkh;
                const feeOverride           = 500;

                // remove token first
                const removeTokenOperation = await tokenRegistryInstance.methods.removeToken(
                    "fa12",
                    registeredTokenAddress
                ).send()
                await removeTokenOperation.confirmation();

                tokenRegistryStorage    = await tokenRegistryInstance.storage()
                tokenRecord             = await tokenRegistryStorage.tokenLedger.get(registeredTokenAddress);

                assert.equal(tokenRecord, null);
                
                // set token with overriding beneficiary and fee
                const setTokenOperation = await tokenRegistryInstance.methods.setToken(
                    "fa12",
                    registeredTokenAddress,
                    beneficiaryOverride,
                    feeOverride
                ).send()
                await setTokenOperation.confirmation();

                tokenRegistryStorage    = await tokenRegistryInstance.storage()
                tokenRecord             = await tokenRegistryStorage.tokenLedger.get(registeredTokenAddress);

                assert.notEqual(tokenRecord                     , null);
                assert.equal(tokenRecord.tokenType              , "FA12");
                assert.equal(tokenRecord.tokenIds.length        , 0);
                assert.equal(tokenRecord.beneficiaryOverride    , beneficiaryOverride);
                assert.equal(tokenRecord.feeOverride            , feeOverride);

            } catch (e) {
                console.log(e)
            }
        })


        it('admin (eve) should be able to reset mockFA12 token in token registry to no overriding beneficiary and fee', async () => {
            try {

                const registeredTokenAddress = mockFa12TokenAddress;
                const beneficiaryOverride   = null;
                const feeOverride           = null;

                // set token operation
                const setTokenOperation = await tokenRegistryInstance.methods.setToken(
                    "fa12",
                    registeredTokenAddress,
                    beneficiaryOverride,
                    feeOverride
                ).send()
                await setTokenOperation.confirmation();

                tokenRegistryStorage    = await tokenRegistryInstance.storage()
                tokenRecord             = await tokenRegistryStorage.tokenLedger.get(registeredTokenAddress);

                assert.notEqual(tokenRecord                     , null);
                assert.equal(tokenRecord.tokenType              , "FA12");
                assert.equal(tokenRecord.tokenIds.length        , 0);
                assert.equal(tokenRecord.beneficiaryOverride    , beneficiaryOverride);
                assert.equal(tokenRecord.feeOverride            , feeOverride);

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should be able to set mockFA2 token in token registry with no overriding beneficiary or fee', async () => {
            try {

                const newRegisteredTokenAddress = mockFa2TokenAddress;
                const tokenId = 0;

                // set token operation
                const setTokenOperation = await tokenRegistryInstance.methods.setToken(
                    "fa2",
                    newRegisteredTokenAddress,
                    tokenId
                ).send()
                await setTokenOperation.confirmation();

                tokenRegistryStorage    = await tokenRegistryInstance.storage()
                tokenRecord             = await tokenRegistryStorage.tokenLedger.get(newRegisteredTokenAddress);

                assert.notEqual(tokenRecord                     , null);
                assert.equal(tokenRecord.tokenType              , "FA2");
                assert.equal(tokenRecord.tokenIds[0]            , tokenId);
                assert.equal(tokenRecord.tokenIds.length        , 1);
                assert.equal(tokenRecord.beneficiaryOverride    , null);
                assert.equal(tokenRecord.feeOverride            , null);

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should be able to update mockFA2 token in token registry with an overriding beneficiary and fee', async () => {
            try {

                const registeredTokenAddress    = mockFa2TokenAddress;
                const tokenId                   = 0;
                const beneficiaryOverride       = bob.pkh;
                const feeOverride               = 500;

                // set token operation
                const setTokenOperation = await tokenRegistryInstance.methods.setToken(
                    "fa2",
                    registeredTokenAddress,
                    tokenId,
                    beneficiaryOverride,
                    feeOverride
                ).send()
                await setTokenOperation.confirmation();

                tokenRegistryStorage    = await tokenRegistryInstance.storage()
                tokenRecord             = await tokenRegistryStorage.tokenLedger.get(registeredTokenAddress);

                assert.notEqual(tokenRecord                     , null);
                assert.equal(tokenRecord.tokenType              , "FA2");
                assert.equal(tokenRecord.tokenIds[0]            , tokenId);
                assert.equal(tokenRecord.tokenIds.length        , 1);
                assert.equal(tokenRecord.beneficiaryOverride    , beneficiaryOverride);
                assert.equal(tokenRecord.feeOverride            , feeOverride);

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should be able to set mockFA2 token in token registry with an overriding beneficiary and fee', async () => {
            try {

                const registeredTokenAddress    = mockFa2TokenAddress;
                const tokenId                   = 0;
                const beneficiaryOverride       = bob.pkh;
                const feeOverride               = 500;

                // remove token first
                const removeTokenOperation = await tokenRegistryInstance.methods.removeToken(
                    "fa2",
                    registeredTokenAddress,
                    tokenId
                ).send()
                await removeTokenOperation.confirmation();

                tokenRegistryStorage    = await tokenRegistryInstance.storage()
                tokenRecord             = await tokenRegistryStorage.tokenLedger.get(registeredTokenAddress);
                assert.equal(tokenRecord, null);

                // set token with beneficiary and fee override
                const setTokenOperation = await tokenRegistryInstance.methods.setToken(
                    "fa2",
                    registeredTokenAddress,
                    tokenId,
                    beneficiaryOverride,
                    feeOverride
                ).send()
                await setTokenOperation.confirmation();

                tokenRegistryStorage        = await tokenRegistryInstance.storage()
                tokenRecord                 = await tokenRegistryStorage.tokenLedger.get(registeredTokenAddress);

                assert.notEqual(tokenRecord                     , null);
                assert.equal(tokenRecord.tokenType              , "FA2");
                assert.equal(tokenRecord.tokenIds[0]            , tokenId);
                assert.equal(tokenRecord.tokenIds.length        , 1);
                assert.equal(tokenRecord.beneficiaryOverride    , beneficiaryOverride);
                assert.equal(tokenRecord.feeOverride            , feeOverride);

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should be able to reset mockFA2 token in token registry with no overriding beneficiary and fee', async () => {
            try {

                const registeredTokenAddress    = mockFa2TokenAddress;
                const tokenId                   = 0;
                const beneficiaryOverride       = null;
                const feeOverride               = null;

                // set token operation
                const setTokenOperation = await tokenRegistryInstance.methods.setToken(
                    "fa2",
                    registeredTokenAddress,
                    tokenId,
                    beneficiaryOverride,
                    feeOverride
                ).send()
                await setTokenOperation.confirmation();

                tokenRegistryStorage    = await tokenRegistryInstance.storage()
                tokenRecord             = await tokenRegistryStorage.tokenLedger.get(registeredTokenAddress);

                assert.notEqual(tokenRecord                     , null);
                assert.equal(tokenRecord.tokenType              , "FA2");
                assert.equal(tokenRecord.tokenIds[0]            , tokenId);
                assert.equal(tokenRecord.tokenIds.length        , 1);
                assert.equal(tokenRecord.beneficiaryOverride    , beneficiaryOverride);
                assert.equal(tokenRecord.feeOverride            , feeOverride);

            } catch (e) {
                console.log(e)
            }
        })

    })

    describe('%removeToken', function () {
        
        beforeEach("Set signer to admin (eve)", async () => {
            await signerFactory(tezos, adminSk);
        });

        it('admin (eve) should be able to remove mockFA12 token in token registry', async () => {
            try {

                const registeredTokenAddress = mockFa12TokenAddress;

                // remove token operation
                const removeTokenOperation = await tokenRegistryInstance.methods.removeToken(
                    "fa12",
                    registeredTokenAddress
                ).send()
                await removeTokenOperation.confirmation();

                tokenRegistryStorage    = await tokenRegistryInstance.storage()
                tokenRecord             = await tokenRegistryStorage.tokenLedger.get(registeredTokenAddress);

                assert.equal(tokenRecord, null);

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should be able to remove mockFA2 token in token registry', async () => {
            try {

                const registeredTokenAddress = mockFa2TokenAddress;
                const tokenId = 0;

                // remove token operation
                const removeTokenOperation = await tokenRegistryInstance.methods.removeToken(
                    "fa2",
                    registeredTokenAddress,
                    tokenId
                ).send()
                await removeTokenOperation.confirmation();

                tokenRegistryStorage        = await tokenRegistryInstance.storage()
                tokenRecord                 = await tokenRegistryStorage.tokenLedger.get(registeredTokenAddress);

                assert.equal(tokenRecord, null);

            } catch (e) {
                console.log(e)
            }
        })

    })
})
