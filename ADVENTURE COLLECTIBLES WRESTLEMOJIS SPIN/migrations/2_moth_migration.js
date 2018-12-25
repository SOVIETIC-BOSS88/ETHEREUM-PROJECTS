var MothThankYou = artifacts.require("MothThankYou");

module.exports = function(deployer) {
  deployer.deploy(MothThankYou, {gas: 5000000});
};
