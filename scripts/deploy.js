const fs = require('fs');
const hre = require('hardhat');
const ethers = hre.ethers;

async function main() {
    // Loading accounts
    const accounts = await ethers.getSigners();

    console.log('=====================================================================================');
    console.log('ACCOUNTS:');
    console.log('=====================================================================================');
    for (let i = 0; i < accounts.length; i++) {
        const account = accounts[i];
        console.log(` Account ${i}: ${account.address}`);
    }

    // Loading contract factory
    const TokenNMT = await ethers.getContractFactory('Nanomix');
    const TokenNET = await ethers.getContractFactory('Nanoearn');
    const Random = await ethers.getContractFactory('Random');
    const Firepit = await ethers.getContractFactory('Firepit');
    const Sneaker = await ethers.getContractFactory('Sneaker');
    const Playlist = await ethers.getContractFactory('Playlist');
    const Bike = await ethers.getContractFactory('Bike');
    const Box = await ethers.getContractFactory("Box");
    const OpenBoxFactory = await ethers.getContractFactory("OpenBoxFactory");
    const Marketplace = await ethers.getContractFactory('Marketplace');
    const ERC20Withdraw = await ethers.getContractFactory("ERC20Withdraw");

    const [deployer] = await ethers.getSigners();

    console.log('=====================================================================================');
    console.log(`DEPLOYED CONTRACT ADDRESS TO:  ${hre.network.name}`);
    console.log('=====================================================================================');

    const tokenNET = await TokenNET.deploy();
    await tokenNET.deployed();
    console.log(' TokenNET         deployed to:', tokenNET.address);


    const random = await Random.deploy();
    await random.deployed();
    console.log(' Random         deployed to:', random.address);


    const firepit = await Firepit.deploy();
    await firepit.deployed();
    console.log(' Firepit         deployed to:', firepit.address);

    const tokenNMT = await TokenNMT.deploy(tokenNET.address, firepit.address, random.address);
    await tokenNMT.deployed();
    console.log(' TokenNMT         deployed to:', tokenNMT.address);
    

    const sneakerNFT = await Sneaker.deploy();
    await sneakerNFT.deployed();
    console.log(' sneakerNFT         deployed to:', sneakerNFT.address);


    const bikeNFT = await Bike.deploy();
    await bikeNFT.deployed();
    console.log(' bikeNFT         deployed to:', bikeNFT.address);


    const playlistNFT = await Playlist.deploy();
    await playlistNFT.deployed();
    console.log(' playlistNFT         deployed to:', playlistNFT.address);


    const boxNFT = await Box.deploy();
    await boxNFT.deployed();
    console.log(' boxNFT         deployed to:', boxNFT.address);


    const openBoxFactory = await OpenBoxFactory.deploy();
    await openBoxFactory.deployed();
    console.log(' openBoxFactory         deployed to:', openBoxFactory.address);


    const marketplace = await Marketplace.deploy("50000");
    await marketplace.deployed();
    console.log(' marketplace         deployed to:', marketplace.address);

    const erc20Withdraw = await ERC20Withdraw.deploy();
    await erc20Withdraw.deployed();
    console.log(' erc20Withdraw         deployed to:', erc20Withdraw.address);

    console.log("=============== SETTING FOR CONTRACT ===============");
  
    // export deployed contracts to json (using for front-end)
    const contractAddresses = {
        "TokenNMT": tokenNMT.address,
        "TokenNET": tokenNET.address,
        "Random": random.address,
        "Firepit": firepit.address,
        "SneakerNFT": sneakerNFT.address,
        "BikeNFT": bikeNFT.address,
        "PlaylistNFT":playlistNFT.address,
        "BoxNFT": boxNFT.address,
        "OpenBoxFactory": openBoxFactory.address,
        "Marketplace": marketplace.address,
        "ERC20Withdraw": erc20Withdraw.address
    }
    await fs.writeFileSync("contracts.json", JSON.stringify(contractAddresses));

    let tx = await tokenNET.setVault(tokenNMT.address);
    await tx.wait();
    console.log("set vault to mint or burn token for NMT contract");

    tx = await tokenNET.renounceOwnership();
    await tx.wait();
    console.log("renounce owner to address 0x0");

    tx = await firepit.setToken(tokenNMT.address);
    await tx.wait();
    console.log("set token NMT for Firepit");

    tx = await sneakerNFT.setGenerateSneakerFactoryAddress(openBoxFactory.address);
    await tx.wait();
    console.log("set generator for sneaker NFT");
    
    tx = await bikeNFT.setGenerateBikeFactoryAddress(openBoxFactory.address);
    await tx.wait();
    console.log("set generator for bike NFT");

    tx = await playlistNFT.setGeneratePlaylistFactoryAddress(openBoxFactory.address);
    await tx.wait();
    console.log("set generator for playlist NFT");

    tx = await boxNFT.setupBurnRoleAddress(openBoxFactory.address);
    await tx.wait();
    console.log("set burner for box NFT");

    tx = await openBoxFactory.setSneakerSmartContractAddress(sneakerNFT.address);
    await tx.wait();
    console.log("set sneaker contract address");

    tx = await openBoxFactory.setBikeSmartContractAddress(bikeNFT.address);
    await tx.wait();
    console.log("set sneaker contract address");

    tx = await openBoxFactory.setPlaylistSmartContractAddress(playlistNFT.address);
    await tx.wait();
    console.log("set sneaker contract address");

    tx = await openBoxFactory.setBoxSmartContractAddress(boxNFT.address);
    await tx.wait();
    console.log("set box smart contract address");

    tx = await openBoxFactory.setSignerPublicKey("0xa2a8C537664c6C8Ccf1b5870c3A328E513BE7fe8");
    await tx.wait();
    console.log("set signer for contract box factory");

    //Set Accept token NMT for ERC20Withdraw Contract
    tx = await erc20Withdraw.setAcceptedToken(tokenNMT.address, 0);
    await tx.wait();
    console.log("Set Accepted token NMT for ERC20Withdraw Contract");

    //Set Accept token NET for ERC20Withdraw Contract
    tx = await erc20Withdraw.setAcceptedToken(tokenNET.address, 1);
    await tx.wait();
    console.log("Set Accepted token NET for ERC20Withdraw Contract");

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });