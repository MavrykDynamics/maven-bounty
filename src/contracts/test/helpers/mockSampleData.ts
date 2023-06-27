// ------------------------------------------------------------------------------
// Contract Address
// ------------------------------------------------------------------------------

import contractDeployments from './../contractDeployments.json'

import { MichelsonMap } from "@taquito/michelson-encoder";
import { alice, bob, eve, mallory, oscar, ivan, trudy, susie } from "../../scripts/sandbox/accounts";
import { mock } from 'node:test';
export const mvkTokenDecimals = 9

let mockFa12TokenAddress 
let mockFa2TokenAddress 


mockFa12TokenAddress  = contractDeployments.mockFa12Token.address;
mockFa2TokenAddress   = contractDeployments.mockFa2Token.address;

// ------------------------------------------------------------------------------
// Mock Data
// ------------------------------------------------------------------------------

export const mockTokenSalePayment = {

    'default' : {
        'fa2Token' : {
            price           : 2000000,
            currency : {
                "fa2": {
                    tokenContractAddress : mockFa2TokenAddress,
                    tokenId              : 0
                }
            }
        },
        'fa12Token' : {
            price           : 1000000,
            currency : {
                "fa12" : mockFa12TokenAddress
            }
        },
    
        'tez' : {
            price           : 1500000,
            currency : {
                "tez" : null
            }
        }
    },

    'whitelist' : {
        'fa2Token' : {
            price           : 1000000,
            currency : {
                "fa2": {
                    tokenContractAddress : mockFa2TokenAddress,
                    tokenId              : 0
                }
            }
        },

        'fa12Token' : {
            price           : 500000,
            currency : {
                "fa12" : mockFa12TokenAddress
            }
        },

        'tez' : {
            price           : 750000,
            currency : {
                "tez" : null
            }
        }
    }
    
}

export const mockTokenSaleOptions = {

    'default' : {
        maxAmountCap            : 1000000000,
        totalBought             : 0, 
        minPurchaseAmount       : 1000000,
        maxAmountPerWalletTotal : 10000000,
        whitelistOnly           : false,
        payments                : MichelsonMap.fromLiteral({
            'fa2Token'  : mockTokenSalePayment.default.fa2Token,
            'fa12Token' : mockTokenSalePayment.default.fa12Token,
            'tez'       : mockTokenSalePayment.default.tez
        })
        
    },
    
    'whitelist' : {
        maxAmountCap            : 500000000,
        totalBought             : 0, 
        minPurchaseAmount       : 1000000,
        maxAmountPerWalletTotal : 5000000,
        whitelistOnly           : true,
        payments                : MichelsonMap.fromLiteral({
            'fa2Token'  : mockTokenSalePayment.whitelist.fa2Token,
            'fa12Token' : mockTokenSalePayment.whitelist.fa12Token,
            'tez'       : mockTokenSalePayment.whitelist.tez
        })
        
    }

}

