import {
    ContractAbstraction,
    ContractMethod,
    ContractMethodObject,
    ContractProvider,
    ContractView,
    OriginationOperation,
    TezosToolkit,
    Wallet
} from "@taquito/taquito"
import fs from "fs"

import env from "../../env"
import { confirmOperation } from "../../scripts/confirmation"
import { OnChainView } from "@taquito/taquito/dist/types/contract/contract-methods/contract-on-chain-view"

// Contracts Storage Type

const generalContractLambdas = {
    
}

type generalContractStorageType = ""

    // contracts
    
    
    // tokens
    

type GeneralContractContractMethods<T extends ContractProvider | Wallet> = {
    setLambda: (lambdaName: string, lambdaBytes: string) => ContractMethod<T>;
    setProductLambda: (lambdaName: string, lambdaBytes: string)  => ContractMethod<T>;
    updateWhitelistContracts: (
        whitelistContractName       : string,
        whitelistContractAddress    : string
    ) => ContractMethod<T>;
    updateGeneralContracts: (
        generalContractName         : string,
        generalContractAddress      : string
    ) => ContractMethod<T>;
};

type GeneralContractContractMethodObject<T extends ContractProvider | Wallet> =
    Record<string, (...args: any[]) => ContractMethodObject<T>>;

type GeneralContractViews = Record<string, (...args: any[]) => ContractView>;

type GeneralContractOnChainViews = {
    decimals: () => OnChainView;
};

type GeneralContractAbstraction<T extends ContractProvider | Wallet = any> = ContractAbstraction<T,
    GeneralContractContractMethods<T>,
    GeneralContractContractMethodObject<T>,
    GeneralContractViews,
    GeneralContractOnChainViews,
    generalContractStorageType>;


export const setGeneralContractLambdas = async (tezosToolkit: TezosToolkit, contractName : string, contract: GeneralContractAbstraction, consoleLogBool = true ? true : false) => {

    var lambdasPerBatch = 10;

    const lambdas = generalContractLambdas[contractName];
    const lambdasCount  = Object.keys(lambdas).length;
    const batchesCount  = Math.ceil(lambdasCount / lambdasPerBatch);

    for(let i = 0; i < batchesCount; i++) {
        
        const batch = tezosToolkit.wallet.batch();
        var index   = 0;

        for (let lambdaName in lambdas) {
            let bytes   = lambdas[lambdaName]
            if(index < (lambdasPerBatch * (i + 1)) && (index >= lambdasPerBatch * i)){
                batch.withContractCall(contract.methods.setLambda(lambdaName, bytes))
            }
            index++;
        }

        const setupGeneralContractLambdasOperation = await batch.send()
        await confirmOperation(tezosToolkit, setupGeneralContractLambdasOperation.opHash);
    }

    if(consoleLogBool == true){
        // console log contract name in Title Case
        const rawName = contractName.substring(0, contractName.length);
        const addSpaces = rawName.replace(/([A-Z])/g, " $1");
        const formattedContractName = addSpaces.charAt(0).toUpperCase() + addSpaces.slice(1);
        console.log(`${formattedContractName} lambdas setup`)
    }
    
};



export class GeneralContract {
    
    contract        : GeneralContractAbstraction;
    storage         : generalContractStorageType;
    contractName    : string;
    tezos           : TezosToolkit;
  
    constructor(contract: GeneralContractAbstraction, contractName : string, tezos: TezosToolkit) {
        this.contract     = contract;
        this.contractName = contractName;
        this.tezos        = tezos;
    }
  
    static async init(
        generalContractAddress: string,
        contractName : string,
        tezos: TezosToolkit
    ): Promise<GeneralContract> {
        return new GeneralContract(
            await tezos.contract.at(generalContractAddress),
            contractName,
            tezos
        );
    }

    static async originate(
        tezos: TezosToolkit,
        contractName: string,
        storage: generalContractStorageType
    ): Promise<GeneralContract> {       

        // get contract artifacts
        const artifacts: any = JSON.parse(
            fs.readFileSync(`${env.buildDir}/${contractName}.json`).toString()
        );

        // get storage from array
        // const storage = generalControllerStorage[contractName];

        const operation : OriginationOperation = await tezos.contract
        .originate({
            code: artifacts.michelson,
            storage: storage,
        })
        .catch((e) => {
            console.error(e);
            console.log('error no hash')
            return null;
        });
  
        await confirmOperation(tezos, operation.hash);
  
        return new GeneralContract(
            await tezos.contract.at(operation.contractAddress),
            contractName,
            tezos
        );
    }

}
  