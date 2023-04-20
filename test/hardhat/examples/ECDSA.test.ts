import { ethers } from "hardhat";
import { expect } from "chai";

describe("ECDSA Test", async () => {
  let hash: string;
  let signature: string;
  let owner: any;
  let user2: any;
  let ecdsa: any;

  before(async () => {
    const signers = await ethers.getSigners();
    owner = signers[0];
    user2 = signers[1];

    const ECDSAExample = await ethers.getContractFactory("ECDSAExample");
    ecdsa = await ECDSAExample.deploy();
    await ecdsa.deployed();
  });
  beforeEach(async () => {
    hash = ethers.utils.solidityKeccak256(["string"], ["ecdsa test"]);
    signature = await owner.signMessage(ethers.utils.arrayify(hash));
  });

  it("should verify success by signature", async () => {
    expect(await ecdsa.connect(owner).verifySignature(hash, signature)).to.be
      .true;
  });
  it("should verify hash success by r s v", async () => {
    const { r, s, v } = ethers.utils.splitSignature(signature);
    expect(await ecdsa.connect(owner).verifyRSV(hash, v, r, s)).to.be.true;
  });
});
