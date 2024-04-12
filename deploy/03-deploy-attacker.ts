import { HardhatRuntimeEnvironment } from "hardhat/types"
import { ethers } from "hardhat"
import { ReentrantVulnerable, ReentrantInvulnerable } from "../typechain-types"

const deployAttacker = async (hre: HardhatRuntimeEnvironment) => {
    const { getNamedAccounts, deployments } = hre
    const { deploy } = deployments
    const { attacker } = await getNamedAccounts()

    const vulnerable = (await ethers.getContract("ReentrantVulnerable", attacker)) as ReentrantVulnerable
    const invulnerable = (await ethers.getContract("ReentrantInvulnerable", attacker)) as ReentrantInvulnerable
    const _reentrantVulnerable = await vulnerable.getAddress()
    const _reentrantInvulnerable = await invulnerable.getAddress()
    const args = [
        _reentrantVulnerable,
        _reentrantInvulnerable
    ]
    await deploy("Attacker", {
        from: attacker,
        args: args,
        log: true,
        waitConfirmations: 1,
    })
}

export default deployAttacker
deployAttacker.tags = ["all", "attacker"]
