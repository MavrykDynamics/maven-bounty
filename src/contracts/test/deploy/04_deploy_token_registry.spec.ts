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

import { GeneralContract, setGeneralContractLambdas } from '../helpers/deploymentTestHelper'
import { bob } from '../../scripts/sandbox/accounts'
import * as helperFunctions from '../helpers/helperFunctions'

// ------------------------------------------------------------------------------
// Contract Storage
// ------------------------------------------------------------------------------

import { tokenRegistryStorage } from '../../storage/tokenRegistryStorage'

// ------------------------------------------------------------------------------
// Contract Deployment Start
// ------------------------------------------------------------------------------

describe('Token Registry', async () => {
  
    var utils: Utils
    var tokenRegistry
    var tezos

    before('setup', async () => {
        try{

            utils = new Utils()
            await utils.init(bob.sk)
        
            //----------------------------
            // Originate and deploy contracts
            //----------------------------
        
            tokenRegistry = await GeneralContract.originate(utils.tezos, "tokenRegistry", tokenRegistryStorage);
            await saveContractAddress('tokenRegistryAddress', tokenRegistry.contract.address)
        
            /* ---- ---- ---- ---- ---- */
        
            tezos = tokenRegistry.tezos
            await helperFunctions.signerFactory(tezos, bob.sk);

            // Set Lambdas
            await setGeneralContractLambdas(tezos, "tokenRegistry", tokenRegistry.contract)

        } catch(e){
            console.dir(e, {depth: 5})
        }

    })

    it(`token registry contract deployment`, async () => {
        try {
            console.log('-- -- -- -- -- -- -- -- -- -- -- -- --')
        } catch (e) {
            console.log(e)
        }
    })
  
})