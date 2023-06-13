import { MichelsonMap, MichelsonMapKey } from "@taquito/michelson-encoder"
import { BigNumber } from "bignumber.js"

export type cmtaTokenStorageType = {

    administrators          : MichelsonMap<MichelsonMapKey, unknown>;
    
    token_metadata          : MichelsonMap<MichelsonMapKey, unknown>;
    total_supply            : MichelsonMap<MichelsonMapKey, unknown>;

    snapshot_ledger         : MichelsonMap<MichelsonMapKey, unknown>;
    snapshot_lookup         : MichelsonMap<MichelsonMapKey, unknown>;
    snapshot_total_supply   : MichelsonMap<MichelsonMapKey, unknown>;
    token_context           : MichelsonMap<MichelsonMapKey, unknown>;
    identities              : MichelsonMap<MichelsonMapKey, unknown>;

    ledger                  : MichelsonMap<MichelsonMapKey, unknown>;
    operators               : MichelsonMap<MichelsonMapKey, unknown>;

};
