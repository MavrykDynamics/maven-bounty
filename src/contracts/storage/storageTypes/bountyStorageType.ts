import { MichelsonMap, MichelsonMapKey } from "@taquito/michelson-encoder"
import { BigNumber } from "bignumber.js"

export type bountyStorageType = {

    superAdmin              : string;
    admins                  : [string];   
    newSuperAdmin           : string | null;
    
    metadata                : MichelsonMap<MichelsonMapKey, unknown>;
    config                  : {};

    bountyCreators          : MichelsonMap<MichelsonMapKey, unknown>;
    bountyLedger            : MichelsonMap<MichelsonMapKey, unknown>;
    applicationLedger       : MichelsonMap<MichelsonMapKey, unknown>;
    groupLedger             : MichelsonMap<MichelsonMapKey, unknown>;
    userLedger              : MichelsonMap<MichelsonMapKey, unknown>;

    nextBountyId            : BigNumber;
    nextGroupId             : BigNumber;

    lambdaLedger            : MichelsonMap<MichelsonMapKey, unknown>;

};
