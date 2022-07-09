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
    let theContract;
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
    })

    it("Should deploy the sales factory e constructor sets as factory the msg.sender address", async function () {
    
        const SalesFactoryContract = await ethers.getContractFactory("SalesFactory");
        salesFactory = await SalesFactoryContract.deploy();
        await salesFactory.deployed();
        
        expect(await salesFactory.owner()).to.equal(user1.address);


      });

    

    it("Should start a new sale contract", async function () {
        let startBlock = await ethers.provider.getBlock("latest");
        startBlockTimestamp = startBlock.timestamp;
        endBlockTimestamp = startBlockTimestamp + 60 * 60 * 24;

        console.log(await salesFactory.connect(user2).startNewSale(endBlockTimestamp, softCap, hardCap, offeringSize, totalRaised, offeringAddress.address, 1, {value: ethers.utils.parseEther("0.25").toString()},))
       
    
    });
});