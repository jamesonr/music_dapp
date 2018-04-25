var Migrations = artifacts.require("./Migrations.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations, { gas: 4700000, //may be 21000 - 3000000
gasPrice: 20000000000});
};
