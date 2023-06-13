import { MichelsonMap, MichelsonMapKey } from "@taquito/michelson-encoder"
import { BigNumber } from "bignumber.js"

export type tokenRegistryStorageType = {
    
    superAdmin              : string;
    admins                  : [string];
    newSuperAdmin           : string | null;
    
    metadata                : MichelsonMap<MichelsonMapKey, unknown>;
    breakGlassConfig        : {};

    whitelistContracts      : MichelsonMap<MichelsonMapKey, unknown>;
    generalContracts        : MichelsonMap<MichelsonMapKey, unknown>;
    
    defaultFee              : BigNumber;
    defaultBeneficiary      : string;

    tokenLedger             : MichelsonMap<MichelsonMapKey, unknown>;
    
    lambdaLedger            : MichelsonMap<MichelsonMapKey, unknown>;

};
