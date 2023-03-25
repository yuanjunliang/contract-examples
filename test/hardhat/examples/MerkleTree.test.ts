import { ethers } from "hardhat";
import { expect } from "chai";

import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import { MerkleTree } from "merkletreejs";

import { generateAccounts } from "../utils/account.helper";
import { parseEther, defaultAbiCoder, keccak256 } from "ethers/lib/utils";

const accountList = generateAccounts(10);

describe("MerkleTree Test", async function () {
  before(async function () {
    const signers = await ethers.getSigners();
    this.owner = signers[0];

    const MerkleTree = await ethers.getContractFactory("MerkleTree");
    this.mt = await MerkleTree.deploy();
    await this.mt.deployed();
  });

  it("Should verified with openzeppelin merkle-tree", async function () {
    const whitelist = accountList.map((account) => [
      account,
      parseEther("0.2").toString(),
    ]);
    const tree = StandardMerkleTree.of(whitelist, ["address", "uint256"]);
    const root = tree.root;
    await this.mt.connect(this.owner).setRoot(root);

    for (let i = 0; i < whitelist.length; i++) {
      const proof = tree.getProof(i);
      const [account, amount] = whitelist[i];
      const verified = await this.mt.verify(proof, account, amount);
      expect(verified).eq(true);
    }
  });

  it("Should verified with merkletreejs", async function () {
    const whitelist = accountList.map((account) =>
      keccak256(
        keccak256(
          defaultAbiCoder.encode(
            ["address", "uint256"],
            [account, parseEther("0.2").toString()]
          )
        )
      )
    );

    const merkletree = new MerkleTree(whitelist, keccak256, { sort: true });
    const root = merkletree.getHexRoot();

    await this.mt.connect(this.owner).setRoot(root);
    for (const account of accountList) {
      const leaf = keccak256(
        keccak256(
          defaultAbiCoder.encode(
            ["address", "uint256"],
            [account, parseEther("0.2").toString()]
          )
        )
      );

      const proof = merkletree.getHexProof(leaf);
      expect(
        await this.mt.verify(proof, account, parseEther("0.2").toString())
      ).eq(true);
    }
  });

  it("Should verified for NFT airdrop with openzeppelin merkle-tree", async function () {
    const whitelist = accountList.map((account) => [account]);
    const tree = StandardMerkleTree.of(whitelist, ["address"]);
    const root = tree.root;
    await this.mt.connect(this.owner).setRoot(root);

    for (let i = 0; i < whitelist.length; i++) {
      const proof = tree.getProof(i);
      const [account, amount] = whitelist[i];
      const verified = await this.mt.verifyForNFTAirdrop(proof, account);
      expect(verified).eq(true);
    }
  });

  it("Should verified for NFT with merkletreejs", async function () {
    const whitelist = accountList.map((account) =>
      keccak256(keccak256(defaultAbiCoder.encode(["address"], [account])))
    );

    const merkletree = new MerkleTree(whitelist, keccak256, { sort: true });
    const root = merkletree.getHexRoot();

    await this.mt.connect(this.owner).setRoot(root);
    for (const account of accountList) {
      const leaf = keccak256(
        keccak256(defaultAbiCoder.encode(["address"], [account]))
      );

      const proof = merkletree.getHexProof(leaf);
      expect(await this.mt.verifyForNFTAirdrop(proof, account)).eq(true);
    }
  });
});
