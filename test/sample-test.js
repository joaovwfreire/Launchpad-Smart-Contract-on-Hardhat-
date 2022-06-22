const {expect} = require("chai");

const { ethers } = require("hardhat");

describe("ERC20Sales", function () {

  let user1, user2, user3, user4, user5, offeringAddress, factory;
  let startBlockTimestamp;
  let endBlockTimestamp;
  let softCap = ethers.utils.parseEther("50") ;
  let hardCap = ethers.utils.parseEther("500") ;
  let offeringMax = 1000000;
  let totalRaised = 0;
  let theContract;

  beforeEach(async () => {

    [user1, user2, user3, user4, user5, offeringAddress, factory] = await ethers.getSigners();
    let startBlock = await ethers.provider.getBlock("latest");
    startBlockTimestamp = startBlock.timestamp;
    endBlockTimestamp = startBlockTimestamp + 60 * 60 * 24;
    
  })

  

  
  it("Should check the constructor sets as factory the msg.sender address", async function () {

    const ERC20Sales = await ethers.getContractFactory("ERC20Sales");
    const initialOffer = await ERC20Sales.deploy(startBlockTimestamp, endBlockTimestamp, softCap, hardCap, offeringMax, totalRaised, offeringAddress.address);
    await initialOffer.deployed();
    expect(await initialOffer.factory()).to.equal(user1.address);

  });


  it("Should allow one user to invest at the pool", async function () {
    const ERC20Sales = await ethers.getContractFactory("ERC20Sales");
    const initialOffer = await ERC20Sales.deploy(startBlockTimestamp, endBlockTimestamp, softCap, hardCap, offeringMax, totalRaised, offeringAddress.address);
    await initialOffer.deployed();
    await initialOffer.connect(user2).invest({value: ethers.utils.parseEther("0.015") });
    expect(await initialOffer.accounts(user2.address)).to.equal(ethers.utils.parseEther("0.015"));

    await expect(initialOffer.connect(user3).invest({value:ethers.utils.parseEther("0.009")}))
    .to.be.revertedWith("Invested amount is too low!");



  });
        
  } )
