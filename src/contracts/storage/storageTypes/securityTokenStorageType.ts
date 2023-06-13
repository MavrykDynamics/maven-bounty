import { MichelsonMap, MichelsonMapKey } from "@taquito/michelson-encoder"
import { BigNumber } from "bignumber.js"

export type securityTokenStorageType = {

    superAdmin              : string;
    administrators          : MichelsonMap<MichelsonMapKey, unknown>;
    newSuperAdmin           : string | null;
    
    whitelistContracts      : MichelsonMap<MichelsonMapKey, unknown>;
    token_metadata          : MichelsonMap<MichelsonMapKey, unknown>;
    totalSupply             : MichelsonMap<MichelsonMapKey, unknown>;

    snapshotLedger          : MichelsonMap<MichelsonMapKey, unknown>;
    snapshotLookup          : MichelsonMap<MichelsonMapKey, unknown>;
    snapshotTotalSupply     : MichelsonMap<MichelsonMapKey, unknown>;
    tokenContext            : MichelsonMap<MichelsonMapKey, unknown>;
    identities              : MichelsonMap<MichelsonMapKey, unknown>;

    ledger                  : MichelsonMap<MichelsonMapKey, unknown>;
    operators               : MichelsonMap<MichelsonMapKey, unknown>;
};
