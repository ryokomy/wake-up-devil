'use strict';

const HDWalletProvider = require('truffle-hdwallet-provider-privkey');
const privateKeys = [`<replace with deployer's private key>`]

module.exports = {
  networks: {
    development: {
      host: 'localhost',
      port: 7545,
      network_id: '*'
    },
    rinkeby: {
      provider: function() {
        return new HDWalletProvider(privateKeys, 'https://rinkeby.infura.io/');
      },
      network_id: 4,
      gas: 3000000,
      gasPrice: 1000000000 // 1 [GWei]
    }
  },
  privatekey: privateKeys[0]
};