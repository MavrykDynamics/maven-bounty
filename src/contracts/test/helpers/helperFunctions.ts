const { InMemorySigner } = require("@taquito/signer");
import { BigNumber } from "bignumber.js"

// ------------------------------------------------------------------------------
// Constants
// ------------------------------------------------------------------------------

export const fixedPointAccuracy = 10**27;

// ------------------------------------------------------------------------------
// RPC Nodes
// ------------------------------------------------------------------------------

export const rpcNodes = {
    activenet: "https://mainnet.smartpy.io",
    ghostnet : "https://ghostnet.ecadinfra.com"
}

// ------------------------------------------------------------------------------
// Signer Factory
// ------------------------------------------------------------------------------

export async function signerFactory (tezos, pk) {
    await tezos.setProvider({ signer: await InMemorySigner.fromSecretKey(pk) })
    return tezos
}


type tezType = Unit;
type fa12TokenType = string; // assuming address is represented by a string
type fa2TokenType = {
    tokenContractAddress: string;
    tokenId: number; // assuming nat (natural numbers) is represented by a number
}

export type currencyType = 
    | { kind: "tez", value: tezType } 
    | { kind: "fa12", value: fa12TokenType }
    | { kind: "fa2", value: fa2TokenType };
    
// ------------------------------------------------------------------------------
// Common Functions
// ------------------------------------------------------------------------------

export async function wait(ms: number) {
    return new Promise((resolve) => setTimeout(resolve, ms));
}

export function makeSnapshotTimestamp(secondsFromNow : number) {
    
    let currentDateTime: Date = new Date()

    // add X seconds to the current date time
    currentDateTime.setUTCSeconds(currentDateTime.getUTCSeconds() + secondsFromNow)

    let year: string = currentDateTime.getUTCFullYear().toString()
    let month: string = (currentDateTime.getUTCMonth() + 1).toString().padStart(2, '0')
    let day: string = currentDateTime.getUTCDate().toString().padStart(2, '0')
    let hours: string = currentDateTime.getUTCHours().toString().padStart(2, '0')
    let minutes: string = currentDateTime.getUTCMinutes().toString().padStart(2, '0')
    let seconds: string = currentDateTime.getUTCSeconds().toString().padStart(2, '0')

    let snapshot_time = `${year}-${month}-${day}T${hours}:${minutes}:${seconds}Z`

    return snapshot_time
}

export function makeTimestamp(secondsFromNow : number) {
    
    let currentDateTime: Date = new Date()

    // add 5 seconds to the current date time
    currentDateTime.setUTCSeconds(currentDateTime.getUTCSeconds() + secondsFromNow)

    let year: string = currentDateTime.getUTCFullYear().toString()
    let month: string = (currentDateTime.getUTCMonth() + 1).toString().padStart(2, '0')
    let day: string = currentDateTime.getUTCDate().toString().padStart(2, '0')
    let hours: string = currentDateTime.getUTCHours().toString().padStart(2, '0')
    let minutes: string = currentDateTime.getUTCMinutes().toString().padStart(2, '0')
    let seconds: string = currentDateTime.getUTCSeconds().toString().padStart(2, '0')

    let snapshot_time = `${year}-${month}-${day}T${hours}:${minutes}:${seconds}Z`

    return snapshot_time
}

export function removeMillisecondsDateFormat(dateString: string): string {
    // Create a Date object
    const date = new Date(dateString);
    // Format the date
    let formattedDate = date.toISOString();
    // Remove the milliseconds
    formattedDate = formattedDate.substring(0, formattedDate.length - 5) + 'Z';
    return formattedDate;
}
  
export function showMillisecondsDateFormat(dateString: string): string {
    // Create a Date object
    const date = new Date(dateString);
    // Format the date to include milliseconds
    let formattedDate = date.toISOString();
    return formattedDate;
}



export function randomNumberFromInterval(min, max) { // min and max included 
    return Math.floor(Math.random() * (max - min + 1) + min)
}
  
export const almostEqual = (actual, expected, delta) => {
    let greaterLimit  = expected + expected * delta
    let lowerLimit    = expected - expected * delta
    return actual <= greaterLimit && actual >= lowerLimit
}


export async function getStorageMapValue (contractStorage, mapName, key) {
    const storageMapValue = await contractStorage[mapName].get(key);
    return storageMapValue;
}


export async function updateWhitelistContracts (contractInstance, key, address, updateType) {
    const updateWhitelistContractsOperation = await contractInstance.methods.updateWhitelistContracts(key, address, updateType).send();
    return updateWhitelistContractsOperation;
}


export async function updateGeneralContracts (contractInstance, key, address, updateType) {
    const updateGeneralContractsOperation = await contractInstance.methods.updateGeneralContracts(key, address, updateType).send();
    return updateGeneralContractsOperation;
}


export async function updateWhitelistTokenContracts (contractInstance, key, address, updateType) {
    const updateWhitelistTokenContractsOperation = await contractInstance.methods.updateWhitelistTokenContracts(key, address, updateType).send();
    return updateWhitelistTokenContractsOperation;
}

// ------------------------------------------------------------------------------
// Token Approvals and Operators
// ------------------------------------------------------------------------------

export async function updateOperators (tokenContractInstance, owner, operator, tokenId) {
    const updateOperatorsOperation = await tokenContractInstance.methods.update_operators([
        {
            add_operator: {
                owner    : owner,
                operator : operator,
                token_id : tokenId,
            },
        }
    ]).send();
    return updateOperatorsOperation;
}


export async function removeOperators (tokenContractInstance, owner, operator, tokenId) {
    const updateOperatorsOperation = await tokenContractInstance.methods.update_operators([
        {
            remove_operator: {
                owner    : owner,
                operator : operator,
                token_id : tokenId,
            },
        }
    ]).send();
    return updateOperatorsOperation;
}


export async function fa12Transfer (tokenContractInstance, from, to, tokenAmount) {
    const transferOperation = await tokenContractInstance.methods.transfer(from, to, tokenAmount).send()
    return transferOperation;
}


export async function fa2Transfer (tokenContractInstance, from, to, tokenId, tokenAmount) {
    const transferOperation = await tokenContractInstance.methods.transfer([
        {
            from_ : from,
            txs: [
                {
                    to_      : to,
                    token_id : tokenId,
                    amount   : tokenAmount,
                }
            ]
        }
    ]).send()
    return transferOperation;
}


export async function fa2MultiTransfer (tokenContractInstance, from, transferDestination) {
    
    let transactions : any = [];
    for(let i = 0; i < transferDestination.length; i++){
        const singleTransaction = {
            to_      : transferDestination[i][0],
            token_id : transferDestination[i][1],
            amount   : transferDestination[i][2],
        };
        transactions.push(singleTransaction);
    }

    const transferOperation = await tokenContractInstance.methods.transfer([
        {
            from_ : from,
            txs   : transactions
        }
    ]).send()
    return transferOperation;
}


export function mistakenTransferFa2Token (contractInstance, to, tokenContractAddress, tokenId, tokenAmount) {
    const mistakenTransferOperation = contractInstance.methods.mistakenTransfer(
    [
        {
            "to_"    : to,
            "token"  : {
                "fa2" : {
                    "tokenContractAddress": tokenContractAddress,
                    "tokenId" : tokenId
                }
            },
            "amount" : tokenAmount
        }
    ])
    return mistakenTransferOperation;
}


export function mistakenTransferFa12Token (contractInstance, to, tokenContractAddress, tokenAmount) {
    const mistakenTransferOperation = contractInstance.methods.mistakenTransfer(
    [
        {
            "to_"    : to,
            "token"  : {
                "fa12" : tokenContractAddress
            },
            "amount" : tokenAmount
        }
    ])
    return mistakenTransferOperation;
}


export function getTokenInfo(currency, field: "tokenContractAddress" | "tokenId") : string | number | null {

    if (currency.fa2 !== undefined) {

        if(field == "tokenContractAddress"){
            return currency.fa2.tokenContractAddress
        } else if(field == "tokenId"){
            return currency.fa2.tokenId
        } else {
            return null
        }

    } else if (currency.fa12 !== undefined && field === "tokenContractAddress") {
        
        return currency.fa12

    } else {

        return null;

    }
}

// ------------------------------------------------------------------------------
// Marketplace Helpers
// ------------------------------------------------------------------------------

export function calculateRoyaltyFee(price, royalty) {
    const royaltyFeeTotal = Math.floor((price * fixedPointAccuracy * royalty) / (fixedPointAccuracy * 10000))
    return royaltyFeeTotal
}


export function mapsAreEqual(map1, map2) {
    
    // console.log(map1.size !== map2.size);

    if (map1.size !== map2.size) return false;
  
    for (let [key, value] of map1) {
      if (!map2.has(key)) return false;
  
      let val1 = value;
      let val2 = map2.get(key);

    //   console.log(`val1 :${val1} | val2: ${val2}`);
  
      // Convert BigNumber to number if necessary
      if (typeof val1.amount === "object" && val1.amount.toNumber) {
        val1.amount = val1.amount.toNumber();

        // console.log(`val1 :${val1.amount}`);
      }
      if (typeof val2.amount === "object" && val2.amount.toNumber) {
        val2.amount = val2.amount.toNumber();
      }

    }
  
    return true;
  }
  
  