// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleTree {
    error ZeroRootSet();

    event SetNewRoot(bytes32 root);

    bytes32 public root;

    function setRoot(bytes32 root_) external {
        if (root_ == bytes32(0)) {
            revert ZeroRootSet();
        }
        root = root_;

        emit SetNewRoot(root_);
    }

    function verify(
        bytes32[] calldata proof,
        address account,
        uint256 amount
    ) public view returns (bool) {
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(account, amount)))
        );

        return MerkleProof.verify(proof, root, leaf);
    }

    function verifyForNFTAirdrop(
        bytes32[] calldata proof,
        address account
    ) public view returns (bool) {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account))));

        return MerkleProof.verify(proof, root, leaf);
    }
}
