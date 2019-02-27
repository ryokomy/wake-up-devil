const TenDaysWakeUpDevil = artifacts.require("./TenDaysWakeUpDevil.sol");

module.exports = function(deployer) {
  deployer.deploy(TenDaysWakeUpDevil);
};
