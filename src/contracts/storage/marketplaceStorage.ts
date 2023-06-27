import { MichelsonMap } from "@taquito/michelson-encoder"
import { BigNumber } from "bignumber.js"
import { bob, eve } from '../scripts/sandbox/accounts'
import { marketplaceStorageType } from "./storageTypes/marketplaceStorageType"

const config = {
    minOfferAmount             : 1, 
    standardUnit               : 100000,
    royalty                    : 100,
    marketplaceFee             : 100
}


const metadata = MichelsonMap.fromLiteral({
    '': Buffer.from('tezos-storage:data', 'ascii').toString('hex'),
    data: Buffer.from(
        JSON.stringify({
        name: 'Marketplace Contract',
        version: 'v1.0.0',
        authors: ['MAVRYK Dev Team <contact@mavryk.finance>'],
        source: {
            tools: ['Ligo', 'Flextesa'],
            location: 'https://ligolang.org/',
        },
        }),
        'ascii',
    ).toString('hex'),
})

export const marketplaceStorage: marketplaceStorageType = {
    
    superAdmin                : bob.pkh,
    admins                    : [eve.pkh],
    newSuperAdmin             : null,

    metadata                  : metadata,
    config                    : config,
    breakGlassConfig          : {},

    whitelistContracts        : MichelsonMap.fromLiteral({}),
    generalContracts          : MichelsonMap.fromLiteral({}),
    
    nextListingId             : new BigNumber(0),
    nextOfferId               : new BigNumber(0),
    
    listingLedger             : MichelsonMap.fromLiteral({}),
    offerLedger               : MichelsonMap.fromLiteral({}),
    currencyLedger            : MichelsonMap.fromLiteral({}),

    lambdaLedger              : MichelsonMap.fromLiteral({})

};
