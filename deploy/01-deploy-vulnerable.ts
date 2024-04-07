import { HardhatRuntimeEnvironment } from "hardhat/types"

const deployVulnerable = async (hre: HardhatRuntimeEnvironment) => {
    const { getNamedAccounts, deployments } = hre
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()

    const args: any[] = []
    await deploy("ReentrantVulnerable", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: 1,
    })
}

export default deployVulnerable
deployVulnerable.tags = ["all", "vulnerable"]
