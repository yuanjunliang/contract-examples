import { ethers } from "hardhat";
import { expect } from "chai";

const { parseEther } = ethers.utils;

function generateAccounts(n: number): string[] {
  const accounts = [];

  for (let i = 0; i < n; i++) {
    const { address } = ethers.Wallet.createRandom();
    accounts.push(address);
  }
  return accounts;
}

describe("Batch Transfer Test", async function () {
  before(async function () {
    const signers = await ethers.getSigners();
    this.owner = signers[0];

    const BatchTransfer = await ethers.getContractFactory("BatchTransfer");
    this.batchTransfer = await BatchTransfer.deploy();
    await this.batchTransfer.deployed();

    const MT = await ethers.getContractFactory("ERC20Mock");
    this.mt = await MT.deploy("MockToken", "MT");
    await this.mt.deployed();
    await this.mt.mintTo(this.owner.address, parseEther("10000"));
  });

  it("Should batch transfer ETH success", async function () {
    const receivers = generateAccounts(10);
    const amounts = Array(10).fill(parseEther("1.5"));
    await this.batchTransfer
      .connect(this.owner)
      .batchTransferETH(receivers, amounts, { value: parseEther("15") });

    expect(await ethers.provider.getBalance(receivers[0])).to.eq(
      parseEther("1.5").toString()
    );
  });

  it("Should reverted if msg.value not enough when transfer ETH", async function () {
    const receivers = generateAccounts(10);
    const amounts = Array(10).fill(parseEther("1.5"));

    await expect(
      this.batchTransfer
        .connect(this.owner)
        .batchTransferETH(receivers, amounts, { value: parseEther("10") })
    ).reverted;
  });

  it("Should batch transfer ERC20 success", async function () {
    const receivers = generateAccounts(10);
    const amounts = Array(10).fill(parseEther("1.5"));

    await this.mt
      .connect(this.owner)
      .approve(this.batchTransfer.address, parseEther("15"));

    await this.batchTransfer
      .connect(this.owner)
      .batchTransferERC20(this.mt.address, receivers, amounts);
  });
});
