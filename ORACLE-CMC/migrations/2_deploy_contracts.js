var CMCOracle = artifacts.require("./CMCOracle.sol");
var token = artifacts.require("./CryptoTestTokens.sol");

module.exports = function(deployer) {
  deployer.deploy(CMCOracle);
  deployer.deploy(token);
};
