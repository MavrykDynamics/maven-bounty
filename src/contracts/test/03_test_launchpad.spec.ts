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
import { mockTokenSaleOptions } from 'test/helpers/mockSampleData'

// ------------------------------------------------------------------------------
// Contract Helpers
// ------------------------------------------------------------------------------

import { bob, alice, eve, mallory, oscar, david } from '../scripts/sandbox/accounts'
import { 
    signerFactory,
    wait, 
    getStorageMapValue,
    makeTimestamp,
    showMillisecondsDateFormat,
    updateOperators,
    getTokenInfo,
} from './helpers/helperFunctions'
import { sign } from 'crypto'



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

    let launchRecord
    let currencyRecord
    let listingRecord
    let offerRecord

    let launchWhitelistRecord

    let launchId
    let firstLaunchId
    let secondLaunchId
    let thirdLaunchId

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

    describe('%createTokenLaunch', function () {
        
        beforeEach("Set signer to admin (eve)", async () => {
            launchpadStorage = await launchpadInstance.storage()
            await signerFactory(tezos, adminSk);
        });

        it('admin (eve) should be able to create a new token launch [Token Issuance: Auto | Token Distribution : Auto | Empty Sale Options and Whitelist Options]', async () => {
            try {

                const launchId                  = launchpadStorage.lastLaunchId;
                firstLaunchId                   = launchId; // for use in subsequent test

                const name                      = "testTokenLaunch";
                const tokenIssuanceType         = "MINT";
                const tokenDistributionType     = "AUTO";
                const tokenContractAddress      = mockFa2TokenAddress;
                const tokenId                   = 0;
                const saleStart                 = makeTimestamp(30);
                const saleEnd                   = makeTimestamp(300);
                const whitelistSaleStart        = null;
                const whitelistSaleEnd          = null;

                const emptySaleOptions          = MichelsonMap.fromLiteral({});
                const emptyWhitelistOptions     = MichelsonMap.fromLiteral({});

                // create token sale operation
                const createTokenLaunchOperation = await launchpadInstance.methods.createTokenLaunch(
                    name,
                    tokenIssuanceType,
                    tokenDistributionType,
                    tokenContractAddress,
                    tokenId,
                    saleStart,
                    saleEnd,
                    whitelistSaleStart,
                    whitelistSaleEnd,
                    emptySaleOptions,
                    emptyWhitelistOptions
                ).send()
                await createTokenLaunchOperation.confirmation();

                launchpadStorage    = await launchpadInstance.storage()
                launchRecord          = await launchpadStorage.launchLedger.get(launchId);

                assert.notEqual(launchRecord                      , null);

                assert.equal(launchRecord.name                    , name);
                assert.equal(launchRecord.tokenIssuanceType       , tokenIssuanceType);
                assert.equal(launchRecord.tokenDistributionType   , tokenDistributionType);
                assert.equal(launchRecord.tokenContractAddress    , tokenContractAddress);
                assert.equal(launchRecord.tokenId                 , tokenId);
                assert.equal(launchRecord.saleStart               , showMillisecondsDateFormat(saleStart));
                assert.equal(launchRecord.saleEnd                 , showMillisecondsDateFormat(saleEnd));
                
                // assert.equal(launchRecord.saleOptions             , emptySaleOptions);
                // assert.equal(launchRecord.defaultWhitelistOptions , emptyWhitelistOptions);

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should be able to create a new token launch [Token Issuance: Auto | Token Distribution : Auto | Empty Sale Options and Whitelist Options]', async () => {
            try {

                const launchId                  = launchpadStorage.lastLaunchId;
                secondLaunchId                  = launchId; // for use in subsequent test

                const name                      = "testTokenLaunch";
                const tokenIssuanceType         = "MINT";
                const tokenDistributionType     = "AUTO";
                const tokenContractAddress      = mockFa2TokenAddress;
                const tokenId                   = 0;
                const saleStart                 = makeTimestamp(30);
                const saleEnd                   = makeTimestamp(300);
                const whitelistSaleStart        = null;
                const whitelistSaleEnd          = null;

                const emptySaleOptions          = MichelsonMap.fromLiteral({});

                const defaultWhitelistOptionKey     = 'default';
                const defaultWhitelistOptionValue   = 100000;
                const defaultWhitelistOptions       = MichelsonMap.fromLiteral({
                    'default' : defaultWhitelistOptionValue
                });

                // create token sale operation
                const createTokenLaunchOperation = await launchpadInstance.methods.createTokenLaunch(
                    name,
                    tokenIssuanceType,
                    tokenDistributionType,
                    tokenContractAddress,
                    tokenId,
                    saleStart,
                    saleEnd,
                    whitelistSaleStart,
                    whitelistSaleEnd,
                    emptySaleOptions,
                    defaultWhitelistOptions
                ).send()
                await createTokenLaunchOperation.confirmation();

                launchpadStorage      = await launchpadInstance.storage()
                launchRecord          = await launchpadStorage.launchLedger.get(launchId);
                
                const whitelistOption = await launchRecord.defaultWhitelistOptions.get(defaultWhitelistOptionKey.toString());

                // console.log(launchRecord);

                assert.notEqual(launchRecord                      , null);
                assert.equal(launchRecord.name                    , name);
                assert.equal(launchRecord.tokenIssuanceType       , tokenIssuanceType);
                assert.equal(launchRecord.tokenDistributionType   , tokenDistributionType);
                assert.equal(launchRecord.tokenContractAddress    , tokenContractAddress);
                assert.equal(launchRecord.tokenId                 , tokenId);
                assert.equal(launchRecord.saleStart               , showMillisecondsDateFormat(saleStart));
                assert.equal(launchRecord.saleEnd                 , showMillisecondsDateFormat(saleEnd));
                assert.equal(whitelistOption                      , defaultWhitelistOptionValue);

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should be able to create a new token launch [Token Issuance: Auto | Token Distribution : Auto | No expiry | Empty Sale Options and Whitelist Options]', async () => {
            try {

                const launchId                  = launchpadStorage.lastLaunchId;
                thirdLaunchId                   = launchId; // for use in subsequent test

                const name                      = "testTokenLaunch";
                const tokenIssuanceType         = "MINT";
                const tokenDistributionType     = "AUTO";
                const tokenContractAddress      = mockFa2TokenAddress;
                const tokenId                   = 0;
                const saleStart                 = makeTimestamp(30);
                const saleEnd                   = null;
                const whitelistSaleStart        = null;
                const whitelistSaleEnd          = null;

                const emptySaleOptions          = MichelsonMap.fromLiteral({});

                const defaultWhitelistOptionKey     = 'default';
                const defaultWhitelistOptionValue   = 100000;
                const defaultWhitelistOptions       = MichelsonMap.fromLiteral({
                    'default' : defaultWhitelistOptionValue
                });

                // create token sale operation
                const createTokenLaunchOperation = await launchpadInstance.methods.createTokenLaunch(
                    name,
                    tokenIssuanceType,
                    tokenDistributionType,
                    tokenContractAddress,
                    tokenId,
                    saleStart,
                    saleEnd,
                    whitelistSaleStart,
                    whitelistSaleEnd,
                    emptySaleOptions,
                    defaultWhitelistOptions
                ).send()
                await createTokenLaunchOperation.confirmation();

                launchpadStorage      = await launchpadInstance.storage()
                launchRecord          = await launchpadStorage.launchLedger.get(launchId);
                
                const whitelistOption = await launchRecord.defaultWhitelistOptions.get(defaultWhitelistOptionKey.toString());

                assert.notEqual(launchRecord                      , null);
                assert.equal(launchRecord.name                    , name);
                assert.equal(launchRecord.tokenIssuanceType       , tokenIssuanceType);
                assert.equal(launchRecord.tokenDistributionType   , tokenDistributionType);
                assert.equal(launchRecord.tokenContractAddress    , tokenContractAddress);
                assert.equal(launchRecord.tokenId                 , tokenId);
                assert.equal(launchRecord.saleStart               , showMillisecondsDateFormat(saleStart));
                assert.equal(launchRecord.saleEnd                 , null)
                assert.equal(whitelistOption                    , defaultWhitelistOptionValue);

            } catch (e) {
                console.log(e)
            }
        })


        it('admin (eve) should not be able to create a new token launch if the sale end time is before the sale start time', async () => {
            try {

                const name                      = "failTokenLaunch";
                const tokenIssuanceType         = "MINT";
                const tokenDistributionType     = "AUTO";
                const tokenContractAddress      = mockFa2TokenAddress;
                const tokenId                   = 0;
                const saleStart                 = makeTimestamp(300);
                const saleEnd                   = makeTimestamp(30);
                const whitelistSaleStart        = null;
                const whitelistSaleEnd          = null;

                const emptySaleOptions          = MichelsonMap.fromLiteral({});
                const emptyWhitelistOptions     = MichelsonMap.fromLiteral({});

                // create token sale operation
                const createTokenLaunchOperation = await launchpadInstance.methods.createTokenLaunch(
                    name,
                    tokenIssuanceType,
                    tokenDistributionType,
                    tokenContractAddress,
                    tokenId,
                    saleStart,
                    saleEnd,
                    whitelistSaleStart,
                    whitelistSaleEnd,
                    emptySaleOptions,
                    emptyWhitelistOptions
                );
                await chai.expect(createTokenLaunchOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })


        it('admin (eve) should not be able to create a new token launch if the whitelist sale end time is before the whitelist sale start time', async () => {
            try {

                const name                      = "failTokenLaunch";
                const tokenIssuanceType         = "MINT";
                const tokenDistributionType     = "AUTO";
                const tokenContractAddress      = mockFa2TokenAddress;
                const tokenId                   = 0;
                const saleStart                 = makeTimestamp(30);
                const saleEnd                   = makeTimestamp(300);
                const whitelistSaleStart        = makeTimestamp(300);
                const whitelistSaleEnd          = makeTimestamp(30);

                const emptySaleOptions          = MichelsonMap.fromLiteral({});
                const emptyWhitelistOptions     = MichelsonMap.fromLiteral({});

                // create token sale operation
                const createTokenLaunchOperation = await launchpadInstance.methods.createTokenLaunch(
                    name,
                    tokenIssuanceType,
                    tokenDistributionType,
                    tokenContractAddress,
                    tokenId,
                    saleStart,
                    saleEnd,
                    whitelistSaleStart,
                    whitelistSaleEnd,
                    emptySaleOptions,
                    emptyWhitelistOptions
                );
                await chai.expect(createTokenLaunchOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should not be able to create a new token launch with an invalid token issuance type', async () => {
            try {

                const name                      = "failTokenLaunch";
                const tokenIssuanceType         = "mint"; // should be all caps "MINT"
                const tokenDistributionType     = "AUTO";
                const tokenContractAddress      = mockFa2TokenAddress;
                const tokenId                   = 0;
                const saleStart                 = makeTimestamp(30);
                const saleEnd                   = makeTimestamp(300);
                const whitelistSaleStart        = null;
                const whitelistSaleEnd          = null;

                const emptySaleOptions          = MichelsonMap.fromLiteral({});
                const emptyWhitelistOptions     = MichelsonMap.fromLiteral({});

                // create token sale operation
                const createTokenLaunchOperation = await launchpadInstance.methods.createTokenLaunch(
                    name,
                    tokenIssuanceType,
                    tokenDistributionType,
                    tokenContractAddress,
                    tokenId,
                    saleStart,
                    saleEnd,
                    whitelistSaleStart,
                    whitelistSaleEnd,
                    emptySaleOptions,
                    emptyWhitelistOptions
                );
                await chai.expect(createTokenLaunchOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should not be able to create a new token launch with an invalid token distribution type', async () => {
            try {

                const name                      = "failTokenLaunch";
                const tokenIssuanceType         = "MINT"; 
                const tokenDistributionType     = "auto"; // should be all caps "AUTO"
                const tokenContractAddress      = mockFa2TokenAddress;
                const tokenId                   = 0;
                const saleStart                 = makeTimestamp(30);
                const saleEnd                   = makeTimestamp(300);
                const whitelistSaleStart        = null;
                const whitelistSaleEnd          = null;

                const emptySaleOptions          = MichelsonMap.fromLiteral({});
                const emptyWhitelistOptions     = MichelsonMap.fromLiteral({});

                // create token sale operation
                const createTokenLaunchOperation = await launchpadInstance.methods.createTokenLaunch(
                    name,
                    tokenIssuanceType,
                    tokenDistributionType,
                    tokenContractAddress,
                    tokenId,
                    saleStart,
                    saleEnd,
                    whitelistSaleStart,
                    whitelistSaleEnd,
                    emptySaleOptions,
                    emptyWhitelistOptions
                );
                await chai.expect(createTokenLaunchOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })


    })


    describe('%editTokenLaunch', function () {
        
        beforeEach("Set signer to admin (eve)", async () => {
            launchpadStorage = await launchpadInstance.storage()
            await signerFactory(tezos, adminSk);
        });

        it('admin (eve) should be able to edit a token launch', async () => {
            try {

                launchId                        = firstLaunchId;

                const newName                   = "newTestTokenLaunch";
                const newTokenIssuanceType      = "TRANSFER";
                const newTokenDistributionType  = "MANUAL";
                const newTokenContractAddress   = mockFa12TokenAddress;
                const newTokenId                = 1;
                const newSaleStart              = makeTimestamp(60);
                const newSaleEnd                = makeTimestamp(600);
                const newWhitelistSaleStart     = null;
                const newWhitelistSaleEnd       = null;

                const newSaleOptions            = MichelsonMap.fromLiteral({
                    'default'           : mockTokenSaleOptions.default,
                    'defaultWithFa12'   : mockTokenSaleOptions.defaultWithFa12,
                    'whitelist'         : mockTokenSaleOptions.whitelist
                });

                const defaultWhitelistOptionValue   = 5000000;
                const newDefaultWhitelistOptions    = MichelsonMap.fromLiteral({
                    'whitelist' : defaultWhitelistOptionValue
                });

                // edit token launch operation
                const editTokenLaunchOperation = await launchpadInstance.methods.editTokenLaunch(
                    launchId,
                    newName,
                    newTokenIssuanceType,
                    newTokenDistributionType,
                    newTokenContractAddress,
                    newTokenId,
                    newSaleStart,
                    newSaleEnd,
                    newWhitelistSaleStart,
                    newWhitelistSaleEnd,
                    newSaleOptions,
                    newDefaultWhitelistOptions
                ).send()
                await editTokenLaunchOperation.confirmation();

                launchpadStorage    = await launchpadInstance.storage()
                launchRecord          = await launchpadStorage.launchLedger.get(launchId);

                assert.notEqual(launchRecord                      , null);

                // Check launch record
                assert.equal(launchRecord.name                    , newName);
                assert.equal(launchRecord.tokenIssuanceType       , newTokenIssuanceType);
                assert.equal(launchRecord.tokenDistributionType   , newTokenDistributionType);
                assert.equal(launchRecord.tokenContractAddress    , newTokenContractAddress);
                assert.equal(launchRecord.tokenId                 , newTokenId);
                assert.equal(launchRecord.saleStart               , showMillisecondsDateFormat(newSaleStart));
                assert.equal(launchRecord.saleEnd                 , showMillisecondsDateFormat(newSaleEnd));
                
                // Get sale options
                const defaultSaleOption             = launchRecord.saleOptions.get('default');
                const defaultWithFa12SaleOption     = launchRecord.saleOptions.get('defaultWithFa12');
                const defaultWhitelistSaleOption    = launchRecord.saleOptions.get('whitelist');

                // Check Default Sale Option
                assert.equal(defaultSaleOption.maxAmountCap             , mockTokenSaleOptions.default.maxAmountCap);
                assert.equal(defaultSaleOption.totalBought              , mockTokenSaleOptions.default.totalBought);
                assert.equal(defaultSaleOption.minPurchaseAmount        , mockTokenSaleOptions.default.minPurchaseAmount);
                assert.equal(defaultSaleOption.maxAmountPerWalletTotal  , mockTokenSaleOptions.default.maxAmountPerWalletTotal);
                assert.equal(defaultSaleOption.price                    , mockTokenSaleOptions.default.price);

                assert.equal(getTokenInfo(defaultSaleOption.currency, "tokenContractAddress"), mockTokenSaleOptions.default.currency.fa2.tokenContractAddress);
                assert.equal(getTokenInfo(defaultSaleOption.currency, "tokenId")             , mockTokenSaleOptions.default.currency.fa2.tokenId);

                // Check Default FA12 Sale Option
                assert.equal(defaultWithFa12SaleOption.maxAmountCap             , mockTokenSaleOptions.defaultWithFa12.maxAmountCap);
                assert.equal(defaultWithFa12SaleOption.totalBought              , mockTokenSaleOptions.defaultWithFa12.totalBought);
                assert.equal(defaultWithFa12SaleOption.minPurchaseAmount        , mockTokenSaleOptions.defaultWithFa12.minPurchaseAmount);
                assert.equal(defaultWithFa12SaleOption.maxAmountPerWalletTotal  , mockTokenSaleOptions.defaultWithFa12.maxAmountPerWalletTotal);
                assert.equal(defaultWithFa12SaleOption.price                    , mockTokenSaleOptions.defaultWithFa12.price);

                assert.equal(getTokenInfo(defaultWithFa12SaleOption.currency, "tokenContractAddress"), mockTokenSaleOptions.defaultWithFa12.currency.fa12);

                // Check Default Whitelist Sale Option
                assert.equal(defaultWhitelistSaleOption.maxAmountCap             , mockTokenSaleOptions.whitelist.maxAmountCap);
                assert.equal(defaultWhitelistSaleOption.totalBought              , mockTokenSaleOptions.whitelist.totalBought);
                assert.equal(defaultWhitelistSaleOption.minPurchaseAmount        , mockTokenSaleOptions.whitelist.minPurchaseAmount);
                assert.equal(defaultWhitelistSaleOption.maxAmountPerWalletTotal  , mockTokenSaleOptions.whitelist.maxAmountPerWalletTotal);
                assert.equal(defaultWhitelistSaleOption.price                    , mockTokenSaleOptions.whitelist.price);

                assert.equal(getTokenInfo(defaultWhitelistSaleOption.currency, "tokenContractAddress"), mockTokenSaleOptions.whitelist.currency.fa2.tokenContractAddress);
                assert.equal(getTokenInfo(defaultWhitelistSaleOption.currency, "tokenId")             , mockTokenSaleOptions.whitelist.currency.fa2.tokenId);

                // Check default whitelist options
                const defaultWhitelistOption = launchRecord.defaultWhitelistOptions.get('whitelist');
                assert.equal(defaultWhitelistOption, defaultWhitelistOptionValue);

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should not be able to edit a token launch if the sale end time is before the sale start time', async () => {
            try {

                launchId                        = firstLaunchId;

                const newName                   = "newTestTokenLaunch";
                const newTokenIssuanceType      = "TRANSFER";
                const newTokenDistributionType  = "MANUAL";
                const newTokenContractAddress   = mockFa12TokenAddress;
                const newTokenId                = 1;
                const newSaleStart              = makeTimestamp(300);
                const newSaleEnd                = makeTimestamp(30);
                const newWhitelistSaleStart     = null;
                const newWhitelistSaleEnd       = null;

                const newSaleOptions            = MichelsonMap.fromLiteral({
                    'default'           : mockTokenSaleOptions.default,
                    'defaultWithFa12'   : mockTokenSaleOptions.defaultWithFa12,
                    'whitelist'         : mockTokenSaleOptions.whitelist
                });

                const defaultWhitelistOptionValue   = 100000;
                const newDefaultWhitelistOptions    = MichelsonMap.fromLiteral({
                    'whitelist' : defaultWhitelistOptionValue
                });

                // edit token sale operation
                const editTokenLaunchOperation = await launchpadInstance.methods.editTokenLaunch(
                    launchId,
                    newName,
                    newTokenIssuanceType,
                    newTokenDistributionType,
                    newTokenContractAddress,
                    newTokenId,
                    newSaleStart,
                    newSaleEnd,
                    newWhitelistSaleStart,
                    newWhitelistSaleEnd,
                    newSaleOptions,
                    newDefaultWhitelistOptions
                )
                await chai.expect(editTokenLaunchOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should not be able to edit a token launch if the whitelist sale end time is before the whitelist sale start time', async () => {
            try {

                launchId                        = firstLaunchId;

                const newName                   = "newTestTokenLaunch";
                const newTokenIssuanceType      = "TRANSFER";
                const newTokenDistributionType  = "MANUAL";
                const newTokenContractAddress   = mockFa12TokenAddress;
                const newTokenId                = 1;
                const newSaleStart              = makeTimestamp(30);
                const newSaleEnd                = makeTimestamp(300);
                const newWhitelistSaleStart     = makeTimestamp(300);
                const newWhitelistSaleEnd       = makeTimestamp(30);

                const newSaleOptions            = MichelsonMap.fromLiteral({
                    'default'           : mockTokenSaleOptions.default,
                    'defaultWithFa12'   : mockTokenSaleOptions.defaultWithFa12,
                    'whitelist'         : mockTokenSaleOptions.whitelist
                });

                const defaultWhitelistOptionValue   = 100000;
                const newDefaultWhitelistOptions    = MichelsonMap.fromLiteral({
                    'whitelist' : defaultWhitelistOptionValue
                });

                // edit token sale operation
                const editTokenLaunchOperation = await launchpadInstance.methods.editTokenLaunch(
                    launchId,
                    newName,
                    newTokenIssuanceType,
                    newTokenDistributionType,
                    newTokenContractAddress,
                    newTokenId,
                    newSaleStart,
                    newSaleEnd,
                    newWhitelistSaleStart,
                    newWhitelistSaleEnd,
                    newSaleOptions,
                    newDefaultWhitelistOptions
                )
                await chai.expect(editTokenLaunchOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should not be able to edit a token launch with an invalid token issuance type', async () => {
            try {

                launchId                        = firstLaunchId;

                const newName                   = "newTestTokenLaunch";
                const newTokenIssuanceType      = "transfer"; // should be all caps "TRANSFER"
                const newTokenDistributionType  = "MANUAL";
                const newTokenContractAddress   = mockFa12TokenAddress;
                const newTokenId                = 1;
                const newSaleStart              = makeTimestamp(30);
                const newSaleEnd                = makeTimestamp(300);
                const newWhitelistSaleStart     = null;
                const newWhitelistSaleEnd       = null;

                const newSaleOptions            = MichelsonMap.fromLiteral({
                    'default'           : mockTokenSaleOptions.default,
                    'defaultWithFa12'   : mockTokenSaleOptions.defaultWithFa12,
                    'whitelist'         : mockTokenSaleOptions.whitelist
                });

                const defaultWhitelistOptionValue   = 100000;
                const newDefaultWhitelistOptions    = MichelsonMap.fromLiteral({
                    'whitelist' : defaultWhitelistOptionValue
                });

                // edit token sale operation
                const editTokenLaunchOperation = await launchpadInstance.methods.editTokenLaunch(
                    launchId,
                    newName,
                    newTokenIssuanceType,
                    newTokenDistributionType,
                    newTokenContractAddress,
                    newTokenId,
                    newSaleStart,
                    newSaleEnd,
                    newWhitelistSaleStart,
                    newWhitelistSaleEnd,
                    newSaleOptions,
                    newDefaultWhitelistOptions
                )
                await chai.expect(editTokenLaunchOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should not be able to edit a token launch with an invalid token distribution type', async () => {
            try {

                launchId                        = firstLaunchId;

                const newName                   = "newTestTokenLaunch";
                const newTokenIssuanceType      = "TRANSFER";
                const newTokenDistributionType  = "manual"; // should be all caps "MANUAL"
                const newTokenContractAddress   = mockFa12TokenAddress;
                const newTokenId                = 1;
                const newSaleStart              = makeTimestamp(30);
                const newSaleEnd                = makeTimestamp(300);
                const newWhitelistSaleStart     = null;
                const newWhitelistSaleEnd       = null;

                const newSaleOptions            = MichelsonMap.fromLiteral({
                    'default'           : mockTokenSaleOptions.default,
                    'defaultWithFa12'   : mockTokenSaleOptions.defaultWithFa12,
                    'whitelist'         : mockTokenSaleOptions.whitelist
                });

                const defaultWhitelistOptionValue   = 100000;
                const newDefaultWhitelistOptions    = MichelsonMap.fromLiteral({
                    'whitelist' : defaultWhitelistOptionValue
                });

                // edit token sale operation
                const editTokenLaunchOperation = await launchpadInstance.methods.editTokenLaunch(
                    launchId,
                    newName,
                    newTokenIssuanceType,
                    newTokenDistributionType,
                    newTokenContractAddress,
                    newTokenId,
                    newSaleStart,
                    newSaleEnd,
                    newWhitelistSaleStart,
                    newWhitelistSaleEnd,
                    newSaleOptions,
                    newDefaultWhitelistOptions
                )
                await chai.expect(editTokenLaunchOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

        it('non-admin (mallory) should not be able to edit a token launch', async () => {
            try {

                launchId                        = firstLaunchId;

                const newName                   = "newTestTokenLaunch";
                const newTokenIssuanceType      = "TRANSFER";
                const newTokenDistributionType  = "MANUAL";
                const newTokenContractAddress   = mockFa12TokenAddress;
                const newTokenId                = 1;
                const newSaleStart              = makeTimestamp(60);
                const newSaleEnd                = makeTimestamp(600);

                const newSaleOptions            = MichelsonMap.fromLiteral({
                    'default'           : mockTokenSaleOptions.default,
                    'defaultWithFa12'   : mockTokenSaleOptions.defaultWithFa12,
                    'whitelist'         : mockTokenSaleOptions.whitelist
                });

                const defaultWhitelistOptionValue   = 100000;
                const newDefaultWhitelistOptions    = MichelsonMap.fromLiteral({
                    'whitelist' : defaultWhitelistOptionValue
                });

                // edit token sale operation
                const editTokenLaunchOperation = await launchpadInstance.methods.editTokenLaunch(
                    launchId,
                    newName,
                    newTokenIssuanceType,
                    newTokenDistributionType,
                    newTokenContractAddress,
                    newTokenId,
                    newSaleStart,
                    newSaleEnd,
                    newSaleOptions,
                    newDefaultWhitelistOptions
                );
                await chai.expect(editTokenLaunchOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })
    })


    describe('%setLaunchWhitelist', function () {
        
        beforeEach("Set signer to admin (eve)", async () => {
            launchpadStorage = await launchpadInstance.storage()
            await signerFactory(tezos, adminSk);
        });

        it('admin (eve) should be able to set a whitelisted user (alice) for token launch (defaultWhitelistOptions : True)', async () => {
            try {

                launchId                        = secondLaunchId;
                const whitelistedUser           = alice.pkh;
                
                // set launch whitelist operation
                const setLaunchWhitelistOperation = await launchpadInstance.methods.setLaunchWhitelist(
                    [
                        {
                            launchId                : launchId,
                            whitelistUserAddress    : whitelistedUser,
                            defaultWhitelistOption  : true,
                            whitelistOptions        : null
                        }
                    ]
                ).send()
                await setLaunchWhitelistOperation.confirmation();

                launchpadStorage    = await launchpadInstance.storage()
                launchRecord        = await launchpadStorage.launchLedger.get(launchId);

                const launchDefaultWhitelistOptions = launchRecord.defaultWhitelistOptions;
                // console.log(launchDefaultWhitelistOptions);

                launchWhitelistRecord        = await launchpadStorage.launchWhitelistLedger.get([launchId, whitelistedUser]);
                
                // console.log(launchWhitelistRecord);

                // assert.notEqual(launchRecord                      , null);
                // assert.equal(launchRecord.saleOptions             , emptySaleOptions);
                // assert.equal(launchRecord.defaultWhitelistOptions , emptyWhitelistOptions);

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should be able to set a whitelisted user for token launch (defaultWhitelistOptions : False - custom whitelist options)', async () => {
            try {

                launchId                            = secondLaunchId;

                const whitelistedUser               = mallory.pkh;
                const defaultWhitelistOptionKey     = 'custom';
                const defaultWhitelistOptionValue   = 200000;
                const defaultWhitelistOptions       = MichelsonMap.fromLiteral({
                    'custom' : defaultWhitelistOptionValue
                });

                // set launch whitelist operation
                const setLaunchWhitelistOperation = await launchpadInstance.methods.setLaunchWhitelist(
                    [
                        {
                            launchId                : launchId,
                            whitelistUserAddress    : whitelistedUser,
                            defaultWhitelistOption  : true,
                            whitelistOptions        : null
                        }
                    ]
                ).send()
                await setLaunchWhitelistOperation.confirmation();

                // launchpadStorage    = await launchpadInstance.storage()
                // launchRecord          = await launchpadStorage.launchLedger.get(launchId);

                // assert.notEqual(launchRecord                      , null);

                // assert.equal(launchRecord.saleOptions             , emptySaleOptions);
                // assert.equal(launchRecord.defaultWhitelistOptions , emptyWhitelistOptions);

            } catch (e) {
                console.log(e)
            }
        })

    })

    describe('%startLaunch', function () {
        
        beforeEach("Set signer to admin (eve)", async () => {
            launchpadStorage = await launchpadInstance.storage()
            await signerFactory(tezos, adminSk);
        });


        it('admin (eve) should be able to start a launch', async () => {
            try {

                launchId                   = firstLaunchId;
                launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                assert.equal(launchRecord.status , "INACTIVE");

                // start launch operation
                const startLaunchOperation = await launchpadInstance.methods.startLaunch(launchId).send();
                await startLaunchOperation.confirmation();

                launchpadStorage        = await launchpadInstance.storage()
                launchRecord            = await launchpadStorage.launchLedger.get(launchId);

                assert.equal(launchRecord.status , "ACTIVE");

            } catch (e) {
                console.log(e)
            }
        })


        it('non-admin (mallory) should not be able to start a launch', async () => {
            try {

                launchId                   = secondLaunchId;
                launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                assert.equal(launchRecord.status , "INACTIVE");
                
                // set signer to non-admin (mallory)
                await signerFactory(tezos, mallory.sk);

                // start launch operation
                const startLaunchOperation = await launchpadInstance.methods.startLaunch(launchId);
                await chai.expect(startLaunchOperation.send()).to.be.rejected;

                launchpadStorage        = await launchpadInstance.storage()
                launchRecord            = await launchpadStorage.launchLedger.get(launchId);

                assert.equal(launchRecord.status , "INACTIVE");

            } catch (e) {
                console.log(e)
            }
        })

    })


    describe('%pauseLaunch and %unpauseLaunch', function () {
        
        beforeEach("Set signer to admin (eve)", async () => {
            launchpadStorage = await launchpadInstance.storage()
            await signerFactory(tezos, adminSk);
        });


        it('admin (eve) should be able to pause a launch', async () => {
            try {

                launchId                   = firstLaunchId;
                launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                assert.equal(launchRecord.status , "ACTIVE");

                // pause launch operation
                const pauseLaunchOperation = await launchpadInstance.methods.pauseLaunch(launchId).send();
                await pauseLaunchOperation.confirmation();

                launchpadStorage        = await launchpadInstance.storage()
                launchRecord            = await launchpadStorage.launchLedger.get(launchId);

                assert.equal(launchRecord.status , "PAUSED");

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should not be able to pause a launch if it is already paused', async () => {
            try {

                launchId                   = firstLaunchId;
                launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                assert.equal(launchRecord.status , "PAUSED");

                // pause launch operation
                const pauseLaunchOperation = await launchpadInstance.methods.pauseLaunch(launchId);
                await chai.expect(pauseLaunchOperation.send()).to.be.rejected;

                launchpadStorage        = await launchpadInstance.storage()
                launchRecord            = await launchpadStorage.launchLedger.get(launchId);

                assert.equal(launchRecord.status , "PAUSED");

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should not be able to pause a launch if it is not active (not yet started)', async () => {
            try {

                launchId                   = secondLaunchId;
                launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                assert.equal(launchRecord.status , "INACTIVE");

                // pause launch operation
                const pauseLaunchOperation = await launchpadInstance.methods.pauseLaunch(launchId);
                await chai.expect(pauseLaunchOperation.send()).to.be.rejected;

                launchpadStorage        = await launchpadInstance.storage()
                launchRecord            = await launchpadStorage.launchLedger.get(launchId);

                assert.equal(launchRecord.status , "INACTIVE");

            } catch (e) {
                console.log(e)
            }
        })

        it('non-admin (mallory) should not be able to unpause a launch', async () => {
            try {

                // set signer to mallory
                await signerFactory(tezos, mallory.sk)

                launchId                   = firstLaunchId;
                launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                assert.equal(launchRecord.status , "PAUSED");

                // unpause launch operation
                const unpauseLaunchOperation = await launchpadInstance.methods.unpauseLaunch(launchId);
                await chai.expect(unpauseLaunchOperation.send()).to.be.rejected;

                launchpadStorage        = await launchpadInstance.storage()
                launchRecord            = await launchpadStorage.launchLedger.get(launchId);

                assert.equal(launchRecord.status , "PAUSED");

            } catch (e) {
                console.log(e)
            }
        })

        it('admin (eve) should be able to unpause a launch', async () => {
            try {

                launchId                   = firstLaunchId;
                launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                assert.equal(launchRecord.status , "PAUSED");

                // unpause launch operation
                const unpauseLaunchOperation = await launchpadInstance.methods.unpauseLaunch(launchId).send();
                await unpauseLaunchOperation.confirmation();

                launchpadStorage        = await launchpadInstance.storage()
                launchRecord            = await launchpadStorage.launchLedger.get(launchId);

                assert.equal(launchRecord.status , "ACTIVE");

            } catch (e) {
                console.log(e)
            }
        })


        it('admin (eve) should not be able to unpause a launch that is not paused', async () => {
            try {

                // set signer to mallory

                launchId                   = firstLaunchId;
                launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                assert.equal(launchRecord.status , "ACTIVE");

                // unpause launch operation
                const unpauseLaunchOperation = await launchpadInstance.methods.unpauseLaunch(launchId);
                await chai.expect(unpauseLaunchOperation.send()).to.be.rejected;

                launchpadStorage        = await launchpadInstance.storage()
                launchRecord            = await launchpadStorage.launchLedger.get(launchId);

                assert.equal(launchRecord.status , "ACTIVE");

            } catch (e) {
                console.log(e)
            }
        })
    
    })

    describe('Whitelist Period tests', function () {
        
        before("setup launch", async() => {

            launchId                        = firstLaunchId;

            const newName                   = "editTokenLaunch";
            const newTokenIssuanceType      = "TRANSFER";
            const newTokenDistributionType  = "MANUAL";
            const newTokenContractAddress   = null;
            const newTokenId                = null;
            const newSaleStart              = makeTimestamp(100);
            const newSaleEnd                = makeTimestamp(1000);
            const newWhitelistSaleStart     = makeTimestamp(15);
            const newWhitelistSaleEnd       = makeTimestamp(120);

            const newSaleOptions                = null
            const newDefaultWhitelistOptions    = null

            // edit token launch operation
            const editTokenLaunchOperation = await launchpadInstance.methods.editTokenLaunch(
                launchId,
                newName,
                newTokenIssuanceType,
                newTokenDistributionType,
                newTokenContractAddress,
                newTokenId,
                newSaleStart,
                newSaleEnd,
                newWhitelistSaleStart,
                newWhitelistSaleEnd,
                newSaleOptions,
                newDefaultWhitelistOptions
            ).send()
            await editTokenLaunchOperation.confirmation();


            // set launch whitelist operation 
            // i) mallory - default whitelist option - "whitelist" : 5,000,000 
            // ii) alice - custom whitelist option - "whitelist" : 2,000,000
            // iii) oscar - custom whitelist option - "default" : 2,000,000, "whitelist" : 3,000,000


            // i) mallory - default whitelist option - "whitelist" : 5,000,000 
            let whitelistedUser = mallory.pkh;
            let setLaunchWhitelistOperation = await launchpadInstance.methods.setLaunchWhitelist(
                [
                    {
                        launchId                : launchId,
                        whitelistUserAddress    : whitelistedUser,
                        defaultWhitelistOption  : true,
                        whitelistOptions        : null
                    }
                ]
            ).send()
            await setLaunchWhitelistOperation.confirmation();


            // ii) alice - custom whitelist option - "whitelist" : 2,000,000
            whitelistedUser            = alice.pkh;
            let whitelistOptionValue   = 2000000;
            let whitelistOptions       = MichelsonMap.fromLiteral({
                'whitelist' : whitelistOptionValue
            });

            setLaunchWhitelistOperation = await launchpadInstance.methods.setLaunchWhitelist(
                [
                    {
                        launchId                : launchId,
                        whitelistUserAddress    : whitelistedUser,
                        defaultWhitelistOption  : false,
                        whitelistOptions        : whitelistOptions
                    }
                ]
            ).send()
            await setLaunchWhitelistOperation.confirmation();


            // iii) oscar - custom whitelist option - "default" : 2,000,000, "whitelist" : 3,000,000
            whitelistedUser        = oscar.pkh;
            whitelistOptionValue   = 3000000;
            let defaultOptionValue = 2000000;
            whitelistOptions       = MichelsonMap.fromLiteral({
                'default' : defaultOptionValue,
                'whitelist': whitelistOptionValue
            });

            setLaunchWhitelistOperation = await launchpadInstance.methods.setLaunchWhitelist(
                [
                    {
                        launchId                : launchId,
                        whitelistUserAddress    : whitelistedUser,
                        defaultWhitelistOption  : false,
                        whitelistOptions        : whitelistOptions
                    }
                ]
            ).send()
            await setLaunchWhitelistOperation.confirmation();

        })


        beforeEach("Set signer to user (mallory)", async () => {
            user    = mallory.pkh;
            userSk  = mallory.sk;
            launchpadStorage = await launchpadInstance.storage()
            await signerFactory(tezos, userSk);
        });

        it('%purchase - whitelisted user (mallory) should not be able to purchase tokens from launch before whitelist sale start time', async () => {
            try {

                launchId                   = firstLaunchId;
                launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                assert.equal(launchRecord.status , "ACTIVE");

                launchWhitelistRecord      = await launchpadStorage.launchWhitelistLedger.get([launchId, user]);
                assert.notEqual(launchWhitelistRecord, undefined);

                const whitelistSaleStartTimestamp    = launchRecord.whitelistSaleStart;
                const currentTimestamp               = makeTimestamp(0);

                const amount            = 1000000;
                const saleOption        = "default";
                
                // purchase operation
                const purchaseOperation = await launchpadInstance.methods.purchase(
                    launchId,
                    amount,
                    saleOption
                );
                await chai.expect(purchaseOperation.send()).to.be.rejected;

                launchpadStorage        = await launchpadInstance.storage()
                launchRecord            = await launchpadStorage.launchLedger.get(launchId);

                assert.equal(whitelistSaleStartTimestamp > currentTimestamp, true);

            } catch (e) {
                console.log(e)
            }
        })

        it('%purchase - non-whitelisted user (david) should not be able to purchase tokens from launch before whitelist sale start time', async () => {
            try {

                user   = david.pkh;
                userSk = david.sk;
                await signerFactory(tezos, userSk);

                launchId                   = firstLaunchId;
                launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                assert.equal(launchRecord.status , "ACTIVE");

                launchWhitelistRecord       = await launchpadStorage.launchWhitelistLedger.get([launchId, user]);
                assert.equal(launchWhitelistRecord, undefined);

                const whitelistSaleStartTimestamp    = launchRecord.whitelistSaleStart;
                const currentTimestamp               = makeTimestamp(0);

                const amount            = 1000000;
                const saleOption        = "default";
                
                // purchase operation
                const purchaseOperation = await launchpadInstance.methods.purchase(
                    launchId,
                    amount,
                    saleOption
                );
                await chai.expect(purchaseOperation.send()).to.be.rejected;

                launchpadStorage        = await launchpadInstance.storage()
                launchRecord            = await launchpadStorage.launchLedger.get(launchId);

                assert.equal(whitelistSaleStartTimestamp > currentTimestamp, true);

            } catch (e) {
                console.log(e)
            }
        })

        it('%purchase - whitelisted user (mallory) should be able to purchase tokens (whitelist sale option) from launch after whitelist sale start time', async () => {
            try {

                launchId                   = firstLaunchId;
                launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                assert.equal(launchRecord.status , "ACTIVE");

                launchWhitelistRecord       = await launchpadStorage.launchWhitelistLedger.get([launchId, user]);
                assert.notEqual(launchWhitelistRecord, undefined);

                const whitelistSaleStartTimestamp   = launchRecord.whitelistSaleStart;
                let currentTimestamp                = makeTimestamp(0);
                
                // wait for whitelist start time
                const differenceInMilliseconds = new Date(whitelistSaleStartTimestamp).getTime() - new Date(currentTimestamp).getTime();
                await wait(differenceInMilliseconds + 10);

                const amount            = 1000000;
                const saleOption        = "whitelist";
                currentTimestamp        = makeTimestamp(0);

                const initialDefaultSaleOption  = launchRecord.saleOptions.get(saleOption);
                const initialTotalBought        = initialDefaultSaleOption.totalBought;
                
                // purchase operation
                const purchaseOperation = await launchpadInstance.methods.purchase(
                    launchId,
                    amount,
                    saleOption
                ).send();
                await purchaseOperation.confirmation();

                launchpadStorage        = await launchpadInstance.storage()
                launchRecord            = await launchpadStorage.launchLedger.get(launchId);

                const updatedDefaultSaleOption  = launchRecord.saleOptions.get(saleOption);
                const updatedTotalBought        = updatedDefaultSaleOption.totalBought;

                assert.equal(currentTimestamp > whitelistSaleStartTimestamp, true);
                assert.equal(+updatedTotalBought, +initialTotalBought + +amount);

            } catch (e) {
                console.log(e)
            }
        })


        it('%purchase - whitelisted user (mallory) should not be able to purchase tokens (whitelist sale option) beyond her allowed limit', async () => {
            try {

                const saleOption        = "whitelist";

                launchId                   = firstLaunchId;
                launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                assert.equal(launchRecord.status , "ACTIVE");

                launchWhitelistRecord       = await launchpadStorage.launchWhitelistLedger.get([launchId, user]);
                assert.notEqual(launchWhitelistRecord, undefined);
                const allowedAmount         = launchWhitelistRecord.get(saleOption);

                const amount                = allowedAmount + 100;
                
                // purchase operation
                const purchaseOperation = await launchpadInstance.methods.purchase(
                    launchId,
                    amount,
                    saleOption
                );
                await chai.expect(purchaseOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })


        it('%purchase - whitelisted user (mallory) should not be able to purchase tokens (default sale option) she is not whitelisted for', async () => {
            try {

                const saleOption           = "default";

                launchId                   = firstLaunchId;
                launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                assert.equal(launchRecord.status , "ACTIVE");

                // user is in the whitelist record
                launchWhitelistRecord       = await launchpadStorage.launchWhitelistLedger.get([launchId, user]);
                assert.notEqual(launchWhitelistRecord, undefined);
                
                // user is not whitelisted for the specified sale option
                const allowedAmount         = launchWhitelistRecord.get(saleOption);
                assert.equal(allowedAmount, undefined);

                const amount                = 1000000;
                
                // purchase operation
                const purchaseOperation = await launchpadInstance.methods.purchase(
                    launchId,
                    amount,
                    saleOption
                );
                await chai.expect(purchaseOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })


        it('%purchase - non-whitelisted user (david) should not be able to purchase tokens (whitelist sale option) from launch after whitelist sale start time', async () => {
            try {

                user    = david.pkh;
                userSk  = david.sk;
                await signerFactory(tezos, userSk);

                launchId                   = firstLaunchId;
                launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                assert.equal(launchRecord.status , "ACTIVE");

                // user is not whitelisted
                launchWhitelistRecord       = await launchpadStorage.launchWhitelistLedger.get([launchId, user]);
                assert.equal(launchWhitelistRecord, undefined);

                const amount            = 1000000;
                const saleOption        = "whitelist";
                
                // purchase operation
                const purchaseOperation = await launchpadInstance.methods.purchase(
                    launchId,
                    amount,
                    saleOption
                );
                await chai.expect(purchaseOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

        // it('%purchase - user (mallory) should be able to purchase tokens from launch', async () => {
        //     try {

        //         launchId                   = firstLaunchId;
        //         launchRecord               = await launchpadStorage.launchLedger.get(launchId);
        //         assert.equal(launchRecord.status , "ACTIVE");

        //         const initialDefaultSaleOption  = launchRecord.saleOptions.get('default');
        //         const initialTotalBought        = initialDefaultSaleOption.totalBought;

        //         const amount            = 1000000;
        //         const saleOption        = "default";
        //         const currentTimestamp  = makeTimestamp(0);

        //         // purchase operation
        //         const purchaseOperation = await launchpadInstance.methods.purchase(
        //             launchId,
        //             amount,
        //             saleOption
        //         ).send();
        //         await purchaseOperation.confirmation();

        //         launchpadStorage        = await launchpadInstance.storage()
        //         launchRecord            = await launchpadStorage.launchLedger.get(launchId);

        //         const updatedDefaultSaleOption  = launchRecord.saleOptions.get('default');
        //         const updatedTotalBought        = updatedDefaultSaleOption.totalBought;
        //         const saleStartTimestamp        = launchRecord.saleStart;

        //         console.log(`currentTimestamp: ${currentTimestamp}`);
        //         console.log(`saleStartTimestamp: ${saleStartTimestamp}`);
        //         console.log(`currentTimestamp > saleStartTimestamp: ${currentTimestamp > saleStartTimestamp}`);

        //         assert.equal(currentTimestamp > saleStartTimestamp, true);
        //         assert.equal(updatedTotalBought, initialTotalBought + amount);


        //     } catch (e) {
        //         console.log(e)
        //     }
        // })

    })


    
})
