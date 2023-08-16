import { Utils } from "../helpers/Utils"
const saveContractAddress = require("../helpers/saveContractAddress")

const chai = require('chai')
const chaiAsPromised = require('chai-as-promised')
chai.use(chaiAsPromised)
chai.should()

// ------------------------------------------------------------------------------
// Contract Helpers
// ------------------------------------------------------------------------------

import { GeneralContract, setGeneralContractLambdas }  from '../helpers/deploymentTestHelper'
import { bob } from '../../scripts/sandbox/accounts'

// ------------------------------------------------------------------------------
// Contract Storage
// ------------------------------------------------------------------------------

import { bountyStorage } from '../../storage/bountyStorage'
import {
    signerFactory,
} from '../helpers/helperFunctions'


// ------------------------------------------------------------------------------
// Contract Deployment Start
// ------------------------------------------------------------------------------

describe('Bounty', async () => {
    
    var utils: Utils
    var bounty 
    var ledgerKey
    var tezos

    before('setup', async () => {
        try{

            utils = new Utils()
            await utils.init(bob.sk)
        
            //----------------------------
            // Originate and deploy contracts
            //----------------------------
        
            bounty = await GeneralContract.originate(utils.tezos, "bounty", bountyStorage)
            await saveContractAddress('bountyAddress', bounty.contract.address)

            tezos = bounty.tezos
            await signerFactory(tezos, bob.sk)

            // Set Lambdas
            await setGeneralContractLambdas(tezos, "bounty", bounty.contract)
        
        } catch(e){
            console.dir(e, {depth: 5})
        }

    })

    it(`bounty contract deployed`, async () => {
        try {
            console.log('-- -- -- -- -- -- -- -- -- -- -- -- --')
        } catch (e) {
            console.log(e)
        }
    })
  
})