import { ethers } from "hardhat";
const { Wallet } = ethers;

export function generateAccounts(num: number): string[] {
  const accountList = [];
  for (let i = 0; i < num; i++) {
    const { address } = Wallet.createRandom();
    accountList.push(address);
  }
  return accountList;
}
