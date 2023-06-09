import { MichelsonMap, MichelsonMapKey } from "@taquito/michelson-encoder"
import { BigNumber } from "bignumber.js"

export type freezeRuleEngineStorageType = {
    administrator           : string;
    frozen_accounts         : MichelsonMap<MichelsonMapKey, unknown>;
};
