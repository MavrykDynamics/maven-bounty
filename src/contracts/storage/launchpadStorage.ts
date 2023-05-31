import { MichelsonMap } from "@taquito/michelson-encoder"
import { BigNumber } from "bignumber.js"
import { bob } from '../scripts/sandbox/accounts'
import { MVK } from "../test/helpers/Utils"
import { launchpadStorageType } from "./storageTypes/launchpadStorageType"

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
    admins                    : [],
    newSuperAdmin             : "",

    metadata                  : metadata,
    config                    : {},

    whitelistContracts        : MichelsonMap.fromLiteral({}),
    generalContracts          : MichelsonMap.fromLiteral({}),
    
    lambdaLedger              : MichelsonMap.fromLiteral({})
};
