import { MichelsonMap, MichelsonMapKey } from "@taquito/michelson-encoder"
import { BigNumber } from "bignumber.js"

export type launchpadStorageType = {
    
    superAdmin              : string;
    admins                  : [];
    newSuperAdmin           : string;
    
    metadata                : MichelsonMap<MichelsonMapKey, unknown>;
    config                  : {};

    whitelistContracts      : MichelsonMap<MichelsonMapKey, unknown>;
    generalContracts        : MichelsonMap<MichelsonMapKey, unknown>;
    
    lambdaLedger            : MichelsonMap<MichelsonMapKey, unknown>;

};
