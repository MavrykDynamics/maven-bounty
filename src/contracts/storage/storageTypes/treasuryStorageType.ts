import { MichelsonMap, MichelsonMapKey } from "@taquito/michelson-encoder"
import { BigNumber } from "bignumber.js"

export type treasuryStorageType = {
    
    superAdmin              : string;
    admins                  : [string];
    newSuperAdmin           : string | null;
    
    metadata                : MichelsonMap<MichelsonMapKey, unknown>;

    whitelistContracts      : MichelsonMap<MichelsonMapKey, unknown>;
    generalContracts        : MichelsonMap<MichelsonMapKey, unknown>;
    whitelistTokenContracts : MichelsonMap<MichelsonMapKey, unknown>;
    
    lambdaLedger            : MichelsonMap<MichelsonMapKey, unknown>;

};
