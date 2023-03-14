// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "murky/Merkle.sol";

import "contracts/examples/MerkleTreeWithERC20.sol";
import "contracts/mock/ERC20Mock.sol";

contract MerkleTreeWithERC20Test is Test {
    address owner = vm.addr(1);

    address user1 = vm.addr(11);
    address user2 = vm.addr(12);
    address user3 = vm.addr(13);
    address user4 = vm.addr(14);

    ERC20Mock token;
    MerkleTreeWithERC20 airdrop;

    function setUp() public {
        token = new ERC20Mock("MockToken", "MT");
        token.mint(owner, 1000 ether);
        airdrop = new MerkleTreeWithERC20(owner);
    }

    function testClaimAirdrop() public {
        _deposit();

        // generate merkle tree
        Merkle m = new Merkle();
        bytes32[] memory data = new bytes32[](4);
        data[0] = keccak256(
            bytes.concat(keccak256(abi.encode(user1, 0.1 ether)))
        );
        data[1] = keccak256(
            bytes.concat(keccak256(abi.encode(user1, 0.2 ether)))
        );
        data[2] = keccak256(
            bytes.concat(keccak256(abi.encode(user1, 0.3 ether)))
        );
        data[3] = keccak256(
            bytes.concat(keccak256(abi.encode(user1, 0.4 ether)))
        );

        // set merkle root to airdrop
        bytes32 root = m.getRoot(data);
        vm.prank(owner);
        airdrop.setMerkleRoot(root);

        // verify proof and claim airdrop
        bytes32[] memory proof = m.getProof(data, 0);
        vm.prank(user1);
        airdrop.claimAirdrop(proof, 0.1 ether, address(token));

        assertEq(token.balanceOf(address(user1)), 0.1 ether);
    }

    function _deposit() internal returns (uint256) {
        uint256 amount = 10 ether;

        vm.startPrank(owner);
        token.approve(address(airdrop), amount);
        airdrop.deposit(address(token), amount);
        vm.stopPrank();
        return amount;
    }
}
