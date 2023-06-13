import { MichelsonMap } from "@taquito/michelson-encoder"
import { cmtaTokenStorageType } from "./storageTypes/cmtaTokenStorageType"
import { eve, oscar } from '../scripts/sandbox/accounts'

const ledgerKey = {
    owner       : eve.pkh,
    token_id    : 0
}

let administrators = new MichelsonMap();
administrators.set(ledgerKey, 1);

export const cmtaTokenStorage: cmtaTokenStorageType = {
    
    administrators          : administrators,

    token_metadata          : MichelsonMap.fromLiteral({}),
    total_supply            : MichelsonMap.fromLiteral({}),

    snapshot_ledger         : MichelsonMap.fromLiteral({}),
    snapshot_lookup         : MichelsonMap.fromLiteral({}),
    snapshot_total_supply   : MichelsonMap.fromLiteral({}),
    token_context           : MichelsonMap.fromLiteral({}),
    identities              : MichelsonMap.fromLiteral({}),

    ledger                  : MichelsonMap.fromLiteral({}),
    operators               : MichelsonMap.fromLiteral({}),
};
