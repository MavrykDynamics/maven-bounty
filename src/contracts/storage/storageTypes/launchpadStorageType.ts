import { MichelsonMap, MichelsonMapKey } from "@taquito/michelson-encoder"
import { BigNumber } from "bignumber.js"

export type launchpadStorageType = {
    
    superAdmin              : string;
    admins                  : [string];
    newSuperAdmin           : string | null;
    
    metadata                : MichelsonMap<MichelsonMapKey, unknown>;
    config                  : {};
    breakGlassConfig        : {};

    whitelistContracts      : MichelsonMap<MichelsonMapKey, unknown>;
    generalContracts        : MichelsonMap<MichelsonMapKey, unknown>;

    launchLedger            : MichelsonMap<MichelsonMapKey, unknown>;
    launchWhitelistLedger   : MichelsonMap<MichelsonMapKey, unknown>;
    purchaseLedger          : MichelsonMap<MichelsonMapKey, unknown>;
    lastLaunchId            : BigNumber;
    
    lambdaLedger            : MichelsonMap<MichelsonMapKey, unknown>;

};
