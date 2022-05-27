const hre = require('hardhat');
const contract = require('../contracts.json');

/// Discription : Verification source script
/// Prerequisite: Adding VERIFY_KEY value in `.env` file
/// How to use  : Run below command
///               cmd$> npx hardhat run scripts/verify.js --network <your-network>

async function main() {
  const VERIFY_KEY = process.env.VERIFY_KEY;
  
  console.log('=====================================================================================');
  console.log('VERIFY_KEY:', VERIFY_KEY);
  console.log('=====================================================================================');

  console.log('Verify TokenNMT');
  try {
    await hre.run("verify:verify", {
      address: contract.TokenNMT,
      constructorArguments: [contract.TokenNET, contract.Firepit, contract.Random],
      contract: "contracts/Nanomix.sol:Nanomix"
    });
  } catch (e) {
    console.log(e.message);
  }

  console.log('Verify TokenNET');
  try {
    await hre.run("verify:verify", {
      address: contract.TokenNET,
      constructorArguments: [],
      contract: "contracts/Nanoearn.sol:Nanoearn"
    });
  } catch (e) {
    console.log(e.message);
  }

  console.log('Verify FirePit');
  try {
    await hre.run("verify:verify", {
      address: contract.Firepit,
      constructorArguments: [],
      contract: "contracts/firepit.sol:FirePit"
    });
  } catch (e) {
    console.log(e.message);
  }

  console.log('Verify SneakerNFT');
  try {
    await hre.run("verify:verify", {
      address: contract.SneakerNFT,
      constructorArguments: [],
      contract: "contracts/NanoSneaker.sol:Sneaker"
    });
  } catch (e) {
    console.log(e.message);
  }

  console.log('Verify BikeNFT');
  try {
    await hre.run("verify:verify", {
      address: contract.BikeNFT,
      constructorArguments: [],
      contract: "contracts/NanoBike.sol:Bike"
    });
  } catch (e) {
    console.log(e.message);
  }

  console.log('Verify PlaylistNFT');
  try {
    await hre.run("verify:verify", {
      address: contract.PlaylistNFT,
      constructorArguments: [],
      contract: "contracts/NanoPlaylist.sol:Playlist"
    });
  } catch (e) {
    console.log(e.message);
  }

  console.log('Verify BoxNFT');
  try {
    await hre.run("verify:verify", {
      address: contract.BoxNFT,
      constructorArguments: [],
      contract: "contracts/NanoBox.sol:Box"
    });
  } catch (e) {
    console.log(e.message);
  }

  console.log('Verify OpenBoxFactory');
  try {
    await hre.run("verify:verify", {
      address: contract.OpenBoxFactory,
      constructorArguments: [],
      contract: "contracts/OpenBoxFactory.sol:OpenBoxFactory"
    });
  } catch (e) {
    console.log(e.message);
  }

  console.log('Verify Marketplace');
  try {
    await hre.run("verify:verify", {
      address: contract.Marketplace,
      constructorArguments: ["50000"],
      contract: "contracts/Marketplace.sol:Marketplace"
    });
  } catch (e) {
    console.log(e.message);
  }

  console.log('Verify ERC20Withdraw');
  try {
    await hre.run("verify:verify", {
      address: contract.ERC20Withdraw,
      constructorArguments: [],
      contract: "contracts/ERC20Withdraw.sol:ERC20Withdraw"
    });
  } catch (e) {
    console.log(e.message);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });