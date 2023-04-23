import { ethers, network } from "hardhat";
import { expect } from "chai";

const { parseEther } = ethers.utils;

const PERMIT_AMOUNT =
  "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";

describe("Permit ERC20 Token Test", async function () {
  before(async function () {
    const signers = await ethers.getSigners();
    this.signer = signers[0];

    const PermitToken = await ethers.getContractFactory("PermitToken");
    const StakePool = await ethers.getContractFactory("StakePool");

    this.token = await PermitToken.deploy("MockToken", "MT");
    await this.token.deployed();

    this.stakePool = await StakePool.deploy(this.token.address);
    await this.stakePool.deployed();
  });

  it("Should permit and deposit success", async function () {
    await this.token.mint(parseEther("10"));
    const domain = {
      name: "MockToken",
      version: "1",
      chainId: network.config.chainId,
      verifyingContract: this.token.address,
    };

    const types = {
      Permit: [
        { name: "owner", type: "address" },
        { name: "spender", type: "address" },
        { name: "value", type: "uint256" },
        { name: "nonce", type: "uint256" },
        { name: "deadline", type: "uint256" },
      ],
    };

    const block = await ethers.provider.getBlock("latest");
    const deadline = block.timestamp + 100;

    const value = {
      owner: this.signer.address,
      spender: this.stakePool.address,
      value: PERMIT_AMOUNT,
      nonce: await this.token.nonces(this.signer.address),
      deadline: deadline,
    };

    const signature = await this.signer._signTypedData(domain, types, value);
    const { v, r, s } = ethers.utils.splitSignature(signature);
    await this.stakePool
      .connect(this.signer)
      .deposit(parseEther("1"), PERMIT_AMOUNT, deadline, v, r, s);
    expect(await this.stakePool.getUserStaking(this.signer.address)).to.eq(
      parseEther("1")
    );
  });
});
