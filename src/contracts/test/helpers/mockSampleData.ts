// ------------------------------------------------------------------------------
// Contract Address
// ------------------------------------------------------------------------------

import contractDeployments from './../contractDeployments.json'

import { MichelsonMap } from "@taquito/michelson-encoder";
import { alice, bob, eve, mallory, oscar, ivan, trudy, susie } from "../../scripts/sandbox/accounts";
export const mvkTokenDecimals = 9

let mockFa12TokenAddress 
let mockFa2TokenAddress 


mockFa12TokenAddress            = contractDeployments.mockFa12Token.address;
mockFa2TokenAddress             = contractDeployments.mockFa2Token.address;

// ------------------------------------------------------------------------------
// Mock Data
// ------------------------------------------------------------------------------

export const mockTokenSaleOptions = {

    'default' : {
        maxAmountCap            : 1000000000,
        totalBought             : 0, 
        minPurchaseAmount       : 1000000,
        maxAmountPerWalletTotal : 10000000,
        price                   : 1000000,
        currency : {
            "fa2": {
                tokenContractAddress : mockFa2TokenAddress,
                tokenId              : 0
            }
        }
    },
    'defaultWithFa12' : {
        maxAmountCap            : 1000000000,
        totalBought             : 0, 
        minPurchaseAmount       : 1000000,
        maxAmountPerWalletTotal : 10000000,
        price                   : 1000000,
        currency : {
            "fa12": mockFa12TokenAddress
        }
    },
    'whitelist' : {
        maxAmountCap            : 500000000,
        totalBought             : 0, 
        minPurchaseAmount       : 1000000,
        maxAmountPerWalletTotal : 5000000,
        price                   : 1000000,
        currency : {
            "fa2": {
                tokenContractAddress : mockFa2TokenAddress,
                tokenId              : 0
            }
        }
    }

}

