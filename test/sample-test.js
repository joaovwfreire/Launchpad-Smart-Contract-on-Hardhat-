
const {expect} = require("chai");
const { parseEther } = require("ethers/lib/utils");

const { ethers } = require("hardhat");

describe("ERC20Sales", function () {

  let user1, user2, user3, user4, user5, offeringAddress, factory;
  let startBlockTimestamp;
  let endBlockTimestamp;
  let softCap = ethers.utils.parseEther("5") ;
  let hardCap = ethers.utils.parseEther("50") ;
  let offeringSize = 1000000;
  let totalRaised = 0;
  let theContract;
  let initialOffer;
  let TokenToTest;
  
  before(async () => {
    [user1, user2, user3, user4, user5, user6, factory] = await ethers.getSigners();
    let startBlock = await ethers.provider.getBlock("latest");
    startBlockTimestamp = startBlock.timestamp;
    endBlockTimestamp = startBlockTimestamp + 60 * 60 * 24;
    TokenToTest = await ethers.getContractFactory("TTTToken");
    let offeringAddress = await TokenToTest.deploy(100000000);
    
    const ERC20Sales = await ethers.getContractFactory("ERC20Sales");
    initialOffer = await ERC20Sales.deploy(startBlockTimestamp, endBlockTimestamp, softCap, hardCap, offeringSize, totalRaised, offeringAddress.address);
    await initialOffer.deployed();

    
    
    
    await offeringAddress.transfer(initialOffer.address, offeringSize);
    let a = await offeringAddress.balanceOf(offeringAddress.address);
    let b = await offeringAddress.balanceOf(initialOffer.address);
    console.log(a, b);

  })


  beforeEach(async () => {

  })
  

  
  it("Should check the constructor sets as factory the msg.sender address", async function () {
    
    expect(await initialOffer.factory()).to.equal(user1.address);
  });


  it("Should allow one user to invest at the pool", async function () {
    
    let investmentAmount = ethers.utils.parseEther("1").toString();
    let arg = {value: investmentAmount};
    await initialOffer.connect(user2).invest(arg);
    let userBalance = await initialOffer.getUserBalance(user2.address);
    expect(userBalance.amount).to.equal(ethers.utils.parseEther("1").toString());

  });

  it("Should revert if the investment amount is too low", async function () {
    
    let failInvestmentAmount = ethers.utils.parseEther("0.009");
    await expect(initialOffer.connect(user3).invest({value: failInvestmentAmount.toString()}))
    .to.be.revertedWith("Invested amount is too low!");

  });
  
  it("Should return the correct total investment, user shares and claim amount", async function () {
    await initialOffer.connect(user4).invest({value: ethers.utils.parseEther("4").toString()})
    
    let totalRaised = await initialOffer.totalRaised();
    expect(totalRaised).to.equal(ethers.utils.parseEther("5"));

    let user2Shares = await initialOffer.getUserShares(user2.address);
    expect(user2Shares).to.equal(20000000);
    let user4Shares = await initialOffer.getUserShares(user4.address);
    expect(user4Shares).to.equal(80000000);

    let user2Claim = await initialOffer.getClaimAmount(user2.address);
    expect(user2Claim).to.equal(user2Shares * offeringSize / (10 ** 8));
    let user4Claim = await initialOffer.getClaimAmount(user4.address);
    expect(user4Claim).to.equal(800000);

  });

  it("Should revert if the user tries to claim too early", async function () {
    
  
    await expect(initialOffer.connect(user2).claim(user2.address))
    .to.be.revertedWith("Contract is not at this stage!");

  });

  it("Should not allow an user to invest after the sales period is over", async function () {
    await network.provider.send("evm_increaseTime", [3600 * 23 + 3590])
    await initialOffer.connect(user5).invest({value: ethers.utils.parseEther("2").toString()});
    
    let user5Balance = await initialOffer.getUserBalance(user5.address);
    expect(user5Balance.amount).to.equal(ethers.utils.parseEther("2").toString());

    await network.provider.send("evm_increaseTime", [10])
    
    await expect(initialOffer.connect(user5).invest({value: ethers.utils.parseEther("2").toString()}))
    .to.be.revertedWith("Contract is not at this stage!");
    

  });

  it("Should allow an user to claim 900 seconds after the sales finish", async function () {
    
    

    await network.provider.send("evm_increaseTime", [900]);

    await initialOffer.connect(user5).claim(user5.address);
    let user5Balance = await initialOffer.getUserBalance(user5.address);
    expect(user5Balance.claimed).to.equal(true);
    
    await expect(initialOffer.connect(user6).claim(user5.address))
    .to.be.revertedWith("Cannot claim for someone else");
    

  });


  } )
