import { Utils } from "../helpers/Utils"
const saveContractAddress = require("../helpers/saveContractAddress")

const chai = require('chai')
const chaiAsPromised = require('chai-as-promised')
chai.use(chaiAsPromised)
chai.should()

// ------------------------------------------------------------------------------
// Contract Address
// ------------------------------------------------------------------------------

import contractDeployments from '../contractDeployments.json'

// ------------------------------------------------------------------------------
// Contract Helpers
// ------------------------------------------------------------------------------

import { GeneralContract }  from '../helpers/deploymentTestHelper'
import { bob } from '../../scripts/sandbox/accounts'

// ------------------------------------------------------------------------------
// Contract Storage
// ------------------------------------------------------------------------------

import { securityTokenStorage } from '../../storage/securityTokenStorage'

// ------------------------------------------------------------------------------
// Contract Deployment Start
// ------------------------------------------------------------------------------

describe('Security Token', async () => {
    
    var utils: Utils
    var securityToken 

    before('setup', async () => {
        try{

            utils = new Utils()
            await utils.init(bob.sk)
        
            //----------------------------
            // Originate and deploy contracts
            //----------------------------

            securityToken = await GeneralContract.originate(utils.tezos, "securityToken", securityTokenStorage);
            await saveContractAddress('securityTokenAddress', securityToken.contract.address)
        
        } catch(e){
            console.dir(e, {depth: 5})
        }

    })

    it(`security token contract deployed`, async () => {
        try {
            console.log('-- -- -- -- -- -- -- -- -- -- -- -- --')
        } catch (e) {
            console.log(e)
        }
    })
  
})