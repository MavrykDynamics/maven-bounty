import { Utils } from './helpers/Utils'
import { MichelsonMap } from '@taquito/taquito'

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
    updateOperators
} from './helpers/helperFunctions'



// ------------------------------------------------------------------------------
// Contract Notes
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Contract Tests
// ------------------------------------------------------------------------------

describe('Test: Launchpad Contract', async () => {

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

    let launchpadAddress
    let launchpadInstance
    let launchpadStorage

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

    let saleRecord
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

        launchpadAddress                = contractDeployments.launchpad.address
        launchpadInstance               = await utils.tezos.contract.at(launchpadAddress)
        launchpadStorage                = await launchpadInstance.storage()

        mockFa12TokenAddress            = contractDeployments.mockFa12Token.address;
        mockFa12TokenInstance           = await utils.tezos.contract.at(mockFa12TokenAddress)
        mockFa12TokenStorage            = await mockFa12TokenInstance.storage()

        mockFa2TokenAddress             = contractDeployments.mockFa2Token.address;
        mockFa2TokenInstance            = await utils.tezos.contract.at(mockFa2TokenAddress);
        mockFa2TokenStorage             = await mockFa2TokenInstance.storage()

        console.log('-- -- -- -- -- -- -- -- -- -- -- -- --')

    })

    beforeEach('storage', async () => {
        launchpadStorage            = await launchpadInstance.storage()
    })

    describe('%createTokenSale', function () {
        
        beforeEach("Set signer to admin (eve)", async () => {
            launchpadStorage = await launchpadInstance.storage()
            await signerFactory(tezos, adminSk);
        });

        it('admin (eve) should be able to create a new token sale [Token Issuance: Auto | Token Distribution : Auto | Empty Sale Options and Whitelist Options]', async () => {
            try {

                const saleId                    = launchpadStorage.lastSaleId;
                const name                      = "testTokenSale";
                const tokenIssuanceType         = "mint";
                const tokenDistributionType     = "auto";
                const tokenContractAddress      = mockFa2TokenAddress;
                const tokenId                   = 0;
                const saleStart                 = makeTimestamp(30);
                const saleEnd                   = makeTimestamp(300);

                const emptySaleOptions          = MichelsonMap.fromLiteral({});
                const emptyWhitelistOptions     = MichelsonMap.fromLiteral({});

                // create token sale operation
                const createTokenSaleOperation = await launchpadInstance.methods.createTokenSale(
                    name,
                    tokenIssuanceType,
                    tokenDistributionType,
                    tokenContractAddress,
                    tokenId,
                    saleStart,
                    saleEnd,
                    emptySaleOptions,
                    emptyWhitelistOptions
                ).send()
                await createTokenSaleOperation.confirmation();

                launchpadStorage    = await launchpadInstance.storage()
                saleRecord          = await launchpadStorage.saleLedger.get(saleId);

                assert.notEqual(saleRecord                      , null);

                assert.equal(saleRecord.name                    , name);
                assert.equal(saleRecord.tokenIssuanceType       , tokenIssuanceType);
                assert.equal(saleRecord.tokenDistributionType   , tokenDistributionType);
                assert.equal(saleRecord.tokenContractAddress    , tokenContractAddress);
                assert.equal(saleRecord.tokenId                 , tokenId);
                assert.equal(saleRecord.saleStart               , showMillisecondsDateFormat(saleStart));
                assert.equal(saleRecord.saleEnd                 , showMillisecondsDateFormat(saleEnd));
                
                // assert.equal(saleRecord.saleOptions             , emptySaleOptions);
                // assert.equal(saleRecord.defaultWhitelistOptions , emptyWhitelistOptions);

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should be able to create a new token sale [Token Issuance: Auto | Token Distribution : Auto | Empty Sale Options and Whitelist Options]', async () => {
            try {

                const saleId                    = launchpadStorage.lastSaleId;
                const name                      = "testTokenSale";
                const tokenIssuanceType         = "mint";
                const tokenDistributionType     = "auto";
                const tokenContractAddress      = mockFa2TokenAddress;
                const tokenId                   = 0;
                const saleStart                 = makeTimestamp(30);
                const saleEnd                   = makeTimestamp(300);

                const emptySaleOptions          = MichelsonMap.fromLiteral({});

                const defaultWhitelistOptionKey     = 'default';
                const defaultWhitelistOptionValue   = 100000;
                const defaultWhitelistOptions       = MichelsonMap.fromLiteral({
                    'default' : defaultWhitelistOptionValue
                });

                // create token sale operation
                const createTokenSaleOperation = await launchpadInstance.methods.createTokenSale(
                    name,
                    tokenIssuanceType,
                    tokenDistributionType,
                    tokenContractAddress,
                    tokenId,
                    saleStart,
                    saleEnd,
                    emptySaleOptions,
                    defaultWhitelistOptions
                ).send()
                await createTokenSaleOperation.confirmation();

                launchpadStorage    = await launchpadInstance.storage()
                saleRecord          = await launchpadStorage.saleLedger.get(saleId);
                
                const whitelistOption = await saleRecord.defaultWhitelistOptions.get(defaultWhitelistOptionKey.toString());

                console.log(saleRecord);

                assert.notEqual(saleRecord                      , null);
                assert.equal(saleRecord.name                    , name);
                assert.equal(saleRecord.tokenIssuanceType       , tokenIssuanceType);
                assert.equal(saleRecord.tokenDistributionType   , tokenDistributionType);
                assert.equal(saleRecord.tokenContractAddress    , tokenContractAddress);
                assert.equal(saleRecord.tokenId                 , tokenId);
                assert.equal(saleRecord.saleStart               , showMillisecondsDateFormat(saleStart));
                assert.equal(saleRecord.saleEnd                 , showMillisecondsDateFormat(saleEnd));
                assert.equal(whitelistOption                    , defaultWhitelistOptionValue);

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should be able to create a new token sale [Token Issuance: Auto | Token Distribution : Auto | No expiry | Empty Sale Options and Whitelist Options]', async () => {
            try {

                const saleId                    = launchpadStorage.lastSaleId;
                const name                      = "testTokenSale";
                const tokenIssuanceType         = "mint";
                const tokenDistributionType     = "auto";
                const tokenContractAddress      = mockFa2TokenAddress;
                const tokenId                   = 0;
                const saleStart                 = makeTimestamp(30);
                const saleEnd                   = null;

                const emptySaleOptions          = MichelsonMap.fromLiteral({});

                const defaultWhitelistOptionKey     = 'default';
                const defaultWhitelistOptionValue   = 100000;
                const defaultWhitelistOptions       = MichelsonMap.fromLiteral({
                    'default' : defaultWhitelistOptionValue
                });

                // create token sale operation
                const createTokenSaleOperation = await launchpadInstance.methods.createTokenSale(
                    name,
                    tokenIssuanceType,
                    tokenDistributionType,
                    tokenContractAddress,
                    tokenId,
                    saleStart,
                    saleEnd,
                    emptySaleOptions,
                    defaultWhitelistOptions
                ).send()
                await createTokenSaleOperation.confirmation();

                launchpadStorage    = await launchpadInstance.storage()
                saleRecord          = await launchpadStorage.saleLedger.get(saleId);
                
                const whitelistOption = await saleRecord.defaultWhitelistOptions.get(defaultWhitelistOptionKey.toString());

                assert.notEqual(saleRecord                      , null);
                assert.equal(saleRecord.name                    , name);
                assert.equal(saleRecord.tokenIssuanceType       , tokenIssuanceType);
                assert.equal(saleRecord.tokenDistributionType   , tokenDistributionType);
                assert.equal(saleRecord.tokenContractAddress    , tokenContractAddress);
                assert.equal(saleRecord.tokenId                 , tokenId);
                assert.equal(saleRecord.saleStart               , showMillisecondsDateFormat(saleStart));
                assert.equal(saleRecord.saleEnd                 , null)
                assert.equal(whitelistOption                    , defaultWhitelistOptionValue);

            } catch (e) {
                console.log(e)
            }
        })

    })

    
})
