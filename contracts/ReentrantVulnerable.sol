// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

error ReentrantVulnerable__BalanceTooLow();
error ReentrantVulnerable__TransferFailed();

contract ReentrantVulnerable {

    mapping(address => uint256) balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        if (balances[msg.sender] < amount) {
            revert ReentrantVulnerable__BalanceTooLow();
        }
        (bool success, ) = msg.sender.call{ value: amount }("");
        if (!success) {
            revert ReentrantVulnerable__TransferFailed();
        }
        balances[msg.sender] -= amount;
    }
}
