// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import {PermitToken, StakePool} from "contracts/examples/PermitToken.sol";

contract PermitTokenTest is Test {
    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );
    bytes32 typeHash =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    PermitToken public token;
    StakePool public stakePool;

    uint256 privateKey = 1;
    address user = vm.addr(privateKey);

    function setUp() public {
        token = new PermitToken("MockToken", "MT");
        stakePool = new StakePool(token);
    }

    function test_Deposit() public {
        deal(address(token), user, 10 ether);

        uint256 permitAmount = type(uint256).max;
        uint256 deadline = block.timestamp + 100;

        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                address(user),
                address(stakePool),
                permitAmount,
                token.nonces(user),
                deadline
            )
        );

        bytes32 domainSeparator = keccak256(
            abi.encode(
                typeHash,
                keccak256(abi.encodePacked(token.name())),
                keccak256("1"),
                block.chainid,
                address(token)
            )
        );

        bytes32 hash = ECDSA.toTypedDataHash(domainSeparator, structHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, hash);

        vm.prank(user);
        stakePool.deposit(1 ether, permitAmount, deadline, v, r, s);
        assertEq(stakePool.getUserStaking(address(user)), 1 ether);
    }
}
