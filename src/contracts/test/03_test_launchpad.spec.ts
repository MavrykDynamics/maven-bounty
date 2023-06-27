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
import { mockTokenSaleOptions, mockTokenSalePayment } from 'test/helpers/mockSampleData'

// ------------------------------------------------------------------------------
// Contract Helpers
// ------------------------------------------------------------------------------

import { bob, alice, eve, mallory, oscar, david } from '../scripts/sandbox/accounts'
import { 
    signerFactory,
    almostEqual,
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

    let initialUserTokenBalance
    let updatedUserTokenBalance

    let initialTreasuryTokenBalance
    let updatedTreasuryTokenBalance

    let initialUserPurchaseRecord
    let updatedUserPurchaseRecord

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

    let securityTokenAddress 
    let securityTokenInstance
    let securityTokenStorage

    let treasuryAddress
    
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
    let approveOperation
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

        treasuryAddress = bob.pkh;

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

        securityTokenAddress            = contractDeployments.securityToken.address;
        securityTokenInstance           = await utils.tezos.contract.at(securityTokenAddress);
        securityTokenStorage            = await securityTokenInstance.storage()

        console.log('-- -- -- -- -- -- -- -- -- -- -- -- --')

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
                const tokenContractAddress      = securityTokenAddress;
                const tokenId                   = 0;
                const maxAmountCap              = 1000000000;
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
                    maxAmountCap,
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
                assert.equal(launchRecord.maxAmountCap            , maxAmountCap);
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
                const tokenContractAddress      = securityTokenAddress;
                const tokenId                   = 0;
                const maxAmountCap              = 1000000000;
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
                    maxAmountCap,
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
                assert.equal(launchRecord.maxAmountCap            , maxAmountCap);
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
                const tokenContractAddress      = securityTokenAddress;
                const tokenId                   = 0;
                const maxAmountCap              = 1000000000;
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
                    maxAmountCap,
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
                assert.equal(launchRecord.maxAmountCap            , maxAmountCap);
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
                const tokenContractAddress      = securityTokenAddress;
                const tokenId                   = 0;
                const maxAmountCap              = 1000000000;
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
                    maxAmountCap,
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
                const tokenContractAddress      = securityTokenAddress;
                const tokenId                   = 0;
                const maxAmountCap              = 1000000000;
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
                    maxAmountCap,
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
                const tokenContractAddress      = securityTokenAddress;
                const tokenId                   = 0;
                const maxAmountCap              = 1000000000;
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
                    maxAmountCap,
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
                const tokenContractAddress      = securityTokenAddress;
                const tokenId                   = 0;
                const maxAmountCap              = 1000000000;
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
                    maxAmountCap,
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
                const newMaxAmountCap           = 2000000000;
                const newTotalBought            = 100;
                const newSaleStart              = makeTimestamp(60);
                const newSaleEnd                = makeTimestamp(600);
                const newWhitelistSaleStart     = null;
                const newWhitelistSaleEnd       = null;

                const newSaleOptions            = MichelsonMap.fromLiteral({
                    'default'           : mockTokenSaleOptions.default,
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
                    newMaxAmountCap,
                    newTotalBought,
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
                assert.equal(launchRecord.maxAmountCap            , newMaxAmountCap);
                assert.equal(launchRecord.totalBought             , newTotalBought);
                assert.equal(launchRecord.saleStart               , showMillisecondsDateFormat(newSaleStart));
                assert.equal(launchRecord.saleEnd                 , showMillisecondsDateFormat(newSaleEnd));
                
                // Get sale options
                const defaultSaleOption             = launchRecord.saleOptions.get('default');

                // Check Default Sale Option
                assert.equal(defaultSaleOption.maxAmountCap             , mockTokenSaleOptions.default.maxAmountCap);
                assert.equal(defaultSaleOption.totalBought              , mockTokenSaleOptions.default.totalBought);
                assert.equal(defaultSaleOption.minPurchaseAmount        , mockTokenSaleOptions.default.minPurchaseAmount);
                assert.equal(defaultSaleOption.maxAmountPerWalletTotal  , mockTokenSaleOptions.default.maxAmountPerWalletTotal);

                const defaultSaleOptionFa2TokenPayment  = defaultSaleOption.payments.get('fa2Token');
                const defaultSaleOptionFa12TokenPayment = defaultSaleOption.payments.get('fa12Token');
                const defaultSaleOptionTezTokenPayment  = defaultSaleOption.payments.get('tez');

                // fa2 payment price
                assert.equal(defaultSaleOptionFa2TokenPayment.price                                         , mockTokenSalePayment.default.fa2Token.price);
                assert.equal(getTokenInfo(defaultSaleOptionFa2TokenPayment.currency, "tokenContractAddress"), mockTokenSalePayment.default.fa2Token.currency.fa2.tokenContractAddress);
                assert.equal(getTokenInfo(defaultSaleOptionFa2TokenPayment.currency, "tokenId")             , mockTokenSalePayment.default.fa2Token.currency.fa2.tokenId);

                // fa12 payment price
                assert.equal(defaultSaleOptionFa12TokenPayment.price                                         , mockTokenSalePayment.default.fa12Token.price);
                assert.equal(getTokenInfo(defaultSaleOptionFa12TokenPayment.currency, "tokenContractAddress"), mockTokenSalePayment.default.fa12Token.currency.fa12);

                // tez payment price
                assert.equal(defaultSaleOptionTezTokenPayment.price                                          , mockTokenSalePayment.default.tez.price);
                assert.equal(getTokenInfo(defaultSaleOptionTezTokenPayment.currency, "tokenContractAddress") , mockTokenSalePayment.default.tez.currency.tez);
                

                const defaultWhitelistSaleOption                 = launchRecord.saleOptions.get('whitelist');
                const defaultWhitelistSaleOptionFa2TokenPayment  = defaultWhitelistSaleOption.payments.get('fa2Token');
                const defaultWhitelistSaleOptionFa12TokenPayment = defaultWhitelistSaleOption.payments.get('fa12Token');
                const defaultWhitelistSaleOptionTezTokenPayment  = defaultWhitelistSaleOption.payments.get('tez');

                // Check Default Whitelist Sale Option
                assert.equal(defaultWhitelistSaleOption.maxAmountCap             , mockTokenSaleOptions.whitelist.maxAmountCap);
                assert.equal(defaultWhitelistSaleOption.totalBought              , mockTokenSaleOptions.whitelist.totalBought);
                assert.equal(defaultWhitelistSaleOption.minPurchaseAmount        , mockTokenSaleOptions.whitelist.minPurchaseAmount);
                assert.equal(defaultWhitelistSaleOption.maxAmountPerWalletTotal  , mockTokenSaleOptions.whitelist.maxAmountPerWalletTotal);

                // fa2 payment price
                assert.equal(defaultWhitelistSaleOptionFa2TokenPayment.price                                         , mockTokenSalePayment.whitelist.fa2Token.price);
                assert.equal(getTokenInfo(defaultWhitelistSaleOptionFa2TokenPayment.currency, "tokenContractAddress"), mockTokenSalePayment.whitelist.fa2Token.currency.fa2.tokenContractAddress);
                assert.equal(getTokenInfo(defaultWhitelistSaleOptionFa2TokenPayment.currency, "tokenId")             , mockTokenSalePayment.whitelist.fa2Token.currency.fa2.tokenId);

                // fa12 payment price
                assert.equal(defaultWhitelistSaleOptionFa12TokenPayment.price                                         , mockTokenSalePayment.whitelist.fa12Token.price);
                assert.equal(getTokenInfo(defaultWhitelistSaleOptionFa12TokenPayment.currency, "tokenContractAddress"), mockTokenSalePayment.whitelist.fa12Token.currency.fa12);

                // tez payment price
                assert.equal(defaultWhitelistSaleOptionTezTokenPayment.price                                          , mockTokenSalePayment.whitelist.tez.price);
                assert.equal(getTokenInfo(defaultWhitelistSaleOptionTezTokenPayment.currency, "tokenContractAddress") , mockTokenSalePayment.whitelist.tez.currency.tez);
                
                
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
                const newMaxAmountCap           = 2000000000;
                const newTotalBought            = 100;
                const newSaleStart              = makeTimestamp(300);
                const newSaleEnd                = makeTimestamp(30);
                const newWhitelistSaleStart     = null;
                const newWhitelistSaleEnd       = null;

                const newSaleOptions            = MichelsonMap.fromLiteral({
                    'default'           : mockTokenSaleOptions.default,
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
                    newMaxAmountCap,
                    newTotalBought,
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
                const newMaxAmountCap           = 2000000000;
                const newTotalBought            = 100;
                const newSaleStart              = makeTimestamp(30);
                const newSaleEnd                = makeTimestamp(300);
                const newWhitelistSaleStart     = makeTimestamp(300);
                const newWhitelistSaleEnd       = makeTimestamp(30);

                const newSaleOptions            = MichelsonMap.fromLiteral({
                    'default'           : mockTokenSaleOptions.default,
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
                    newMaxAmountCap,
                    newTotalBought,
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
                const newMaxAmountCap           = 2000000000;
                const newTotalBought            = 100;
                const newSaleStart              = makeTimestamp(30);
                const newSaleEnd                = makeTimestamp(300);
                const newWhitelistSaleStart     = null;
                const newWhitelistSaleEnd       = null;

                const newSaleOptions            = MichelsonMap.fromLiteral({
                    'default'           : mockTokenSaleOptions.default,
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
                    newMaxAmountCap,
                    newTotalBought,
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
                const newMaxAmountCap           = 2000000000;
                const newTotalBought            = 100;
                const newSaleStart              = makeTimestamp(30);
                const newSaleEnd                = makeTimestamp(300);
                const newWhitelistSaleStart     = null;
                const newWhitelistSaleEnd       = null;

                const newSaleOptions            = MichelsonMap.fromLiteral({
                    'default'           : mockTokenSaleOptions.default,
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
                    newMaxAmountCap,
                    newTotalBought,
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
                const newMaxAmountCap           = 2000000000;
                const newTotalBought            = 100;
                const newSaleStart              = makeTimestamp(60);
                const newSaleEnd                = makeTimestamp(600);

                const newSaleOptions            = MichelsonMap.fromLiteral({
                    'default'           : mockTokenSaleOptions.default,
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
                    newMaxAmountCap,
                    newTotalBought,
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

    describe('%purchase tests', function () {
        
        before("setup launch", async() => {

            launchId                        = firstLaunchId;

            const newName                   = "editTokenLaunch";
            const newTokenIssuanceType      = "TRANSFER";
            const newTokenDistributionType  = "MANUAL";
            const newTokenContractAddress   = securityTokenAddress;
            const newTokenId                = null;
            const newMaxAmountCap           = null;
            const newTotalBought            = 0;
            const newSaleStart              = makeTimestamp(50);
            const newSaleEnd                = makeTimestamp(300);
            const newWhitelistSaleStart     = makeTimestamp(15);
            const newWhitelistSaleEnd       = makeTimestamp(150);

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
                newMaxAmountCap,
                newTotalBought,
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


        describe('Before whitelist sale start time', function () {

            beforeEach("Set signer to user (mallory)", async () => {
                user        = mallory.pkh;
                userSk      = mallory.sk;
                tokenId     = 0;
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
                    const payment           = "fa2Token";
                    
                    // purchase operation
                    const purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
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
                    const payment           = "fa2Token";
                    
                    // purchase operation
                    const purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
                    );
                    await chai.expect(purchaseOperation.send()).to.be.rejected;
    
                    launchpadStorage        = await launchpadInstance.storage()
                    launchRecord            = await launchpadStorage.launchLedger.get(launchId);
    
                    assert.equal(whitelistSaleStartTimestamp > currentTimestamp, true);
    
                } catch (e) {
                    console.log(e)
                }
            })
    
        })

        
        describe('After whitelist sale start time', function () {

            beforeEach("Set signer to user (mallory)", async () => {
                user        = mallory.pkh;
                userSk      = mallory.sk;
                tokenId     = 0;
                launchpadStorage = await launchpadInstance.storage()
                await signerFactory(tezos, userSk);
            });


            it('%purchase - whitelisted user (mallory) should be able to purchase tokens (whitelist sale option) from launch and pay in FA2 Tokens', async () => {
                try {
    
                    user        = mallory.pkh;
                    userSk      = mallory.sk;
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
                    const payment           = "fa2Token";
                    currentTimestamp        = makeTimestamp(0);
    
                    const initialDefaultSaleOption  = launchRecord.saleOptions.get(saleOption);
                    const initialTotalBought        = initialDefaultSaleOption.totalBought;
                    const saleOptionPayments        = initialDefaultSaleOption.payments.get(payment);
                    const price                     = saleOptionPayments.price;

                    const totalCost                 = price * (amount / 10**6);
                    
                    initialUserPurchaseRecord         = await launchpadStorage.purchaseLedger.get([launchId, user]);
                    const initialUserTotalPurchased   = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.totalPurchased;
                    const initialUserTotalDistributed = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.totalDistributed;
                    const initialUserPurchasedOption  = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.purchased.get(saleOption);
    
                    mockFa2TokenStorage             = await mockFa2TokenInstance.storage();
                    initialUserTokenBalance         = await mockFa2TokenStorage.ledger.get(user);
                    initialTreasuryTokenBalance     = await mockFa2TokenStorage.ledger.get(treasuryAddress);
    
                    // update operators operation
                    updateOperatorsOperation = await updateOperators(mockFa2TokenInstance, user, launchpadAddress, tokenId);
                    await updateOperatorsOperation.confirmation();
    
                    // purchase operation
                    const purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
                    ).send();
                    await purchaseOperation.confirmation();
    
                    launchpadStorage        = await launchpadInstance.storage()
                    mockFa2TokenStorage     = await mockFa2TokenInstance.storage()
    
                    launchRecord                    = await launchpadStorage.launchLedger.get(launchId);
                    updatedUserTokenBalance         = await mockFa2TokenStorage.ledger.get(user);
                    updatedTreasuryTokenBalance     = await mockFa2TokenStorage.ledger.get(treasuryAddress);
    
                    updatedUserPurchaseRecord         = await launchpadStorage.purchaseLedger.get([launchId, user]);
                    const updatedUserTotalPurchased   = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.totalPurchased;
                    const updatedUserTotalDistributed = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.totalDistributed;
                    const updatedUserPurchasedOption  = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.purchased.get(saleOption);
    
                    const updatedDefaultSaleOption  = launchRecord.saleOptions.get(saleOption);
                    const updatedTotalBought        = updatedDefaultSaleOption.totalBought;
    
                    assert.equal(currentTimestamp > whitelistSaleStartTimestamp, true);
                    assert.equal(+updatedTotalBought, +initialTotalBought + +amount);
    
                    // check user purchases
                    assert.equal(+updatedUserTotalPurchased, +initialUserTotalPurchased + +amount);
                    assert.equal(+updatedUserTotalDistributed, +initialUserTotalDistributed);
                    assert.equal(+updatedUserPurchasedOption, +initialUserPurchasedOption + +amount);
    
                    // check user balance for payment: mock FA2 token
                    assert.equal(+updatedUserTokenBalance, +initialUserTokenBalance - +totalCost);
    
                    // check treasury balance
                    assert.equal(+updatedTreasuryTokenBalance, +initialTreasuryTokenBalance + +totalCost);
    
                } catch (e) {
                    console.log(e)
                }
            })
    
            it('%purchase - whitelisted user (mallory) should be able to purchase tokens (whitelist sale option) from launch and pay in FA12 Tokens', async () => {
                try {
    
                    user        = mallory.pkh;
                    userSk      = mallory.sk;
                    launchId                   = firstLaunchId;
                    launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                    assert.equal(launchRecord.status , "ACTIVE");
    
                    launchWhitelistRecord       = await launchpadStorage.launchWhitelistLedger.get([launchId, user]);
                    assert.notEqual(launchWhitelistRecord, undefined);
    
                    const amount            = 1000000;
                    const saleOption        = "whitelist";
                    const payment           = "fa12Token";

                    const defaultWhitelistSaleOption     = launchRecord.saleOptions.get(saleOption);
                    const saleOptionPayments             = defaultWhitelistSaleOption.payments.get(payment);
                    const price                          = saleOptionPayments.price;

                    const totalCost                 = price * (amount / 10**6);
    
                    const initialDefaultSaleOption  = launchRecord.saleOptions.get(saleOption);
                    const initialTotalBought        = initialDefaultSaleOption.totalBought;
                    
                    initialUserPurchaseRecord         = await launchpadStorage.purchaseLedger.get([launchId, user]);
                    const initialUserTotalPurchased   = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.totalPurchased;
                    const initialUserTotalDistributed = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.totalDistributed;
                    const initialUserPurchasedOption  = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.purchased.get(saleOption);
    
                    mockFa12TokenStorage             = await mockFa12TokenInstance.storage();
                    initialUserTokenBalance          = (await mockFa12TokenStorage.ledger.get(user)).balance.toNumber();
                    initialTreasuryTokenBalance      = (await mockFa12TokenStorage.ledger.get(treasuryAddress)).balance.toNumber();
    
                    // approve operation
                    approveOperation = await mockFa12TokenInstance.methods.approve(launchpadAddress, totalCost).send();
                    await approveOperation.confirmation();
    
                    // purchase operation
                    const purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
                    ).send();
                    await purchaseOperation.confirmation();
                    
                    // approve operation
                    approveOperation = await mockFa12TokenInstance.methods.approve(launchpadAddress, 0).send();
                    await approveOperation.confirmation();
    
                    launchpadStorage        = await launchpadInstance.storage()
                    mockFa12TokenStorage    = await mockFa12TokenInstance.storage()
    
                    launchRecord                    = await launchpadStorage.launchLedger.get(launchId);
                    updatedUserTokenBalance         = (await mockFa12TokenStorage.ledger.get(user)).balance.toNumber();
                    updatedTreasuryTokenBalance     = (await mockFa12TokenStorage.ledger.get(treasuryAddress)).balance.toNumber();
    
                    updatedUserPurchaseRecord         = await launchpadStorage.purchaseLedger.get([launchId, user]);
                    const updatedUserTotalPurchased   = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.totalPurchased;
                    const updatedUserTotalDistributed = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.totalDistributed;
                    const updatedUserPurchasedOption  = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.purchased.get(saleOption);
    
                    const updatedDefaultSaleOption  = launchRecord.saleOptions.get(saleOption);
                    const updatedTotalBought        = updatedDefaultSaleOption.totalBought;
    
                    assert.equal(+updatedTotalBought, +initialTotalBought + +amount);
    
                    // check user purchases
                    assert.equal(+updatedUserTotalPurchased, +initialUserTotalPurchased + +amount);
                    assert.equal(+updatedUserTotalDistributed, +initialUserTotalDistributed);
                    assert.equal(+updatedUserPurchasedOption, +initialUserPurchasedOption + +amount);
    
                    // check user balance for payment: mock FA2 token
                    assert.equal(+updatedUserTokenBalance, +initialUserTokenBalance - +totalCost);
    
                    // check treasury balance
                    assert.equal(+updatedTreasuryTokenBalance, +initialTreasuryTokenBalance + +totalCost);
    
                } catch (e) {
                    console.log(e)
                }
            })
    
    
            it('%purchase - whitelisted user (mallory) should be able to purchase tokens (whitelist sale option) from launch and pay in Tez', async () => {
                try {
    
                    launchId                   = firstLaunchId;
                    launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                    assert.equal(launchRecord.status , "ACTIVE");
    
                    launchWhitelistRecord       = await launchpadStorage.launchWhitelistLedger.get([launchId, user]);
                    assert.notEqual(launchWhitelistRecord, undefined);
    
                    const amount            = 1000000;
                    const saleOption        = "whitelist";
                    const payment           = "tez";

                    const defaultWhitelistSaleOption     = launchRecord.saleOptions.get(saleOption);
                    const saleOptionPayments             = defaultWhitelistSaleOption.payments.get(payment);
                    const initialTotalBought             = defaultWhitelistSaleOption.totalBought;
                    const priceInMutez                   = saleOptionPayments.price;

                    const totalCostInMutez  = priceInMutez * (amount / 10**6);
    
                    initialUserPurchaseRecord         = await launchpadStorage.purchaseLedger.get([launchId, user]);
                    const initialUserTotalPurchased   = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.totalPurchased;
                    const initialUserTotalDistributed = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.totalDistributed;
                    const initialUserPurchasedOption  = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.purchased.get(saleOption);
                    
                    const initialUserTezBalance     = await utils.tezos.tz.getBalance(user);
                    const initialTreasuryTezBalance = await utils.tezos.tz.getBalance(treasuryAddress);
    
                    // purchase operation
                    const purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
                    ).send({ amount: totalCostInMutez, mutez: true});
                    await purchaseOperation.confirmation();
    
                    launchpadStorage        = await launchpadInstance.storage()
                    launchRecord            = await launchpadStorage.launchLedger.get(launchId);
    
                    const updatedDefaultSaleOption  = launchRecord.saleOptions.get(saleOption);
                    const updatedTotalBought        = updatedDefaultSaleOption.totalBought;
    
                    updatedUserPurchaseRecord         = await launchpadStorage.purchaseLedger.get([launchId, user]);
                    const updatedUserTotalPurchased   = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.totalPurchased;
                    const updatedUserTotalDistributed = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.totalDistributed;
                    const updatedUserPurchasedOption  = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.purchased.get(saleOption);
    
                    const updatedUserTezBalance     = await utils.tezos.tz.getBalance(user);
                    const updatedTreasuryTezBalance = await utils.tezos.tz.getBalance(treasuryAddress);
    
                    assert.equal(+updatedTotalBought, +initialTotalBought + +amount);
    
                    // check user purchases
                    assert.equal(+updatedUserTotalPurchased, +initialUserTotalPurchased + +amount);
                    assert.equal(+updatedUserTotalDistributed, +initialUserTotalDistributed);
                    assert.equal(+updatedUserPurchasedOption, +initialUserPurchasedOption + +amount);
    
                    // check user balance for payment: tez
                    assert.equal(almostEqual(+updatedUserTezBalance, +initialUserTezBalance - +totalCostInMutez, 0.01), true);
    
                    // check treasury balance
                    assert.equal(+updatedTreasuryTezBalance, +initialTreasuryTezBalance + +totalCostInMutez);
    
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
                    const payment               = "fa2Token";
                    
                    // purchase operation
                    const purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
                    );
                    await chai.expect(purchaseOperation.send()).to.be.rejected;
    
                } catch (e) {
                    console.log(e)
                }
            })

            it('%purchase - whitelisted user (mallory) should not be able to purchase tokens (whitelist sale option) below the minPurchaseAmount', async () => {
                try {

    
                    launchId                   = firstLaunchId;
                    launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                    assert.equal(launchRecord.status , "ACTIVE");
    
                    launchWhitelistRecord       = await launchpadStorage.launchWhitelistLedger.get([launchId, user]);
                    assert.notEqual(launchWhitelistRecord, undefined);

                    const saleOption                     = "whitelist";
                    const defaultWhitelistSaleOption     = launchRecord.saleOptions.get(saleOption);
                    const minPurchaseAmount              = defaultWhitelistSaleOption.minPurchaseAmount;
    
                    const amount                = minPurchaseAmount - 1;
                    const payment               = "fa2Token";
                    
                    // purchase operation
                    const purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
                    );
                    await chai.expect(purchaseOperation.send()).to.be.rejected;
    
                } catch (e) {
                    console.log(e)
                }
            })
    
    
            it('%purchase - whitelisted user (mallory) should not be able to purchase tokens (default sale option) that is not whitelisted', async () => {
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
                    const payment               = "fa2Token";
    
                    // purchase operation
                    const purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
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
                    const payment           = "fa2Token";
                    
                    // purchase operation
                    const purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
                    );
                    await chai.expect(purchaseOperation.send()).to.be.rejected;
    
                } catch (e) {
                    console.log(e)
                }
            })
    
        })

        describe('Before sale start time', function () {

            beforeEach("Set signer to user (mallory)", async () => {
                user        = mallory.pkh;
                userSk      = mallory.sk;
                tokenId     = 0;
                launchpadStorage = await launchpadInstance.storage()
                await signerFactory(tezos, userSk);
            });

            it('%purchase - whitelisted user (mallory) should not be able to purchase tokens from launch before sale start time', async () => {
                try {
    
                    launchId                   = firstLaunchId;
                    launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                    assert.equal(launchRecord.status , "ACTIVE");
    
                    const saleStartTimestamp    = launchRecord.saleStart;
                    const currentTimestamp      = makeTimestamp(0);
    
                    const amount            = 1000000;
                    const saleOption        = "default";
                    const payment           = "fa2Token";
                    
                    // purchase operation
                    const purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
                    );
                    await chai.expect(purchaseOperation.send()).to.be.rejected;
    
                    launchpadStorage        = await launchpadInstance.storage()
                    launchRecord            = await launchpadStorage.launchLedger.get(launchId);
    
                    assert.equal(saleStartTimestamp > currentTimestamp, true);
    
                } catch (e) {
                    console.log(e)
                }
            })
    
            it('%purchase - non-whitelisted user (david) should not be able to purchase tokens from launch before sale start time', async () => {
                try {
    
                    user   = david.pkh;
                    userSk = david.sk;
                    await signerFactory(tezos, userSk);
    
                    launchId                   = firstLaunchId;
                    launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                    assert.equal(launchRecord.status , "ACTIVE");
    
                    const saleStartTimestamp    = launchRecord.saleStart;
                    const currentTimestamp      = makeTimestamp(0);
    
                    const amount            = 1000000;
                    const saleOption        = "default";
                    const payment           = "fa2Token";
                    
                    // purchase operation
                    const purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
                    );
                    await chai.expect(purchaseOperation.send()).to.be.rejected;
    
                    launchpadStorage        = await launchpadInstance.storage()
                    launchRecord            = await launchpadStorage.launchLedger.get(launchId);
    
                    assert.equal(saleStartTimestamp > currentTimestamp, true);
    
                } catch (e) {
                    console.log(e)
                }
            })
    
        })

        describe('After sale start time', function () {

            beforeEach("Set signer to user (david)", async () => {
                user        = david.pkh;
                userSk      = david.sk;
                tokenId     = 0;
                launchpadStorage = await launchpadInstance.storage()
                await signerFactory(tezos, userSk);
            });
    

            it('%purchase - non-whitelisted user (david) should be able to purchase tokens (default sale option) from launch and pay in FA2 Tokens', async () => {
                try {
    
                    user        = david.pkh;
                    userSk      = david.sk;
                    launchId                   = firstLaunchId;
                    launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                    assert.equal(launchRecord.status , "ACTIVE");
    
                    const saleStartTimestamp   = launchRecord.saleStart;
                    let currentTimestamp       = makeTimestamp(0);
                    
                    // wait for whitelist start time
                    const differenceInMilliseconds = new Date(saleStartTimestamp).getTime() - new Date(currentTimestamp).getTime();
                    await wait(differenceInMilliseconds + 10);
    
                    const amount            = 1000000;
                    const saleOption        = "default";
                    const payment           = "fa2Token";

                    const defaultSaleOption         = launchRecord.saleOptions.get(saleOption);
                    const initialTotalBought        = defaultSaleOption.totalBought;
                    const saleOptionPayments        = defaultSaleOption.payments.get(payment);
                    const price                     = saleOptionPayments.price;
                    
                    const totalCost                 = price * (amount / 10**6);
                    currentTimestamp                = makeTimestamp(0);
                    
                    initialUserPurchaseRecord         = await launchpadStorage.purchaseLedger.get([launchId, user]);
                    const initialUserTotalPurchased   = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.totalPurchased;
                    const initialUserTotalDistributed = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.totalDistributed;
                    const initialUserPurchasedOption  = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.purchased.get(saleOption);
    
                    mockFa2TokenStorage             = await mockFa2TokenInstance.storage();
                    initialUserTokenBalance         = await mockFa2TokenStorage.ledger.get(user);
                    initialTreasuryTokenBalance     = await mockFa2TokenStorage.ledger.get(treasuryAddress);
    
                    // update operators operation
                    updateOperatorsOperation = await updateOperators(mockFa2TokenInstance, user, launchpadAddress, tokenId);
                    await updateOperatorsOperation.confirmation();
    
                    // purchase operation
                    const purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
                    ).send();
                    await purchaseOperation.confirmation();
    
                    launchpadStorage        = await launchpadInstance.storage()
                    mockFa2TokenStorage     = await mockFa2TokenInstance.storage()
    
                    launchRecord                    = await launchpadStorage.launchLedger.get(launchId);
                    updatedUserTokenBalance         = await mockFa2TokenStorage.ledger.get(user);
                    updatedTreasuryTokenBalance     = await mockFa2TokenStorage.ledger.get(treasuryAddress);
    
                    updatedUserPurchaseRecord         = await launchpadStorage.purchaseLedger.get([launchId, user]);
                    const updatedUserTotalPurchased   = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.totalPurchased;
                    const updatedUserTotalDistributed = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.totalDistributed;
                    const updatedUserPurchasedOption  = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.purchased.get(saleOption);
    
                    const updatedDefaultSaleOption  = launchRecord.saleOptions.get(saleOption);
                    const updatedTotalBought        = updatedDefaultSaleOption.totalBought;
    
                    assert.equal(currentTimestamp > saleStartTimestamp, true);
                    assert.equal(+updatedTotalBought, +initialTotalBought + +amount);
    
                    // check user purchases
                    assert.equal(+updatedUserTotalPurchased, +initialUserTotalPurchased + +amount);
                    assert.equal(+updatedUserTotalDistributed, +initialUserTotalDistributed);
                    assert.equal(+updatedUserPurchasedOption, +initialUserPurchasedOption + +amount);

                    // check user balance for payment: mock FA2 token
                    assert.equal(+updatedUserTokenBalance, +initialUserTokenBalance - +totalCost);
    
                    // check treasury balance
                    assert.equal(+updatedTreasuryTokenBalance, +initialTreasuryTokenBalance + +totalCost);
    
                } catch (e) {
                    console.log(e)
                }
            })

            it('%purchase - non-whitelisted user (david) should be able to purchase tokens (default sale option) from launch and pay in FA12 Tokens', async () => {
                try {
    
                    launchId                   = firstLaunchId;
                    launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                    assert.equal(launchRecord.status , "ACTIVE");
    
                    const amount            = 1000000;
                    const saleOption        = "default";
                    const payment           = "fa12Token";

                    const defaultSaleOption           = launchRecord.saleOptions.get(saleOption);
                    const saleOptionPayments          = defaultSaleOption.payments.get(payment);
                    const initialTotalBought          = defaultSaleOption.totalBought;
                    const price                       = saleOptionPayments.price;

                    const totalCost                   = price * (amount / 10**6);
    
                    initialUserPurchaseRecord         = await launchpadStorage.purchaseLedger.get([launchId, user]);
                    const initialUserTotalPurchased   = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.totalPurchased;
                    const initialUserTotalDistributed = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.totalDistributed;
                    const initialUserPurchasedOption  = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.purchased.get(saleOption);
    
                    mockFa12TokenStorage             = await mockFa12TokenInstance.storage();
                    initialUserTokenBalance          = (await mockFa12TokenStorage.ledger.get(user)).balance.toNumber();
                    initialTreasuryTokenBalance      = (await mockFa12TokenStorage.ledger.get(treasuryAddress)).balance.toNumber();
    
                    // approve operation
                    approveOperation = await mockFa12TokenInstance.methods.approve(launchpadAddress, totalCost).send();
                    await approveOperation.confirmation();
    
                    // purchase operation
                    const purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
                    ).send();
                    await purchaseOperation.confirmation();
                    
                    // approve operation
                    approveOperation = await mockFa12TokenInstance.methods.approve(launchpadAddress, 0).send();
                    await approveOperation.confirmation();
    
                    launchpadStorage        = await launchpadInstance.storage()
                    mockFa12TokenStorage    = await mockFa12TokenInstance.storage()
    
                    launchRecord                    = await launchpadStorage.launchLedger.get(launchId);
                    updatedUserTokenBalance         = (await mockFa12TokenStorage.ledger.get(user)).balance.toNumber();
                    updatedTreasuryTokenBalance     = (await mockFa12TokenStorage.ledger.get(treasuryAddress)).balance.toNumber();
    
                    updatedUserPurchaseRecord         = await launchpadStorage.purchaseLedger.get([launchId, user]);
                    const updatedUserTotalPurchased   = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.totalPurchased;
                    const updatedUserTotalDistributed = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.totalDistributed;
                    const updatedUserPurchasedOption  = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.purchased.get(saleOption);
    
                    const updatedDefaultSaleOption  = launchRecord.saleOptions.get(saleOption);
                    const updatedTotalBought        = updatedDefaultSaleOption.totalBought;
    
                    assert.equal(+updatedTotalBought, +initialTotalBought + +amount);
    
                    // check user purchases
                    assert.equal(+updatedUserTotalPurchased, +initialUserTotalPurchased + +amount);
                    assert.equal(+updatedUserTotalDistributed, +initialUserTotalDistributed);
                    assert.equal(+updatedUserPurchasedOption, +initialUserPurchasedOption + +amount);
    
                    // check user balance for payment: mock FA2 token
                    assert.equal(+updatedUserTokenBalance, +initialUserTokenBalance - +totalCost);
    
                    // check treasury balance
                    assert.equal(+updatedTreasuryTokenBalance, +initialTreasuryTokenBalance + +totalCost);
    
                } catch (e) {
                    console.log(e)
                }
            })
    
    
            it('%purchase - non-whitelisted user (david) should be able to purchase tokens (default sale option) from launch and pay in Tez', async () => {
                try {
    
                    launchId                   = firstLaunchId;
                    launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                    assert.equal(launchRecord.status , "ACTIVE");
    
                    const amount            = 1000000;
                    const saleOption        = "default";
                    const payment           = "tez";

                    const defaultSaleOption              = launchRecord.saleOptions.get(saleOption);
                    const saleOptionPayments             = defaultSaleOption.payments.get(payment);
                    const priceInMutez                   = saleOptionPayments.price;

                    const totalCostInMutez  = priceInMutez * (amount / 10**6);
    
                    const initialDefaultSaleOption  = launchRecord.saleOptions.get(saleOption);
                    const initialTotalBought        = initialDefaultSaleOption.totalBought;
    
                    initialUserPurchaseRecord         = await launchpadStorage.purchaseLedger.get([launchId, user]);
                    const initialUserTotalPurchased   = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.totalPurchased;
                    const initialUserTotalDistributed = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.totalDistributed;
                    const initialUserPurchasedOption  = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.purchased.get(saleOption);
                    
                    const initialUserTezBalance     = await utils.tezos.tz.getBalance(user);
                    const initialTreasuryTezBalance = await utils.tezos.tz.getBalance(treasuryAddress);
    
                    // purchase operation
                    const purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
                    ).send({ amount: totalCostInMutez, mutez: true});
                    await purchaseOperation.confirmation();
    
                    launchpadStorage        = await launchpadInstance.storage()
                    launchRecord            = await launchpadStorage.launchLedger.get(launchId);
    
                    const updatedDefaultSaleOption  = launchRecord.saleOptions.get(saleOption);
                    const updatedTotalBought        = updatedDefaultSaleOption.totalBought;
    
                    updatedUserPurchaseRecord         = await launchpadStorage.purchaseLedger.get([launchId, user]);
                    const updatedUserTotalPurchased   = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.totalPurchased;
                    const updatedUserTotalDistributed = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.totalDistributed;
                    const updatedUserPurchasedOption  = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.purchased.get(saleOption);
    
                    const updatedUserTezBalance     = await utils.tezos.tz.getBalance(user);
                    const updatedTreasuryTezBalance = await utils.tezos.tz.getBalance(treasuryAddress);
    
                    assert.equal(+updatedTotalBought, +initialTotalBought + +amount);
    
                    // check user purchases
                    assert.equal(+updatedUserTotalPurchased, +initialUserTotalPurchased + +amount);
                    assert.equal(+updatedUserTotalDistributed, +initialUserTotalDistributed);
                    assert.equal(+updatedUserPurchasedOption, +initialUserPurchasedOption + +amount);
    
                    // check user balance for payment: tez
                    assert.equal(almostEqual(+updatedUserTezBalance, +initialUserTezBalance - +totalCostInMutez, 0.01), true);
    
                    // check treasury balance
                    assert.equal(+updatedTreasuryTezBalance, +initialTreasuryTezBalance + +totalCostInMutez);
    
                } catch (e) {
                    console.log(e)
                }
            })

            it('%purchase - non-whitelisted user (david) should not be able to purchase tokens with the whitelist sale option', async () => {
                try {
    
                    launchId                   = firstLaunchId;
                    launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                    assert.equal(launchRecord.status , "ACTIVE");
    
                    const amount            = 1000000;
                    const saleOption        = "whitelist";
                    var payment             = "fa12Token";

                    const saleOptionRecord       = launchRecord.saleOptions.get(saleOption);
                    const saleOptionFa12Payment  = saleOptionRecord.payments.get(payment);
                    const saleOptionFa12Price    = saleOptionFa12Payment.price;

                    // ------------------------------------------
                    // Payment: FA12 Token
                    // ------------------------------------------

                    let totalCost = saleOptionFa12Price * (amount / 10**6);

                    // approve operation
                    approveOperation = await mockFa12TokenInstance.methods.approve(launchpadAddress, totalCost).send();
                    await approveOperation.confirmation();
    
                    // purchase operation
                    let purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
                    );
                    await chai.expect(purchaseOperation.send()).to.be.rejected;

                    // approve operation
                    approveOperation = await mockFa12TokenInstance.methods.approve(launchpadAddress, 0).send();
                    await approveOperation.confirmation();
                    
                    // ------------------------------------------
                    // Payment: FA2 Token
                    // ------------------------------------------

                    // update operators operation
                    payment = "fa2Token";
                    updateOperatorsOperation = await updateOperators(mockFa2TokenInstance, user, launchpadAddress, tokenId);
                    await updateOperatorsOperation.confirmation();

                    purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
                    );
                    await chai.expect(purchaseOperation.send()).to.be.rejected;

                    // ------------------------------------------
                    // Payment: Tez
                    // ------------------------------------------

                    payment = "tez";
                    const saleOptionTezPayment  = saleOptionRecord.payments.get(payment);
                    const saleOptionTezPrice    = saleOptionTezPayment.price;
                    totalCost = saleOptionTezPrice * (amount / 10**6);

                    purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
                    );
                    await chai.expect(purchaseOperation.send({ amount: totalCost, mutez: true})).to.be.rejected;
    
                } catch (e) {
                    console.log(e)
                }
            })

            it('%purchase - non-whitelisted user (david) should not be able to purchase tokens (default sale option) beyond the max amount per wallet', async () => {
                try {

    
                    launchId                   = firstLaunchId;
                    launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                    assert.equal(launchRecord.status , "ACTIVE");
    
                    const saleOption              = "default";
                    const saleOptionRecord        = launchRecord.saleOptions.get(saleOption);
                    const maxAmountPerWalletTotal = saleOptionRecord.maxAmountPerWalletTotal;
    
                    const amount                = maxAmountPerWalletTotal + 100;
                    const payment               = "fa2Token";
                    
                    // purchase operation
                    const purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
                    );
                    await chai.expect(purchaseOperation.send()).to.be.rejected;
    
                } catch (e) {
                    console.log(e)
                }
            })

            it('%purchase - non-whitelisted user (david) should not be able to purchase tokens (default sale option) below the minPurchaseAmount', async () => {
                try {

    
                    launchId                   = firstLaunchId;
                    launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                    assert.equal(launchRecord.status , "ACTIVE");

                    const saleOption                     = "default";
                    const saleOptionRecord               = launchRecord.saleOptions.get(saleOption);
                    const minPurchaseAmount              = saleOptionRecord.minPurchaseAmount;
    
                    const amount                = minPurchaseAmount - 1;
                    const payment               = "fa2Token";
                    
                    // purchase operation
                    const purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
                    );
                    await chai.expect(purchaseOperation.send()).to.be.rejected;
    
                } catch (e) {
                    console.log(e)
                }
            })

            it('%purchase - whitelisted user (mallory) should be able to purchase tokens (default sale option) from launch and pay in FA2 Tokens', async () => {
                try {
    
                    user        = mallory.pkh;
                    userSk      = mallory.sk;
                    await signerFactory(tezos, userSk);

                    launchId                   = firstLaunchId;
                    launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                    assert.equal(launchRecord.status , "ACTIVE");
    
                    const amount            = 1000000;
                    const saleOption        = "default";
                    const payment           = "fa2Token";
    
                    const initialDefaultSaleOption  = launchRecord.saleOptions.get(saleOption);
                    const initialTotalBought        = initialDefaultSaleOption.totalBought;
                    const saleOptionPayments        = initialDefaultSaleOption.payments.get(payment);
                    const price                     = saleOptionPayments.price;

                    const totalCost                 = price * (amount / 10**6);
                    
                    initialUserPurchaseRecord         = await launchpadStorage.purchaseLedger.get([launchId, user]);
                    const initialUserTotalPurchased   = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.totalPurchased;
                    const initialUserTotalDistributed = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.totalDistributed;
                    const initialUserPurchasedOption  = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.purchased.get(saleOption) == undefined ? 0 : initialUserPurchaseRecord.purchased.get(saleOption);
    
                    mockFa2TokenStorage             = await mockFa2TokenInstance.storage();
                    initialUserTokenBalance         = await mockFa2TokenStorage.ledger.get(user);
                    initialTreasuryTokenBalance     = await mockFa2TokenStorage.ledger.get(treasuryAddress);
    
                    // update operators operation
                    updateOperatorsOperation = await updateOperators(mockFa2TokenInstance, user, launchpadAddress, tokenId);
                    await updateOperatorsOperation.confirmation();
    
                    // purchase operation
                    const purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
                    ).send();
                    await purchaseOperation.confirmation();
    
                    launchpadStorage        = await launchpadInstance.storage()
                    mockFa2TokenStorage     = await mockFa2TokenInstance.storage()
    
                    launchRecord                    = await launchpadStorage.launchLedger.get(launchId);
                    updatedUserTokenBalance         = await mockFa2TokenStorage.ledger.get(user);
                    updatedTreasuryTokenBalance     = await mockFa2TokenStorage.ledger.get(treasuryAddress);
    
                    updatedUserPurchaseRecord         = await launchpadStorage.purchaseLedger.get([launchId, user]);
                    const updatedUserTotalPurchased   = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.totalPurchased;
                    const updatedUserTotalDistributed = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.totalDistributed;
                    const updatedUserPurchasedOption  = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.purchased.get(saleOption);
    
                    const updatedDefaultSaleOption  = launchRecord.saleOptions.get(saleOption);
                    const updatedTotalBought        = updatedDefaultSaleOption.totalBought;
    
                    assert.equal(+updatedTotalBought, +initialTotalBought + +amount);
    
                    // check user purchases
                    assert.equal(+updatedUserTotalPurchased, +initialUserTotalPurchased + +amount);
                    assert.equal(+updatedUserTotalDistributed, +initialUserTotalDistributed);
                    assert.equal(+updatedUserPurchasedOption, +initialUserPurchasedOption + +amount);
    
                    // check user balance for payment: mock FA2 token
                    assert.equal(+updatedUserTokenBalance, +initialUserTokenBalance - +totalCost);
    
                    // check treasury balance
                    assert.equal(+updatedTreasuryTokenBalance, +initialTreasuryTokenBalance + +totalCost);
    
                } catch (e) {
                    console.log(e)
                }
            })
    
            it('%purchase - whitelisted user (mallory) should be able to purchase tokens (default sale option) from launch and pay in FA12 Tokens', async () => {
                try {
    
                    user        = mallory.pkh;
                    userSk      = mallory.sk;
                    await signerFactory(tezos, userSk);

                    launchId                   = firstLaunchId;
                    launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                    assert.equal(launchRecord.status , "ACTIVE");
    
                    const amount            = 1000000;
                    const saleOption        = "default";
                    const payment           = "fa12Token";

                    const defaultSaleOption           = launchRecord.saleOptions.get(saleOption);
                    const saleOptionPayments          = defaultSaleOption.payments.get(payment);
                    const initialTotalBought          = defaultSaleOption.totalBought;
                    const price                       = saleOptionPayments.price;

                    const totalCost                   = price * (amount / 10**6);
                    
                    initialUserPurchaseRecord         = await launchpadStorage.purchaseLedger.get([launchId, user]);
                    const initialUserTotalPurchased   = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.totalPurchased;
                    const initialUserTotalDistributed = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.totalDistributed;
                    const initialUserPurchasedOption  = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.purchased.get(saleOption);
    
                    mockFa12TokenStorage             = await mockFa12TokenInstance.storage();
                    initialUserTokenBalance          = (await mockFa12TokenStorage.ledger.get(user)).balance.toNumber();
                    initialTreasuryTokenBalance      = (await mockFa12TokenStorage.ledger.get(treasuryAddress)).balance.toNumber();
    
                    // approve operation
                    approveOperation = await mockFa12TokenInstance.methods.approve(launchpadAddress, totalCost).send();
                    await approveOperation.confirmation();
    
                    // purchase operation
                    const purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
                    ).send();
                    await purchaseOperation.confirmation();
                    
                    // approve operation
                    approveOperation = await mockFa12TokenInstance.methods.approve(launchpadAddress, 0).send();
                    await approveOperation.confirmation();
    
                    launchpadStorage        = await launchpadInstance.storage()
                    mockFa12TokenStorage    = await mockFa12TokenInstance.storage()
    
                    launchRecord                    = await launchpadStorage.launchLedger.get(launchId);
                    updatedUserTokenBalance         = (await mockFa12TokenStorage.ledger.get(user)).balance.toNumber();
                    updatedTreasuryTokenBalance     = (await mockFa12TokenStorage.ledger.get(treasuryAddress)).balance.toNumber();
    
                    updatedUserPurchaseRecord         = await launchpadStorage.purchaseLedger.get([launchId, user]);
                    const updatedUserTotalPurchased   = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.totalPurchased;
                    const updatedUserTotalDistributed = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.totalDistributed;
                    const updatedUserPurchasedOption  = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.purchased.get(saleOption);
    
                    const updatedDefaultSaleOption  = launchRecord.saleOptions.get(saleOption);
                    const updatedTotalBought        = updatedDefaultSaleOption.totalBought;
    
                    assert.equal(+updatedTotalBought, +initialTotalBought + +amount);
    
                    // check user purchases
                    assert.equal(+updatedUserTotalPurchased, +initialUserTotalPurchased + +amount);
                    assert.equal(+updatedUserTotalDistributed, +initialUserTotalDistributed);
                    assert.equal(+updatedUserPurchasedOption, +initialUserPurchasedOption + +amount);
    
                    // check user balance for payment: mock FA2 token
                    assert.equal(+updatedUserTokenBalance, +initialUserTokenBalance - +totalCost);
    
                    // check treasury balance
                    assert.equal(+updatedTreasuryTokenBalance, +initialTreasuryTokenBalance + +totalCost);
    
                } catch (e) {
                    console.log(e)
                }
            })
    
    
            it('%purchase - whitelisted user (mallory) should be able to purchase tokens (default sale option) from launch and pay in Tez', async () => {
                try {
    
                    user        = mallory.pkh;
                    userSk      = mallory.sk;
                    await signerFactory(tezos, userSk);

                    launchId                   = firstLaunchId;
                    launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                    assert.equal(launchRecord.status , "ACTIVE");
    
                    const amount            = 1000000;
                    const saleOption        = "default";
                    const payment           = "tez";

                    const defaultSaleOption              = launchRecord.saleOptions.get(saleOption);
                    const saleOptionPayments             = defaultSaleOption.payments.get(payment);
                    const priceInMutez                   = saleOptionPayments.price;

                    const totalCostInMutez  = priceInMutez * (amount / 10**6);
    
                    const initialDefaultSaleOption  = launchRecord.saleOptions.get(saleOption);
                    const initialTotalBought        = initialDefaultSaleOption.totalBought;
    
                    initialUserPurchaseRecord         = await launchpadStorage.purchaseLedger.get([launchId, user]);
                    const initialUserTotalPurchased   = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.totalPurchased;
                    const initialUserTotalDistributed = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.totalDistributed;
                    const initialUserPurchasedOption  = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.purchased.get(saleOption);
                    
                    const initialUserTezBalance     = await utils.tezos.tz.getBalance(user);
                    const initialTreasuryTezBalance = await utils.tezos.tz.getBalance(treasuryAddress);
    
                    // purchase operation
                    const purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
                    ).send({ amount: totalCostInMutez, mutez: true});
                    await purchaseOperation.confirmation();
    
                    launchpadStorage        = await launchpadInstance.storage()
                    launchRecord            = await launchpadStorage.launchLedger.get(launchId);
    
                    const updatedDefaultSaleOption  = launchRecord.saleOptions.get(saleOption);
                    const updatedTotalBought        = updatedDefaultSaleOption.totalBought;
    
                    updatedUserPurchaseRecord         = await launchpadStorage.purchaseLedger.get([launchId, user]);
                    const updatedUserTotalPurchased   = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.totalPurchased;
                    const updatedUserTotalDistributed = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.totalDistributed;
                    const updatedUserPurchasedOption  = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.purchased.get(saleOption);
    
                    const updatedUserTezBalance     = await utils.tezos.tz.getBalance(user);
                    const updatedTreasuryTezBalance = await utils.tezos.tz.getBalance(treasuryAddress);
    
                    assert.equal(+updatedTotalBought, +initialTotalBought + +amount);
    
                    // check user purchases
                    assert.equal(+updatedUserTotalPurchased, +initialUserTotalPurchased + +amount);
                    assert.equal(+updatedUserTotalDistributed, +initialUserTotalDistributed);
                    assert.equal(+updatedUserPurchasedOption, +initialUserPurchasedOption + +amount);
    
                    // check user balance for payment: tez
                    assert.equal(almostEqual(+updatedUserTezBalance, +initialUserTezBalance - +totalCostInMutez, 0.01), true);
    
                    // check treasury balance
                    assert.equal(+updatedTreasuryTezBalance, +initialTreasuryTezBalance + +totalCostInMutez);
    
                } catch (e) {
                    console.log(e)
                }
            })
    
    
            it('%purchase - whitelisted user (mallory) should not be able to purchase tokens (default sale option) beyond her allowed limit', async () => {
                try {

                    user        = mallory.pkh;
                    userSk      = mallory.sk;
                    await signerFactory(tezos, userSk);
    
                    const saleOption           = "default";
    
                    launchId                   = firstLaunchId;
                    launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                    assert.equal(launchRecord.status , "ACTIVE");
                    
                    const saleOptionRecord        = launchRecord.saleOptions.get(saleOption);
                    const maxAmountPerWalletTotal = saleOptionRecord.maxAmountPerWalletTotal;
    
                    const amount                = maxAmountPerWalletTotal + 100;
                    const payment               = "fa2Token";
                    
                    // purchase operation
                    const purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
                    );
                    await chai.expect(purchaseOperation.send()).to.be.rejected;
    
                } catch (e) {
                    console.log(e)
                }
            })

            it('%purchase - whitelisted user (mallory) should be able to purchase tokens (whitelist sale option) from launch and pay in FA2 Tokens', async () => {
                try {
    
                    user        = mallory.pkh;
                    userSk      = mallory.sk;
                    await signerFactory(tezos, userSk);

                    launchId                   = firstLaunchId;
                    launchRecord               = await launchpadStorage.launchLedger.get(launchId);
                    assert.equal(launchRecord.status , "ACTIVE");
    
                    launchWhitelistRecord       = await launchpadStorage.launchWhitelistLedger.get([launchId, user]);
                    assert.notEqual(launchWhitelistRecord, undefined);

                    const amount            = 1000000;
                    const saleOption        = "whitelist";
                    const payment           = "fa2Token";
    
                    const initialDefaultSaleOption  = launchRecord.saleOptions.get(saleOption);
                    const initialTotalBought        = initialDefaultSaleOption.totalBought;
                    const saleOptionPayments        = initialDefaultSaleOption.payments.get(payment);
                    const price                     = saleOptionPayments.price;

                    const totalCost                 = price * (amount / 10**6);
                    
                    initialUserPurchaseRecord         = await launchpadStorage.purchaseLedger.get([launchId, user]);
                    const initialUserTotalPurchased   = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.totalPurchased;
                    const initialUserTotalDistributed = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.totalDistributed;
                    const initialUserPurchasedOption  = initialUserPurchaseRecord == undefined ? 0 : initialUserPurchaseRecord.purchased.get(saleOption);
    
                    mockFa2TokenStorage             = await mockFa2TokenInstance.storage();
                    initialUserTokenBalance         = await mockFa2TokenStorage.ledger.get(user);
                    initialTreasuryTokenBalance     = await mockFa2TokenStorage.ledger.get(treasuryAddress);
    
                    // update operators operation
                    updateOperatorsOperation = await updateOperators(mockFa2TokenInstance, user, launchpadAddress, tokenId);
                    await updateOperatorsOperation.confirmation();
    
                    // purchase operation
                    const purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
                    ).send();
                    await purchaseOperation.confirmation();
    
                    launchpadStorage        = await launchpadInstance.storage()
                    mockFa2TokenStorage     = await mockFa2TokenInstance.storage()
    
                    launchRecord                    = await launchpadStorage.launchLedger.get(launchId);
                    updatedUserTokenBalance         = await mockFa2TokenStorage.ledger.get(user);
                    updatedTreasuryTokenBalance     = await mockFa2TokenStorage.ledger.get(treasuryAddress);
    
                    updatedUserPurchaseRecord         = await launchpadStorage.purchaseLedger.get([launchId, user]);
                    const updatedUserTotalPurchased   = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.totalPurchased;
                    const updatedUserTotalDistributed = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.totalDistributed;
                    const updatedUserPurchasedOption  = updatedUserPurchaseRecord == undefined ? 0 : updatedUserPurchaseRecord.purchased.get(saleOption);
    
                    const updatedDefaultSaleOption  = launchRecord.saleOptions.get(saleOption);
                    const updatedTotalBought        = updatedDefaultSaleOption.totalBought;
    
                    assert.equal(+updatedTotalBought, +initialTotalBought + +amount);
    
                    // check user purchases
                    assert.equal(+updatedUserTotalPurchased, +initialUserTotalPurchased + +amount);
                    assert.equal(+updatedUserTotalDistributed, +initialUserTotalDistributed);
                    assert.equal(+updatedUserPurchasedOption, +initialUserPurchasedOption + +amount);
    
                    // check user balance for payment: mock FA2 token
                    assert.equal(+updatedUserTokenBalance, +initialUserTokenBalance - +totalCost);
    
                    // check treasury balance
                    assert.equal(+updatedTreasuryTokenBalance, +initialTreasuryTokenBalance + +totalCost);
    
                } catch (e) {
                    console.log(e)
                }
            })

            it('%purchase - user (mallory) should not be able to purchase tokens beyond the max amount cap (launch record)', async () => {
                try {
    
                    await signerFactory(tezos, adminSk);

                    launchId                        = firstLaunchId;
                    launchRecord                    = await launchpadStorage.launchLedger.get(launchId);
                    assert.equal(launchRecord.status , "ACTIVE");

                    const initialMaxAmountCap = launchRecord.maxAmountCap;
                    const initialTotalBought  = launchRecord.totalBought;

                    const newName                   = null;
                    const newTokenIssuanceType      = null;
                    const newTokenDistributionType  = null;
                    const newTokenContractAddress   = null;
                    const newTokenId                = null;
                    const newMaxAmountCap           = 50000000;
                    const newTotalBought            = 48500000;
                    const newSaleStart              = null;
                    const newSaleEnd                = null;
                    const newWhitelistSaleStart     = null;
                    const newWhitelistSaleEnd       = null;

                    const newSaleOptions                = null
                    const newDefaultWhitelistOptions    = null

                    // edit token launch operation
                    let editTokenLaunchOperation = await launchpadInstance.methods.editTokenLaunch(
                        launchId,
                        newName,
                        newTokenIssuanceType,
                        newTokenDistributionType,
                        newTokenContractAddress,
                        newTokenId,
                        newMaxAmountCap,
                        newTotalBought,
                        newSaleStart,
                        newSaleEnd,
                        newWhitelistSaleStart,
                        newWhitelistSaleEnd,
                        newSaleOptions,
                        newDefaultWhitelistOptions
                    ).send()
                    await editTokenLaunchOperation.confirmation();

                    user    = mallory.pkh
                    userSk  = mallory.sk;
                    await signerFactory(tezos, userSk);
    
                    const amount                    = newMaxAmountCap - newTotalBought + 1;
                    const saleOption                = "default";
                    const payment                   = "fa2Token";
    
                    // update operators operation
                    updateOperatorsOperation = await updateOperators(mockFa2TokenInstance, user, launchpadAddress, tokenId);
                    await updateOperatorsOperation.confirmation();
    
                    // purchase operation
                    const purchaseOperation = await launchpadInstance.methods.purchase(
                        launchId,
                        amount,
                        saleOption,
                        payment
                    );
                    await chai.expect(purchaseOperation.send()).to.be.rejected;

                    
                    // reset max amount cap and total bought
                    await signerFactory(tezos, adminSk);

                    // edit token launch operation
                    editTokenLaunchOperation = await launchpadInstance.methods.editTokenLaunch(
                        launchId,
                        newName,
                        newTokenIssuanceType,
                        newTokenDistributionType,
                        newTokenContractAddress,
                        newTokenId,
                        initialMaxAmountCap,
                        initialTotalBought,
                        newSaleStart,
                        newSaleEnd,
                        newWhitelistSaleStart,
                        newWhitelistSaleEnd,
                        newSaleOptions,
                        newDefaultWhitelistOptions
                    ).send()
                    await editTokenLaunchOperation.confirmation();
    
                } catch (e) {
                    console.log(e)
                }
            })
    
        })

    })


    
})
