import { MichelsonMap } from "@taquito/michelson-encoder"
import { BigNumber } from "bignumber.js"
import { bob } from '../scripts/sandbox/accounts'
import { MVK } from "../test/helpers/Utils"
import { tokenRegistryStorageType } from "./storageTypes/tokenRegistryStorageType"

const metadata = MichelsonMap.fromLiteral({
    '': Buffer.from('tezos-storage:data', 'ascii').toString('hex'),
    data: Buffer.from(
        JSON.stringify({
        name: 'Token Registry Contract',
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

export const tokenRegistryStorage : tokenRegistryStorageType = {
    
    superAdmin                : bob.pkh,
    admins                    : [],
    newSuperAdmin             : "",

    metadata                  : metadata,
    breakGlassConfig          : {},

    whitelistContracts        : MichelsonMap.fromLiteral({}),
    generalContracts          : MichelsonMap.fromLiteral({}),

    defaultFee                : new BigNumber(100),
    defaultBeneficiary        : bob.pkh,

    tokenLedger               : MichelsonMap.fromLiteral({}),
    
    lambdaLedger              : MichelsonMap.fromLiteral({})
    
};
