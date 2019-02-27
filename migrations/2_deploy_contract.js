const RobinHood = artifacts.require("./RobinHood.sol");
const TenDaysWakeUpDevil = artifacts.require("./TenDaysWakeUpDevil.sol");

module.exports = function(deployer) {
  deployer.then(async () => {
    await deployer.deploy(RobinHood);
    await deployer.deploy(TenDaysWakeUpDevil, RobinHood.address);
  })
};
