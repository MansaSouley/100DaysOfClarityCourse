
import { Clarinet, Tx, Chain, Account, Contract, types } from 'https://deno.land/x/clarinet@v0.31.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Ensure that user can mint NFT & stake ",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        let deployer = accounts.get("deployer")!;
        let wallet_1 = accounts.get("wallet_1")!;

        let mintBlock = chain.mineBlock([
           Tx.contractCall("nft-simple", "mint", [], deployer.address)
        ]);

        console.log(mintBlock.receipts[0].events);

        chain.mineEmptyBlock(1);

        let stakeBlock = chain.mineBlock([
           Tx.contractCall("staking-simple", "stake-nft", [types.uint(1)], deployer.address)
        ]);
       
        console.log(stakeBlock.receipts[0].events)
        stakeBlock.receipts[0].result.expectOk()
    },
});

Clarinet.test({
    name: "Get unclaimed balance after 5 blocks",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        let deployer = accounts.get("deployer")!;
        let wallet_1 = accounts.get("wallet_1")!;

        let mintBlock = chain.mineBlock([
           Tx.contractCall("nft-simple", "mint", [], deployer.address)
        ]);

        console.log(mintBlock.receipts[0].events);

        chain.mineEmptyBlock(1);

        let stakeBlock = chain.mineBlock([
           Tx.contractCall("staking-simple", "stake-nft", [types.uint(1)], deployer.address)
        ]);
       
        console.log(stakeBlock.receipts[0].events)
        
        chain.mineEmptyBlock(5);

        const getUnclaimedBalance = chain.callReadOnlyFn("staking-simple", "get-unclaimed-balance",[], deployer.address);
        console.log(getUnclaimedBalance);

        getUnclaimedBalance.result.expectOk().expectUint(6);

        console.log(chain.getAssetsMaps());
    },
});

Clarinet.test({
    name: "Test claiming after 5 blocks",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        let deployer = accounts.get("deployer")!;
        let wallet_1 = accounts.get("wallet_1")!;

        let mintBlock = chain.mineBlock([
           Tx.contractCall("nft-simple", "mint", [], deployer.address)
        ]);
        
        chain.mineEmptyBlock(1);

        let stakeBlock = chain.mineBlock([
           Tx.contractCall("staking-simple", "stake-nft", [types.uint(1)], deployer.address)
        ]);
                      
        chain.mineEmptyBlock(5);

         let claimBlock = chain.mineBlock([
           Tx.contractCall("staking-simple", "claim-reward", [types.uint(1)], deployer.address)
        ]);
        
        console.log(claimBlock.receipts[0].events);
        
        console.log(chain.getAssetsMaps());
        assertEquals(chain.getAssetsMaps().assets['.simple-ft.clarity-token'][deployer.address], 6);
    },
});