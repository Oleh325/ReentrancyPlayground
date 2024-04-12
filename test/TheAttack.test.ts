import { assert, expect } from "chai"
import { network, deployments, ethers } from "hardhat"
import { Attacker, ReentrantVulnerable, ReentrantInvulnerable } from "../typechain-types"
import { BigNumberish } from "ethers"
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers"

describe("Reentrancy Attack", function () {
    let attackerContract: Attacker
    let vulnerable: ReentrantVulnerable
    let invulnerable: ReentrantInvulnerable
    let attacker: HardhatEthersSigner
    let victim: HardhatEthersSigner

    beforeEach(async function () {
        attacker = (await ethers.getNamedSigners()).attacker
        victim = (await ethers.getNamedSigners()).victim
        await deployments.fixture(["all"])
        vulnerable = (await ethers.getContract("ReentrantVulnerable", victim)) as ReentrantVulnerable
        invulnerable = (await ethers.getContract("ReentrantInvulnerable", victim)) as ReentrantInvulnerable
        attackerContract = (await ethers.getContract("Attacker", attacker)) as Attacker
    })

    describe("Attack vulnerable", async function () {
        it("should attack vulnerable contract and drain everything the victim deposited", async function () {
            await vulnerable.deposit({ value: ethers.parseEther("10") })
            const attackerBalance = await ethers.provider.getBalance(attacker.address)
            const transaction = await attackerContract.attackVulnerable({ value: ethers.parseEther("1") })
            const transactionReceipt = await transaction.wait(1)
            let feesSpent = transactionReceipt?.fee!
            const withdrawTransaction = await attackerContract.withdraw()
            const withdrawTransactionReceipt = await withdrawTransaction.wait(1)
            feesSpent += withdrawTransactionReceipt?.fee!
            const attackerBalanceAfter = await ethers.provider.getBalance(attacker.address)
            expect(attackerBalanceAfter).to.be.equal(attackerBalance + ethers.parseEther("10") - feesSpent)
        })
    })
    describe("Attack invulnerable", async function () {
        it("should revert while trying to attack the method with call at the end", async function () {
            await invulnerable.deposit({ value: ethers.parseEther("10") })
            expect(attackerContract.attackInvulnerable()).to.be.revertedWithCustomError({ interface: invulnerable.interface }, "ReentrantInvulnerable__BalanceTooLow()")            
        })
        it("should revert while trying to attack the method with lock", async function () {
            await invulnerable.deposit({ value: ethers.parseEther("10") })
            expect(attackerContract.attackInvulnerable()).to.be.revertedWithCustomError({ interface: invulnerable.interface }, "ReentrantInvulnerable__ReentrancyAttempt()")            
        })
    })
})