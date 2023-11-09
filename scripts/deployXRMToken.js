const ethers = require("hardhat").ethers;

async function main() {

  const totalSupply = ethers.utils.parseUnits('10000000', 6)
  // console.log('totalSupply:', totalSupply);
  
  const XRMToken = await ethers.getContractFactory('XRMToken');

  const xrm = await XRMToken.deploy("xiaruoming", "XRM", totalSupply);
  await xrm.deployed();

  console.log(`new World Cup Token deployed to ${xrm.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
