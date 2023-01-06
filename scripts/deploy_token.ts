import { ethers } from "hardhat";

async function main() {
  const SBT = await ethers.getContractFactory("BitmoonDaoToken");

  const SBT_Token = await SBT.deploy();

  console.log("Contract deployed to address:", SBT_Token.address)


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
