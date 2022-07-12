const {expect} = require("chai");
const { parseEther } = require("ethers/lib/utils");

const { ethers } = require("hardhat");


describe("SalesFactory", function () {

    
    
    let user1, user2, user3, factory;
    let startBlockTimestamp;
    let endBlockTimestamp;
    let softCap = ethers.utils.parseEther("5") ;
    let hardCap = ethers.utils.parseEther("50") ;
    let offeringSize = 1000000;
    let totalRaised = 10319300;
    let theSalesContract;
    let saleAddress;
    let salesFactory;
    let offeringAddress;
    let TokenToTest;


    before(async() => {
        [user1, user2, user3, user4, user5, user6, factory] = await ethers.getSigners();
        let startBlock = await ethers.provider.getBlock("latest");
        startBlockTimestamp = startBlock.timestamp;
        endBlockTimestamp = startBlockTimestamp + 60 * 60 * 24;
        TokenToTest = await ethers.getContractFactory("TTTToken");
        offeringAddress = await TokenToTest.deploy(100000000);
        const SalesFactoryContract = await ethers.getContractFactory("SalesFactory");
        salesFactory = await SalesFactoryContract.deploy();
        await salesFactory.deployed();
    })

    it("Should deploy the sales factory e constructor sets as factory the msg.sender address", async function () {
    
        
        expect(await salesFactory.owner()).to.equal(user1.address);


      });

    

    it("Should start a new sale contract", async function () {
        let startBlock = await ethers.provider.getBlock("latest");
        startBlockTimestamp = startBlock.timestamp;
        endBlockTimestamp = startBlockTimestamp + 60 * 60 * 24;
        
        
        /*
        await expect(salesFactory.connect(user2).startNewSale(endBlockTimestamp, softCap, hardCap, offeringSize, totalRaised, offeringAddress.address, 1, {value: ethers.utils.parseEther("0.25").toString()},))
        .to.emit(salesFactory, "SaleCreated")
        .withArgs(user2.address, "0x856e4424f806D16E8CBC702B3c0F2ede5468eae5", endBlockTimestamp, ethers.utils.parseEther("0.25"), true );
        */

        const tx = await salesFactory.connect(user2).startNewSale(endBlockTimestamp, softCap, hardCap, offeringSize, totalRaised, offeringAddress.address, 1, {value: ethers.utils.parseEther("0.25").toString()},)
        const receipt = await tx.wait()

        let i = 0;
        for (const event of receipt.events) {
            if (i == 1){
                saleAddress = event.args[1];
                let saleOwner = (await salesFactory.sales(saleAddress))[1]
                expect(saleOwner)
                .to.equal(user2.address)
            }
            i++
        }
        
    
    });

    it("Should allow one user to invest at the pool", async function () {
        let User2ERC20Sales = await ethers.getContractFactory("ERC20Sales");
        theSalesContract = await User2ERC20Sales.attach(saleAddress);
        let investmentAmount = ethers.utils.parseEther("1").toString();
        let arg = {value: investmentAmount};
        await theSalesContract.connect(user3).invest(arg);
        let userBalance = await theSalesContract.getUserBalance(user3.address);
        expect(userBalance.amount).to.equal(ethers.utils.parseEther("1").toString());
    
      });
});