var HDWalletProvider = require("truffle-hdwallet-provider");
var testnetMnemonic = "lyrics unable brain wet blast entry dash alert wrestle bacon popular fold";

mainnetMnemonic = "XXX";


module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*" // Match any network ID
    },
    ropsten: {
      provider: function() {
        return new HDWalletProvider(testnetMnemonic, "https://ropsten.infura.io/CQ4TCTCfJ6wsd5VRRgYm")
      },
      network_id: 3,
      gas: 7900000,
      gasPrice: 21000000000
    },
    mainnet: {
      provider: function() {
        return new HDWalletProvider(mainnetMnemonic, "https://mainnet.infura.io/F5xdDA6sjrIgRJNUivmc")
      },
      network_id: 1,
      gas: 7900000,
      gasPrice: 12000000000 
    }
  }
};
