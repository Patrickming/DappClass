require("@nomicfoundation/hardhat-toolbox");

//在配置文件中引用
require('dotenv').config()

//读取配置文件.env里的    || ''是因为要string
let ALCHEMY_KEY = process.env.ALCHEMY_KEY || ''
let INFURA_KEY = process.env.INFURA_KEY || ''
let PRIVATE_KEY = process.env.PRIVATE_KEY || ''
let ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || ''

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  networks: {
      okttest: {
        url: ` https://exchaintestrpc.okex.org`,
        accounts: [PRIVATE_KEY]
      },
      goerli: {
          url: `https://eth-goerli.g.alchemy.com/v2/${ALCHEMY_KEY}`,
          accounts: [PRIVATE_KEY]
      }
  },
  // 配置自动化verify相关
  etherscan: {
      apiKey: {
          goerli: ETHERSCAN_API_KEY
      },
  },
  // 配置编译器版本
  solidity: {
      version: "0.8.18",
      settings: {
          optimizer: {
              enabled: false,
              runs: 200
          }
      }
  }
};
