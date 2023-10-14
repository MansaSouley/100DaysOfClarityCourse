
import { Clarinet, Tx, Chain, Account, Contract, types } from 'https://deno.land/x/clarinet@v0.31.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Ensure that the right amount of STX(nft price) is transferred by expectingEvent",
    async fn(chain: Chain, accounts: Map<string, Account>, conctracts: Map<string, Contract>){
        let deployer = accounts.get("deployer")!;
        let wallet_1 = accounts.get("wallet_1")!;

        let block = chain.mineBlock([
            Tx.contractCall("nft-simple", "mint", [], wallet_1.address)
        ]);

        block.receipts[0].result.expectOk().expectBool(true);
        console.log(block.receipts[0].events);
        block.receipts[0].events.expectSTXTransferEvent(
            10000000,
            wallet_1.address,
            `${deployer.address}.nft-simple`
        )
    }
})

Clarinet.test({
    name: "Ensure that the right amount of STX(nft price) is transferred by checking balances",
    async fn(chain: Chain, accounts: Map<string, Account>, conctracts: Map<string, Contract>){
        let deployer = accounts.get("deployer")!;
        let wallet_1 = accounts.get("wallet_1")!;

        let block = chain.mineBlock([
            Tx.contractCall("nft-simple", "mint", [], wallet_1.address)
        ]);

        block.receipts[0].result.expectOk().expectBool(true);
        console.log(block.receipts[0].events);
        assertEquals(chain.getAssetsMaps().assets['STX'][wallet_1.address], 99999990000000);
    }
})

Clarinet.test({
    name: "Ensure that the right NFT is minted to the right address",
    async fn(chain: Chain, accounts: Map<string, Account>, conctracts: Map<string, Contract>){
        let deployer = accounts.get("deployer")!;
        let wallet_1 = accounts.get("wallet_1")!;

        let block = chain.mineBlock([
            Tx.contractCall("nft-simple", "mint", [], wallet_1.address)
        ]);

        block.receipts[0].result.expectOk().expectBool(true);
        console.log(block.receipts[0].events);
        block.receipts[0].events.expectNonFungibleTokenMintEvent(
            types.uint(1),
            wallet_1.address,
            `${deployer.address}.nft-simple`,
            "simple-nft"
        )
    }
})