require('@nomiclabs/hardhat-waffle')
require('@atixlabs/hardhat-time-n-mine')
require('@nomiclabs/hardhat-etherscan')

const fs = require('fs')
const dev = fs.readFileSync('.secret').toString().trim()
module.exports = {
  solidity: {
    compilers: [
      {
        version: '0.8.1',
      },
      {
        version: '0.7.4',
      },
    ],
  },
  networks: {
    'mainnet': {
      url: 'https://bsc-dataseed.binance.org',
      chainId: 56,
      accounts: [dev],
    },
    'testnet': {
      url: 'https://data-seed-prebsc-1-s1.binance.org:8545',
      chainId: 97,
      accounts: [dev],
    },
  },
  etherscan: {
    apiKey: "8PIDQ6G9CGWIBJW3DXRTY56G4H46E25YHE"
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './cache',
    artifacts: './artifacts',
    deploy: 'deploy',
    deployments: 'deployments',
  },
  mocha: {
    timeout: 5 * 60 * 10000,
  },
}
