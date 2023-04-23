// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PermitToken is ERC20Permit {
    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) ERC20Permit(name_) {}

    function mint(uint256 amount) public {
        _mint(msg.sender, amount);
    }
}

contract StakePool {
    PermitToken public token;
    mapping(address => uint256) internal userStaked;

    event Deposit(address account, uint256 amount);

    constructor(PermitToken token_) {
        token = token_;
    }

    function deposit(
        uint256 amount,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        token.permit(msg.sender, address(this), value, deadline, v, r, s);
        userStaked[msg.sender] = amount;
        token.transferFrom(msg.sender, address(this), amount);
        emit Deposit(msg.sender, amount);
    }

    function getUserStaking(address account) external view returns (uint256) {
        return userStaked[account];
    }
}
