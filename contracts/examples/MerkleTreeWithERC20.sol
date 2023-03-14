// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @dev Airdrop with merkle tree example
 */
contract MerkleTreeWithERC20 is Ownable {
    bytes32 public root;

    error ZeroRootSet();
    error InvalidProof();

    event MerkleRootSet(bytes32 root);
    event Deposit(address token, uint256 amount);
    event Withdraw(address token, uint256 amount);
    event ClaimAirdropSuccess(address account, uint256 amount, address token);

    constructor(address owner_) {
        _transferOwnership(owner_);
    }

    function setMerkleRoot(bytes32 root_) external onlyOwner {
        if (root_ == bytes32(0)) {
            revert ZeroRootSet();
        }

        root = root_;

        emit MerkleRootSet(root);
    }

    // deposit amount of token for airdrop
    function deposit(address token, uint256 amount) external onlyOwner {
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        emit Deposit(token, amount);
    }

    function claimAirdrop(
        bytes32[] calldata proof,
        uint256 amount,
        address token
    ) external {
        // verify whether user in whitelist
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(msg.sender, amount)))
        );

        bool verified = MerkleProof.verify(proof, root, leaf);

        if (!verified) {
            revert InvalidProof();
        }

        IERC20(token).transfer(msg.sender, amount);

        emit ClaimAirdropSuccess(msg.sender, amount, token);
    }

    // withdraw unclaimed tokens
    function withdraw(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);

        emit Withdraw(token, amount);
    }
}
