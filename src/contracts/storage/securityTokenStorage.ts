import { MichelsonMap } from "@taquito/michelson-encoder"
import { BigNumber } from "bignumber.js"
import { securityTokenStorageType } from "./storageTypes/securityTokenStorageType"
import { bob, eve, alice, mallory, oscar } from '../scripts/sandbox/accounts'

let ledgerKey = {
    owner       : eve.pkh,
    token_id    : 0
}

let administrators = new MichelsonMap();
administrators.set(ledgerKey, 1);

export const securityTokenStorage : securityTokenStorageType = {
    
    superAdmin              : bob.pkh,
    administrators          : administrators,
    newSuperAdmin           : null,

    whitelistContracts      : MichelsonMap.fromLiteral({}),
    token_metadata          : MichelsonMap.fromLiteral({}),
    totalSupply             : MichelsonMap.fromLiteral({}),

    snapshotLedger          : MichelsonMap.fromLiteral({}),
    snapshotLookup          : MichelsonMap.fromLiteral({}),
    snapshotTotalSupply     : MichelsonMap.fromLiteral({}),
    tokenContext            : MichelsonMap.fromLiteral({}),
    identities              : MichelsonMap.fromLiteral({}),

    ledger                  : MichelsonMap.fromLiteral({}),
    operators               : MichelsonMap.fromLiteral({}),
};
