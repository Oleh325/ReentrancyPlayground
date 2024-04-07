import { HardhatRuntimeEnvironment } from "hardhat/types"
import { ethers } from "hardhat"
import { ReentrantVulnerable, ReentrantInvulnerable } from "../typechain-types"

const deployAttacker = async (hre: HardhatRuntimeEnvironment) => {
    const { getNamedAccounts, deployments } = hre
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()

    await deployments.fixture(["all"])
    const vulnerable = (await ethers.getContract("ReentrantVulnerable", deployer)) as ReentrantVulnerable
    const invulnerable = (await ethers.getContract("ReentrantInvulnerable", deployer)) as ReentrantInvulnerable
    const _reentrantVulnerable = await vulnerable.getAddress()
    const _reentrantInvulnerable = await invulnerable.getAddress()
    const args = [
        _reentrantVulnerable,
        _reentrantInvulnerable
    ]
    await deploy("Attacker", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: 1,
    })
}

export default deployAttacker
deployAttacker.tags = ["all", "attacker"]
