import "@typechain/hardhat"
import "@nomicfoundation/hardhat-verify"
import "@nomicfoundation/hardhat-chai-matchers"
import "@nomiclabs/hardhat-ethers"
import "hardhat-deploy"
import { HardhatUserConfig } from "hardhat/config"

const config: HardhatUserConfig = {
    solidity: "0.8.24",
    defaultNetwork: "hardhat",
    networks: {
        localhost: {
            chainId: 31337,
        },
    },
    namedAccounts: {
        attacker: {
            default: 0,
        },
        victim: {
            default: 1,
        },
    },
}

export default config
