import { MichelsonMap, MichelsonMapKey } from "@taquito/michelson-encoder"
import { BigNumber } from "bignumber.js"

export type bountyStorageType = {

    superAdmin              : string;
    admins                  : [string];   
    newSuperAdmin           : string | null;
    
    metadata                : MichelsonMap<MichelsonMapKey, unknown>;
    config                  : {};
    // breakGlassConfig        : {};

    // whitelistContracts      : MichelsonMap<MichelsonMapKey, unknown>;
    // generalContracts        : MichelsonMap<MichelsonMapKey, unknown>;
    bountyCreators          : MichelsonMap<MichelsonMapKey, unknown>;

    nextBountyId            : BigNumber;
    nextGroupId             : BigNumber;

    bountyLedger            : MichelsonMap<MichelsonMapKey, unknown>;
    applicationLedger       : MichelsonMap<MichelsonMapKey, unknown>;
    groupLedger             : MichelsonMap<MichelsonMapKey, unknown>;
    userLedger              : MichelsonMap<MichelsonMapKey, unknown>;

    lambdaLedger            : MichelsonMap<MichelsonMapKey, unknown>;

};
