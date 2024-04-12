import { HardhatRuntimeEnvironment } from "hardhat/types"

const deployInvulnerable = async (hre: HardhatRuntimeEnvironment) => {
    const { getNamedAccounts, deployments } = hre
    const { deploy } = deployments
    const { victim } = await getNamedAccounts()

    const args: any[] = []
    await deploy("ReentrantInvulnerable", {
        from: victim,
        args: args,
        log: true,
        waitConfirmations: 1,
    })
}

export default deployInvulnerable
deployInvulnerable.tags = ["all", "invulnerable"]
