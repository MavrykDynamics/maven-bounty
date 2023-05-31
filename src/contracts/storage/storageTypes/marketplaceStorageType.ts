import { MichelsonMap, MichelsonMapKey } from "@taquito/michelson-encoder"
import { BigNumber } from "bignumber.js"

export type marketplaceStorageType = {
    
    superAdmin              : string;
    admins                  : [];
    newSuperAdmin           : string;
    
    metadata                : MichelsonMap<MichelsonMapKey, unknown>;
    config                  : {};

    whitelistContracts      : MichelsonMap<MichelsonMapKey, unknown>;
    generalContracts        : MichelsonMap<MichelsonMapKey, unknown>;

    nextListingId           : BigNumber;
    nextOfferId             : BigNumber;

    listingLedger           : MichelsonMap<MichelsonMapKey, unknown>;
    offerLedger             : MichelsonMap<MichelsonMapKey, unknown>;
    currencyLedger          : MichelsonMap<MichelsonMapKey, unknown>;

    lambdaLedger            : MichelsonMap<MichelsonMapKey, unknown>;

};
