// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

error ReentrantVulnerable__BalanceTooLow();
error ReentrantVulnerable__TransferFailed();

contract ReentrantVulnerable {

    mapping(address => uint256) balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        if (balances[msg.sender] <= 0) {
            revert ReentrantVulnerable__BalanceTooLow();
        }
        (bool success, ) = msg.sender.call{ value: balances[msg.sender] }("");
        if (!success) {
            revert ReentrantVulnerable__TransferFailed();
        }
        balances[msg.sender] = 0;
    }
}
