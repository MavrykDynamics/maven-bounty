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
    getStorageMapValue
} from './helpers/helperFunctions'

// ------------------------------------------------------------------------------
// Contract Notes
// ------------------------------------------------------------------------------

// CMTA Tests - use mallory instead of dan

// ------------------------------------------------------------------------------
// Contract Tests
// ------------------------------------------------------------------------------

describe('Test: CMTA Token Contract', async () => {

    // default
    let utils: Utils
    let tezos

    // misc defaults
    let tokenId 
    let tokenAmount
    let operator
    let operatorKey

    // contract instances 
    let cmtaTokenAddress
    let cmtaTokenInstance
    let cmtaTokenStorage

    // user accounts
    let user
    let userSk

    let admin 
    let adminSk 

    let sender
    let receiver 

    // contract map value
    let storageMap
    let contractMapKey
    let initialContractMapValue
    let updatedContractMapValue

    // operations
    let transferOperation
    let updateOperatorsOperation
    let removeOperatorsOperation
    let setAdminOperation
    let resetAdminOperation
    
    before('setup', async () => {
        
        utils = new Utils()
        await utils.init(bob.sk)
        tezos = utils.tezos;

        admin           = eve.pkh 
        adminSk         = eve.sk 

        cmtaTokenAddress            = contractDeployments.cmtaToken.address;
        cmtaTokenInstance           = await utils.tezos.contract.at(cmtaTokenAddress)
        cmtaTokenStorage            = await cmtaTokenInstance.storage()

        console.log('-- -- -- -- -- -- -- -- -- -- -- -- --')

    })

    beforeEach('storage', async () => {
        cmtaTokenStorage            = await cmtaTokenInstance.storage()
    })

    describe('Admin Calls', function () {
        it('Initialise 3 tokens', async () => {
            try {

                await signerFactory(tezos, adminSk);
                const token_metadata_list = [
                    {
                        token_id : 0,
                        token_metadata : new MichelsonMap()
                    },
                    {
                        token_id : 1,
                        token_metadata : new MichelsonMap()
                    },
                    {
                        token_id : 2,
                        token_metadata : new MichelsonMap()
                    }
                ];

                const setTokenMetadataOperation = await cmtaTokenInstance.methods.set_token_metadata(token_metadata_list).send();
                await setTokenMetadataOperation.confirmation();

                const initialiseTokensOperation = await cmtaTokenInstance.methods.initialise_token([0,1,2]).send();
                await initialiseTokensOperation.confirmation();

            } catch (e) {
                console.log(e)
            }
        })
    })

    describe('Owner Only Calls', function () {
        it('Transferring the Ownership to the individual owners', async () => {
            try {

                const ownerships = [
                    {
                        token_id : 0,
                        owner : alice.pkh
                    },
                    {
                        token_id : 1,
                        proposed_administrator : bob.pkh
                    },
                    {
                        token_id : 2,
                        owner : mallory.pkh
                    },
                ];

            } catch (e) {
                console.log(e)
            }
        })

        it('Not admin trying to propose new owner', async () => {
            try {

                await signerFactory(tezos, alice.sk);
                const proposeAdministratorOperation = await cmtaTokenInstance.methods.propose_administrator(0, alice.pkh);
                chai.expect(proposeAdministratorOperation.send()).to.be.rejected;
                
            } catch (e) {
                console.log(e)
            }
        })

        it('Not admin trying to transfer directly', async () => {
            try {

                await signerFactory(tezos, bob.sk);
                const setAdministratorOperation = await cmtaTokenInstance.methods.set_administrator(0);
                chai.expect(setAdministratorOperation.send()).to.be.rejected;
                
            } catch (e) {
                console.log(e)
            }
        })

        it('Correct admin trying to transfer directly', async () => {
            try {

                await signerFactory(tezos, adminSk);
                const setAdministratorOperation = await cmtaTokenInstance.methods.set_administrator(0);
                chai.expect(setAdministratorOperation.send()).to.be.rejected;
                
            } catch (e) {
                console.log(e)
            }
        })

        it('Correct admin trying to propose transfer', async () => {
            try {

                await signerFactory(tezos, adminSk);
                let proposeAdministratorOperation = await cmtaTokenInstance.methods.propose_administrator(0, alice.pkh).send();
                await proposeAdministratorOperation.confirmation();

                proposeAdministratorOperation = await cmtaTokenInstance.methods.propose_administrator(1, bob.pkh).send();
                await proposeAdministratorOperation.confirmation();

                proposeAdministratorOperation = await cmtaTokenInstance.methods.propose_administrator(2, mallory.pkh).send();
                await proposeAdministratorOperation.confirmation();
                
                
            } catch (e) {
                console.log(e)
            }
        })

        it('Correct admin (but not proposed) trying to transfer', async () => {
            try {

                await signerFactory(tezos, adminSk);
                const setAdministratorOperation = await cmtaTokenInstance.methods.set_administrator(0);
                chai.expect(setAdministratorOperation.send()).to.be.rejected;
                
            } catch (e) {
                console.log(e)
            }
        })

        it('Proposed admin trying to transfer', async () => {
            try {

                await signerFactory(tezos, alice.sk);
                let setAdministratorOperation = await cmtaTokenInstance.methods.set_administrator(0).send();
                await setAdministratorOperation.confirmation();

                await signerFactory(tezos, bob.sk);
                setAdministratorOperation = await cmtaTokenInstance.methods.set_administrator(1).send();
                await setAdministratorOperation.confirmation();

                await signerFactory(tezos, mallory.sk);
                setAdministratorOperation = await cmtaTokenInstance.methods.set_administrator(2).send();
                await setAdministratorOperation.confirmation();
                
            } catch (e) {
                console.log(e)
            }
        })

        it('Non Admin deletes rights', async () => {
            try {

                await signerFactory(tezos, mallory.sk);
                let removeAdministratorOperation = await cmtaTokenInstance.methods.remove_administrator(0, admin);
                chai.expect(removeAdministratorOperation.send()).to.be.rejected;

                await signerFactory(tezos, alice.sk);
                removeAdministratorOperation = await cmtaTokenInstance.methods.remove_administrator(1, admin);
                chai.expect(removeAdministratorOperation.send()).to.be.rejected;

                await signerFactory(tezos, bob.sk);
                removeAdministratorOperation = await cmtaTokenInstance.methods.remove_administrator(2, admin);
                chai.expect(removeAdministratorOperation.send()).to.be.rejected;
                
            } catch (e) {
                console.log(e)
            }
        })

        it('Admin deletes own rights', async () => {
            try {

                await signerFactory(tezos, alice.sk);
                let removeAdministratorOperation = await cmtaTokenInstance.methods.remove_administrator(0, admin).send();
                await removeAdministratorOperation.confirmation();

                await signerFactory(tezos, bob.sk);
                removeAdministratorOperation = await cmtaTokenInstance.methods.remove_administrator(1, admin).send();
                await removeAdministratorOperation.confirmation();

                await signerFactory(tezos, mallory.sk);
                removeAdministratorOperation = await cmtaTokenInstance.methods.remove_administrator(2, admin).send();
                await removeAdministratorOperation.confirmation();
                
            } catch (e) {
                console.log(e)
            }
        })
    })

    describe('Issuing', function () {

        it('Correct admin but not owner trying to mint', async () => {
            try {

                await signerFactory(tezos, adminSk);
                const mintOperation = await cmtaTokenInstance.methods.mint([
                    {
                        token_id : 0,
                        amount : 100,
                        address : admin 
                    }
                ]);
                chai.expect(mintOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

        it('Incorrect owner trying to mint (Alice is owner of 0 not 1', async () => {
            try {

                await signerFactory(tezos, alice.sk);
                const mintOperation = await cmtaTokenInstance.methods.mint([
                    {
                        token_id : 1,
                        amount : 100,
                        address : alice.pkh 
                    }
                ]);
                chai.expect(mintOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

        it('Correct owner trying to batch mint (Alice is owner of 0 not 1 and 2)', async () => {
            try {

                await signerFactory(tezos, alice.sk);
                const mintOperation = await cmtaTokenInstance.methods.mint([
                    {
                        token_id : 0,
                        amount : 100,
                        address : alice.pkh 
                    },
                    {
                        token_id : 1,
                        amount : 100,
                        address : alice.pkh 
                    },
                    {
                        token_id : 2,
                        amount : 100,
                        address : alice.pkh 
                    }
                ]);
                chai.expect(mintOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

        it('Correct owners issuing tokens', async () => {
            try {

                await signerFactory(tezos, alice.sk);
                let mintOperation = await cmtaTokenInstance.methods.mint([
                    {
                        token_id : 0,
                        amount : 100,
                        address : alice.pkh 
                    }
                ]).send();
                await mintOperation.confirmation();


                await signerFactory(tezos, bob.sk);
                mintOperation = await cmtaTokenInstance.methods.mint([
                    {
                        token_id : 1,
                        amount : 100,
                        address : bob.pkh 
                    }
                ]).send();
                await mintOperation.confirmation();


                await signerFactory(tezos, mallory.sk);
                mintOperation = await cmtaTokenInstance.methods.mint([
                    {
                        token_id : 2,
                        amount : 100,
                        address : mallory.pkh 
                    }
                ]).send();
                await mintOperation.confirmation();

            } catch (e) {
                console.log(e)
            }
        })

        it('Correct owners issuing additional amounts of tokens', async () => {
            try {

                await signerFactory(tezos, alice.sk);
                let mintOperation = await cmtaTokenInstance.methods.mint([
                    {
                        token_id : 0,
                        amount : 101,
                        address : alice.pkh 
                    }
                ]).send();
                await mintOperation.confirmation();


                await signerFactory(tezos, bob.sk);
                mintOperation = await cmtaTokenInstance.methods.mint([
                    {
                        token_id : 1,
                        amount : 101,
                        address : bob.pkh 
                    }
                ]).send();
                await mintOperation.confirmation();

                
                await signerFactory(tezos, mallory.sk);
                mintOperation = await cmtaTokenInstance.methods.mint([
                    {
                        token_id : 2,
                        amount : 101,
                        address : mallory.pkh 
                    }
                ]).send();
                await mintOperation.confirmation();

                // update storage
                cmtaTokenStorage = await cmtaTokenInstance.storage();

                var ledgerKey = {
                    owner : alice.pkh,
                    token_id : 0
                };
                const aliceToken0Balance    = await cmtaTokenStorage.ledger.get(ledgerKey);

                ledgerKey.owner     = bob.pkh;
                ledgerKey.token_id  = 1;
                const bobToken1Balance      = await cmtaTokenStorage.ledger.get(ledgerKey);

                ledgerKey.owner     = mallory.pkh;
                ledgerKey.token_id  = 2;
                const malloryToken2Balance  = await cmtaTokenStorage.ledger.get(ledgerKey);

                assert.equal(aliceToken0Balance     , 201);
                assert.equal(bobToken1Balance       , 201);
                assert.equal(malloryToken2Balance   , 201);

            } catch (e) {
                console.log(e)
            }
        })
    })

    describe('Redemption', function () {
        
        it('Correct admin but not owner trying to burn', async () => {
            try {

                await signerFactory(tezos, adminSk);
                const burnOperation = await cmtaTokenInstance.methods.burn([
                    {
                        token_id : 0,
                        amount : 100,
                        address : admin 
                    }
                ]);
                chai.expect(burnOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

        it('Incorrect owner trying to burn (Alice is owner of 0 not 1)', async () => {
            try {

                await signerFactory(tezos, alice.sk);
                const burnOperation = await cmtaTokenInstance.methods.burn([
                    {
                        token_id : 1,
                        amount : 100,
                        address : alice.pkh 
                    }
                ]);
                chai.expect(burnOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

        it('Correct owner trying to batch burn (Alice is owner of 0 not 1 and 2)', async () => {
            try {

                await signerFactory(tezos, alice.sk);
                const burnOperation = await cmtaTokenInstance.methods.burn([
                    {
                        token_id : 0,
                        amount : 100,
                        address : alice.pkh 
                    },
                    {
                        token_id : 1,
                        amount : 100,
                        address : alice.pkh 
                    },
                    {
                        token_id : 2,
                        amount : 100,
                        address : alice.pkh 
                    }
                ]);
                chai.expect(burnOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

        it('Correct owners burning tokens', async () => {
            try {

                await signerFactory(tezos, alice.sk);
                let burnOperation = await cmtaTokenInstance.methods.burn([
                    {
                        token_id : 0,
                        amount : 100,
                        address : alice.pkh 
                    }
                ]).send();
                await burnOperation.confirmation();


                await signerFactory(tezos, bob.sk);
                burnOperation = await cmtaTokenInstance.methods.burn([
                    {
                        token_id : 1,
                        amount : 100,
                        address : bob.pkh 
                    }
                ]).send();
                await burnOperation.confirmation();


                await signerFactory(tezos, mallory.sk);
                burnOperation = await cmtaTokenInstance.methods.burn([
                    {
                        token_id : 2,
                        amount : 100,
                        address : mallory.pkh 
                    }
                ]).send();
                await burnOperation.confirmation();

                // update storage
                cmtaTokenStorage = await cmtaTokenInstance.storage();

                var ledgerKey = {
                    owner : alice.pkh,
                    token_id : 0
                };
                const aliceToken0Balance    = await cmtaTokenStorage.ledger.get(ledgerKey);

                ledgerKey.owner     = bob.pkh;
                ledgerKey.token_id  = 1;
                const bobToken1Balance      = await cmtaTokenStorage.ledger.get(ledgerKey);

                ledgerKey.owner     = mallory.pkh;
                ledgerKey.token_id  = 2;
                const malloryToken2Balance  = await cmtaTokenStorage.ledger.get(ledgerKey);

                assert.equal(aliceToken0Balance     , 101);
                assert.equal(bobToken1Balance       , 101);
                assert.equal(malloryToken2Balance   , 101);

            } catch (e) {
                console.log(e)
            }
        })


        it('Cannot burn more than owner has', async () => {
            try {

                await signerFactory(tezos, alice.sk);
                let burnOperation = await cmtaTokenInstance.methods.burn([
                    {
                        token_id : 0,
                        amount : 201,
                        address : alice.pkh 
                    }
                ]);
                chai.expect(burnOperation.send()).to.be.rejected;


                await signerFactory(tezos, bob.sk);
                burnOperation = await cmtaTokenInstance.methods.burn([
                    {
                        token_id : 1,
                        amount : 201,
                        address : bob.pkh 
                    }
                ]);
                chai.expect(burnOperation.send()).to.be.rejected;


                await signerFactory(tezos, mallory.sk);
                burnOperation = await cmtaTokenInstance.methods.burn([
                    {
                        token_id : 2,
                        amount : 201,
                        address : mallory.pkh 
                    }
                ]);
                chai.expect(burnOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })


        it('Correct owners burning additional amounts of tokens', async () => {
            try {

                await signerFactory(tezos, alice.sk);
                let burnOperation = await cmtaTokenInstance.methods.burn([
                    {
                        token_id : 0,
                        amount : 101,
                        address : alice.pkh 
                    }
                ]).send();
                await burnOperation.confirmation();


                await signerFactory(tezos, bob.sk);
                burnOperation = await cmtaTokenInstance.methods.burn([
                    {
                        token_id : 1,
                        amount : 101,
                        address : bob.pkh 
                    }
                ]).send();
                await burnOperation.confirmation();


                await signerFactory(tezos, mallory.sk);
                burnOperation = await cmtaTokenInstance.methods.burn([
                    {
                        token_id : 2,
                        amount : 101,
                        address : mallory.pkh 
                    }
                ]).send();
                await burnOperation.confirmation();

                // update storage
                cmtaTokenStorage = await cmtaTokenInstance.storage();

                var ledgerKey = {
                    owner : alice.pkh,
                    token_id : 0
                };
                const aliceToken0Balance    = await cmtaTokenStorage.ledger.get(ledgerKey);

                ledgerKey.owner     = bob.pkh;
                ledgerKey.token_id  = 1;
                const bobToken1Balance      = await cmtaTokenStorage.ledger.get(ledgerKey);

                ledgerKey.owner     = mallory.pkh;
                ledgerKey.token_id  = 2;
                const malloryToken2Balance  = await cmtaTokenStorage.ledger.get(ledgerKey);

                assert.equal(aliceToken0Balance     , undefined);
                assert.equal(bobToken1Balance       , undefined);
                assert.equal(malloryToken2Balance   , undefined);

            } catch (e) {
                console.log(e)
            }
        })
    })

    describe('Reassign', function () {

        it('Bootstrapping by issuing some tokens', async () => {
            try {

                await signerFactory(tezos, alice.sk);
                let mintOperation = await cmtaTokenInstance.methods.mint([
                    {
                        token_id : 0,
                        amount : 50,
                        address : alice.pkh 
                    }
                ]).send();
                await mintOperation.confirmation();


                await signerFactory(tezos, bob.sk);
                mintOperation = await cmtaTokenInstance.methods.mint([
                    {
                        token_id : 1,
                        amount : 47,
                        address : alice.pkh 
                    }
                ]).send();
                await mintOperation.confirmation();


                await signerFactory(tezos, mallory.sk);
                mintOperation = await cmtaTokenInstance.methods.mint([
                    {
                        token_id : 2,
                        amount : 39,
                        address : alice.pkh 
                    }
                ]).send();
                await mintOperation.confirmation();

                var ledgerKey = {
                    owner : alice.pkh,
                    token_id : 0
                };
                const aliceToken0Balance    = await cmtaTokenStorage.ledger.get(ledgerKey);

                ledgerKey.token_id  = 1;
                const aliceToken1Balance      = await cmtaTokenStorage.ledger.get(ledgerKey);

                ledgerKey.token_id  = 2;
                const aliceToken2Balance  = await cmtaTokenStorage.ledger.get(ledgerKey);

                assert.equal(aliceToken0Balance     , 50);
                assert.equal(aliceToken1Balance     , 47);
                assert.equal(aliceToken2Balance     , 39);

            } catch (e) {
                console.log(e)
            }
        })

        it('Can now only burn if token on owner address', async () => {
            try {

                await signerFactory(tezos, bob.sk);
                let burnOperation = await cmtaTokenInstance.methods.burn([
                    {
                        token_id : 1,
                        amount : 1,
                        address : bob.pkh 
                    }
                ]);
                chai.expect(burnOperation.send()).to.be.rejected;


                await signerFactory(tezos, mallory.sk);
                burnOperation = await cmtaTokenInstance.methods.burn([
                    {
                        token_id : 2,
                        amount : 1,
                        address : mallory.pkh 
                    }
                ]);
                chai.expect(burnOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

    })

    describe('Pause', function () {

        it('Correct admin but not owner trying to pause', async () => {
            try {

                await signerFactory(tezos, adminSk);
                const pauseOperation = await cmtaTokenInstance.methods.pause([0]);
                await chai.expect(pauseOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

        it('Incorrect owner trying to pause (Alice is owner of 0 not 1)', async () => {
            try {

                await signerFactory(tezos, alice.sk);
                const pauseOperation = await cmtaTokenInstance.methods.pause([1]);
                await chai.expect(pauseOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

        it('Correct owner trying to batch pause (Alice is owner of 0 not 1 and 2)', async () => {
            try {

                await signerFactory(tezos, alice.sk);
                const pauseOperation = await cmtaTokenInstance.methods.pause([0,1,2]);
                await chai.expect(pauseOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

        it('Correct owners pauseing tokens', async () => {
            try {

                await signerFactory(tezos, bob.sk);
                let pauseOperation = await cmtaTokenInstance.methods.pause([1]).send();
                await pauseOperation.confirmation();

                await signerFactory(tezos, mallory.sk);
                pauseOperation = await cmtaTokenInstance.methods.pause([2]).send();
                await pauseOperation.confirmation();

            } catch (e) {
                console.log(e)
            }
        })
    })

    describe('Unpause', function () {

        it('Correct admin but not owner trying to unpause', async () => {
            try {

                await signerFactory(tezos, adminSk);
                const unpauseOperation = await cmtaTokenInstance.methods.unpause([0]);
                await chai.expect(unpauseOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

        it('Incorrect owner trying to unpause (Alice is owner of 0 not 1)', async () => {
            try {

                await signerFactory(tezos, alice.sk);
                const unpauseOperation = await cmtaTokenInstance.methods.unpause([1]);
                await chai.expect(unpauseOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

        it('Correct owner trying to batch unpause (Alice is owner of 0 not 1 and 2)', async () => {
            try {

                await signerFactory(tezos, adminSk);
                const unpauseOperation = await cmtaTokenInstance.methods.unpause([0,1,2]);
                await chai.expect(unpauseOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

        it('Correct owners unpauseing tokens', async () => {
            try {

                await signerFactory(tezos, bob.sk);
                let unpauseOperation = await cmtaTokenInstance.methods.unpause([1]).send();
                await unpauseOperation.confirmation();


                await signerFactory(tezos, mallory.sk);
                unpauseOperation = await cmtaTokenInstance.methods.unpause([2]).send();
                await unpauseOperation.confirmation();

            } catch (e) {
                console.log(e)
            }
        })
    })

    describe('Token Holder Calls', function () {

        describe('Transfer', function () {

            it('Holder with no balance tries transfer', async () => {
                try {

                    await signerFactory(tezos, bob.sk);
                    const transferOperation = await cmtaTokenInstance.methods.transfer([
                        {
                            from_ : bob.pkh,
                            txs: [
                                {
                                    to_: mallory.pkh,
                                    token_id: 0,
                                    amount: 1,
                                },
                            ]
                        }
                    ]);
                    await chai.expect(transferOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it('Admin with no balance tries transfer', async () => {
                try {

                    await signerFactory(tezos, adminSk);
                    const transferOperation = await cmtaTokenInstance.methods.transfer([
                        {
                            from_ : admin,
                            txs: [
                                {
                                    to_: mallory.pkh,
                                    token_id: 0,
                                    amount: 1,
                                },
                            ]
                        }
                    ]);
                    await chai.expect(transferOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it('Admin tries transfer of third parties balance', async () => {
                try {

                    await signerFactory(tezos, adminSk);
                    const transferOperation = await cmtaTokenInstance.methods.transfer([
                        {
                            from_ : alice.pkh,
                            txs: [
                                {
                                    to_: mallory.pkh,
                                    token_id: 0,
                                    amount: 1,
                                },
                            ]
                        }
                    ]);
                    await chai.expect(transferOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

        })
    })

})
