const tokens = artifacts.require("tokens"); 

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(tokens);
  

};
