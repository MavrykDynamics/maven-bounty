import { MichelsonMap } from "@taquito/michelson-encoder"
import { BigNumber } from "bignumber.js"
import { bob, eve } from '../scripts/sandbox/accounts'
import { launchpadStorageType } from "./storageTypes/launchpadStorageType"

const config = {
    minOfferAmount             : 1, 
}

const metadata = MichelsonMap.fromLiteral({
    '': Buffer.from('tezos-storage:data', 'ascii').toString('hex'),
    data: Buffer.from(
        JSON.stringify({
        name: 'Launchpad Contract',
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

export const launchpadStorage : launchpadStorageType = {
    
    superAdmin                : bob.pkh,
    admins                    : [eve.pkh],
    newSuperAdmin             : null,

    metadata                  : metadata,
    config                    : config,
    breakGlassConfig          : {},

    whitelistContracts        : MichelsonMap.fromLiteral({}),
    generalContracts          : MichelsonMap.fromLiteral({}),

    saleLedger                : MichelsonMap.fromLiteral({}),
    saleWhitelistLedger       : MichelsonMap.fromLiteral({}),
    salePurchaseLedger        : MichelsonMap.fromLiteral({}),
    lastSaleId                : new BigNumber(0),
    
    lambdaLedger              : MichelsonMap.fromLiteral({})
};
