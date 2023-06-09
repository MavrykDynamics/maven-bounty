import { MichelsonMap } from "@taquito/michelson-encoder"
import { freezeRuleEngineStorageType } from "./storageTypes/freezeRuleEngineStorageType"
import { eve } from '../scripts/sandbox/accounts'

export const freezeRuleEngineStorage: freezeRuleEngineStorageType = {
    administrator           : eve.pkh,
    frozen_accounts         : MichelsonMap.fromLiteral({})
};
