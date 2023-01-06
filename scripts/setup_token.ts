// 

import { ethers } from "hardhat";




async function main() {


    const BMD_contract_address = "0x00FFc56f91111155Ec";
    
   
    const SBT_contract = await ethers.getContractAt("BitmoonDaoToken", BMD_contract_address);

    const IDO_WALLET = "0xc31E558c8AD54b6De111111";
    const TEAM_WALLET = "0xc97e9F7919586eac301111";
    const GAME_WALLET = "0xb09eeEAEdbD741C111";
    const MKT_WALLET = "0x38321A4cb26753a111";
    const LIQ_WALLET = "0xa50baD4C70B00D5111";
    const STAKE_WALLET = "0xf2BC5F70f97962DA111";
    const AIRDROP_WALLET = "0x30003fa2E24Aa1DcD4111";

    const MOD_WALLET = "0x727b51b3cEbE69eaa1111";
    const MOD_TUYEN = "0xb66347E999Cd6b82A111";

    const LIVENET_ROUTER_ADDRESS = "0x10ED43C718714eb631111E";
    const TESTNET_ROUTER_ADDRESS = "0x9Ac64Cc6e4415144C411113";

    

    // await SBT_contract.setup_wallets(IDO_WALLET,TEAM_WALLET,GAME_WALLET,MKT_WALLET,LIQ_WALLET,STAKE_WALLET,AIRDROP_WALLET);

    await SBT_contract.allowAccess([MOD_WALLET,MOD_TUYEN]);

    // await SBT_contract.setup_pancakerouter(TESTNET_ROUTER_ADDRESS);
    
    console.log("Set up Finished")
    
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
