import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";



require('dotenv').config();
require("@nomiclabs/hardhat-ethers");

const { API_URL, PRIVATE_KEY } = process.env;

console.log(PRIVATE_KEY)

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  defaultNetwork: "testnet",
   networks: {
      hardhat: {},
      testnet: {
         url: "https://data-seed-prebsc-1-s1.binance.org:8545",
         chainId: 97,
          gasPrice: 20000000000,
          accounts: [`${PRIVATE_KEY}`],
      }
   },
};

export default config;
