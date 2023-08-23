import { MichelsonMap } from "@taquito/michelson-encoder"
import { BigNumber } from "bignumber.js"
import { bob, eve } from '../scripts/sandbox/accounts'
import { bountyStorageType } from "./storageTypes/bountyStorageType"

const config = {
    maxActiveBounties          : 5, 
    maxApplications            : 20,
    
    maxMembersPerGroup         : 5,
    maxGroupsCreatedPerUser    : 5,
    maxGroupsPerUser           : 5
}


const metadata = MichelsonMap.fromLiteral({
    '': Buffer.from('tezos-storage:data', 'ascii').toString('hex'),
    data: Buffer.from(
        JSON.stringify({
        name: 'Bounty Contract',
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

export const bountyStorage : bountyStorageType = {
    
    superAdmin                : bob.pkh,
    admins                    : [eve.pkh],
    newSuperAdmin             : null,

    metadata                  : metadata,
    config                    : config,
    
    bountyCreators            : MichelsonMap.fromLiteral({}),
    bountyLedger              : MichelsonMap.fromLiteral({}),
    applicationLedger         : MichelsonMap.fromLiteral({}),
    groupLedger               : MichelsonMap.fromLiteral({}),
    userLedger                : MichelsonMap.fromLiteral({}),

    nextBountyId              : new BigNumber(0),
    nextGroupId               : new BigNumber(0),

    lambdaLedger              : MichelsonMap.fromLiteral({})

};
