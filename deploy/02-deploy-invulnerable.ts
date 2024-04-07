import { HardhatRuntimeEnvironment } from "hardhat/types"

const deployInvulnerable = async (hre: HardhatRuntimeEnvironment) => {
    const { getNamedAccounts, deployments } = hre
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()

    const args: any[] = []
    await deploy("ReentrantInvulnerable", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: 1,
    })
}

export default deployInvulnerable
deployInvulnerable.tags = ["all", "invulnerable"]
