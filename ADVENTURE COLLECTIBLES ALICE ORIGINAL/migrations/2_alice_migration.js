var AliceInWonderland = artifacts.require("AliceInWonderland");

module.exports = function(deployer) {
    // deployment steps
    deployer.deploy(AliceInWonderland, {gas: 5000000});
};
