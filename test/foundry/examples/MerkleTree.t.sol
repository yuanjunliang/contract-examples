// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "murky/Merkle.sol";

import "contracts/examples/MerkleTree.sol";

contract MerkleTreeTest is Test {
    address owner = address(1);
    MerkleTree merkletree;

    function setUp() public {
        merkletree = new MerkleTree();
    }

    function test_Verify() public {
        bytes32[] memory data = new bytes32[](4);

        data[0] = keccak256(
            bytes.concat(keccak256(abi.encode(address(10), 0.2 ether)))
        );
        data[1] = keccak256(
            bytes.concat(keccak256(abi.encode(address(11), 0.2 ether)))
        );
        data[2] = keccak256(
            bytes.concat(keccak256(abi.encode(address(12), 0.2 ether)))
        );
        data[3] = keccak256(
            bytes.concat(keccak256(abi.encode(address(13), 0.2 ether)))
        );

        Merkle m = new Merkle();
        bytes32 root = m.getRoot(data);

        vm.prank(owner);
        merkletree.setRoot(root);

        for (uint i = 0; i < 4; i++) {
            bytes32[] memory proof = m.getProof(data, i);
            bool verified = merkletree.verify(
                proof,
                address(uint160(i + 10)),
                0.2 ether
            );
            assertTrue(verified);
        }
    }

    function test_verifyForNFT() public {
        bytes32[] memory data = new bytes32[](4);
        data[0] = keccak256(bytes.concat(keccak256(abi.encode(address(10)))));
        data[1] = keccak256(bytes.concat(keccak256(abi.encode(address(11)))));
        data[2] = keccak256(bytes.concat(keccak256(abi.encode(address(12)))));
        data[3] = keccak256(bytes.concat(keccak256(abi.encode(address(13)))));

        Merkle m = new Merkle();
        bytes32 root = m.getRoot(data);

        merkletree.setRoot(root);

        for (uint i = 0; i < 4; i++) {
            bytes32[] memory proof = m.getProof(data, i);
            bool verified = merkletree.verifyForNFTAirdrop(
                proof,
                address(uint160(i + 10))
            );

            assertTrue(verified);
        }
    }
}
