// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract ECDSAExample {
    function verifySignature(
        bytes32 hash,
        bytes calldata signature
    ) public view returns (bool) {
        bytes32 messageHash = ECDSA.toEthSignedMessageHash(hash);
        address signer = ECDSA.recover(messageHash, signature);
        return signer == msg.sender;
    }

    function verifyRSV(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public view returns (bool) {
        bytes32 messageHash = ECDSA.toEthSignedMessageHash(hash);
        address signer = ECDSA.recover(messageHash, v, r, s);
        return signer == msg.sender;
    }

    // recover messages whitout prefix: "\x19Ethereum Signed Message:\n32"
    function verifyWithoutPrefix(
        bytes32 hash,
        bytes calldata signature
    ) public view returns (bool) {
        address signer = ECDSA.recover(hash, signature);
        return signer == msg.sender;
    }
}
