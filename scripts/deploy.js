const {ethers} = require("hardhat");
const {CRYPTO_DEVS_NFT_CONTRACT_ADDRESS} = require("../constants");


async function main()
{
  const FakeNFTMarketplace = await ethers.getContractFactory("FakeNFTMarketplace");

  const fakeNftMarketplacedeployed = await FakeNFTMarketplace.deploy();
  fakeNftMarketplacedeployed.deployed();

  console.log("FakeNFtMarketplace contract deployed at address: ", fakeNftMarketplacedeployed.address);


  const CryptoDevsDAO = await ethers.getContractFactory("CryptoDevsDAO");
  const cryptoDevsDAOdeployed = await CryptoDevsDAO.deploy(
    fakeNftMarketplacedeployed.address,CRYPTO_DEVS_NFT_CONTRACT_ADDRESS,
    {
      value: ethers.utils.parseEther("0"),
    }
  );
  
  await cryptoDevsDAOdeployed.deployed();

  console.log("CryptoDevsDAO deployed at :", cryptoDevsDAOdeployed.address);
}

main()
.then(() => process.exit(0))
.catch((error) =>
{
  console.error(error);
  process.exit(1);
});
