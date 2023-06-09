import { MichelsonMap } from "@taquito/michelson-encoder"
import { UnitValue } from "@taquito/taquito"
import { Utils } from "../helpers/Utils"
const saveContractAddress = require("../helpers/saveContractAddress")

const chai = require('chai')
const chaiAsPromised = require('chai-as-promised')
chai.use(chaiAsPromised)
chai.should()

// ------------------------------------------------------------------------------
// Contract Helpers
// ------------------------------------------------------------------------------

import { GeneralContract }  from '../helpers/deploymentTestHelper'
import { bob, alice } from '../../scripts/sandbox/accounts'

// ------------------------------------------------------------------------------
// Contract Storage
// ------------------------------------------------------------------------------

import { freezeRuleEngineStorage } from '../../storage/freezeRuleEngineStorage'

// ------------------------------------------------------------------------------
// Contract Deployment Start
// ------------------------------------------------------------------------------

describe('Freeze Rule Engine', async () => {
    
    var utils: Utils
    var freezeRuleEngine 
    var ledgerKey

    before('setup', async () => {
        try{

            utils = new Utils()
            await utils.init(bob.sk)
        
            //----------------------------
            // Originate and deploy contracts
            //----------------------------
        
            let frozen_accounts = new MichelsonMap();
            frozen_accounts.set(alice.pkh, UnitValue);
            frozen_accounts.set(bob.pkh, UnitValue);
            freezeRuleEngineStorage.frozen_accounts = frozen_accounts

            freezeRuleEngine = await GeneralContract.originate(utils.tezos, "freezeRuleEngine", freezeRuleEngineStorage);
            await saveContractAddress('freezeRuleEngineAddress', freezeRuleEngine.contract.address)
        
        } catch(e){
            console.dir(e, {depth: 5})
        }

    })

    it(`freeze rule engine contract deployed`, async () => {
        try {
            console.log('-- -- -- -- -- -- -- -- -- -- -- -- --')
        } catch (e) {
            console.log(e)
        }
    })
  
})