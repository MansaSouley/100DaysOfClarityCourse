
import { Clarinet, Tx, Chain, Account, Contract, types } from 'https://deno.land/x/clarinet@v0.31.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "ENsure that the right amount of STX(nft price) is transferred",
    async fn(chain: Chain, accounts: Map<string, Account>, conctracts: Map<string, Contract>){
        let deployer = accounts.get("deployer")!;
        let wallet_1 = accounts.get("wallet_1")!;
    }
})
