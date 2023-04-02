import { task } from "hardhat/config";

// use example: npx hardhat mintERC20 --to address --amount 5000 --network sepolia
task("mintERC20", "mint mock ERC20Token")
  .addParam("to", "account mint to")
  .addParam("amount", "amount to mint")
  .setAction(async function (taskArguments, hre, runSuper) {
    const { ethers } = hre;
    const { parseEther } = ethers.utils;
    const mt = await hre.ethers.getContractAt(
      "ERC20Mock",
      "0x69De2Af229fA3bd698cE1148Acb8AaB31092880D" // sepolia testnet test contract
    );

    const tx = await mt.mintTo(
      taskArguments.to,
      parseEther(taskArguments.amount)
    );
    console.log(`txhash: ${tx.hash}`);
  });
