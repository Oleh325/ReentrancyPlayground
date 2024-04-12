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

    function withdrawWithLock() external {
        if (isLocked) {
            revert ReentrantInvulnerable__ReentrancyAttempt();
        }
        isLocked = true;
        if (balances[msg.sender] <= 0) {
            revert ReentrantInvulnerable__BalanceTooLow();
        }
        (bool success, ) = msg.sender.call{ value: balances[msg.sender] }("");
        if (!success) {
            revert ReentrantInvulnerable__TransferFailed();
        }
        balances[msg.sender] = 0;
        isLocked = false;
    }

    function withdrawWithCallAtTheEnd() external {
        if (balances[msg.sender] <= 0) {
            revert ReentrantInvulnerable__BalanceTooLow();
        }
        balances[msg.sender] = 0;
        (bool success, ) = msg.sender.call{ value: balances[msg.sender] }("");
        if (!success) {
            revert ReentrantInvulnerable__TransferFailed();
        }
    }
}
