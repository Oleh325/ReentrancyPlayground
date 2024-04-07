// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

error ReentrantInvulnerable__BalanceTooLow();
error ReentrantInvulnerable__TransferFailed();
error ReentrantInvulnerable__ReentrancyAttempt();

contract ReentrantInvulnerable {

    mapping(address => uint256) private balances;
    bool private isLocked;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdrawWithLock(uint256 amount) external {
        if (isLocked) {
            revert ReentrantInvulnerable__ReentrancyAttempt();
        }
        isLocked = true;
        if (balances[msg.sender] < amount) {
            revert ReentrantInvulnerable__BalanceTooLow();
        }
        (bool success, ) = msg.sender.call{ value: amount }("");
        if (!success) {
            revert ReentrantInvulnerable__TransferFailed();
        }
        balances[msg.sender] -= amount;
        isLocked = false;
    }

    function withdrawWithCallAtTheEnd(uint256 amount) external {
        if (balances[msg.sender] < amount) {
            revert ReentrantInvulnerable__BalanceTooLow();
        }
        balances[msg.sender] -= amount;
        (bool success, ) = msg.sender.call{ value: amount }("");
        if (!success) {
            revert ReentrantInvulnerable__TransferFailed();
        }
    }
}
