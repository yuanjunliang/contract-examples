// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BatchTransfer {
    error InvalidParams();
    error InvalidValue();

    event TransferETHSuccess(address receiver, uint256 amount);

    function batchTransferETH(
        address[] calldata receivers,
        uint256[] calldata amounts
    ) external payable {
        if (receivers.length != amounts.length) {
            revert InvalidParams();
        }

        for (uint256 i; i < receivers.length; ++i) {
            payable(receivers[i]).transfer(amounts[i]);

            emit TransferETHSuccess(receivers[i], amounts[i]);
        }
    }

    function batchTransferERC20(
        IERC20 token,
        address[] calldata receivers,
        uint256[] calldata amounts
    ) external {
        if (receivers.length != amounts.length) {
            revert InvalidParams();
        }

        for (uint i = 0; i < receivers.length; i++) {
            token.transferFrom(msg.sender, receivers[i], amounts[i]);
        }
    }
}
