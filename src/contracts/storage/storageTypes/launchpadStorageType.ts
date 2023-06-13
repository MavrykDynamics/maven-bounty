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

    saleLedger              : MichelsonMap<MichelsonMapKey, unknown>;
    saleWhitelistLedger     : MichelsonMap<MichelsonMapKey, unknown>;
    salePurchaseLedger      : MichelsonMap<MichelsonMapKey, unknown>;
    lastSaleId              : BigNumber;
    
    lambdaLedger            : MichelsonMap<MichelsonMapKey, unknown>;

};
