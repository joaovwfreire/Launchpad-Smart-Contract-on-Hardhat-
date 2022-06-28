# Test Driven Development on Hardhat

This repo intends to go in-depth on the thought process behind TDD with Hardhat for Solidity Smart Contracts.
This is also a personal progress diary.
By reading it, you will have contact with begginer, intermediate and advanced concepts. 
I highly encourage other users to commit to this repo. Be it extra features, corrections or even better phrasing. 

# Launchpad - The Smart Contract

After someconsideration, I've figured a launchpad is a comprehensive Solidity smart contract in terms of concepts needed to understand. If done right, it should include the usage of good design patterns, oracles and factory contracts to say the least.
A launchpad is platform in which the end-user can purchase initial offerings. 
In the ERC-20 offering there is a minimum amount of sales (soft cap). The smart contract will receive ETH as payment and upon a manual transaction , the sale will be finished and users will be able to claim their tokens. In the ERC721 and ERC-1155 launchpads, however, users will be able to claim their assets immediately after purchasing. The ERC721 will utilize the Merkle tree data structure to host both Whitelisted and non-whitelisted sales.
The ERC-1155 launchpad will have two modes: a normal drop and a dutch auction. It will utilize an Oracle to host sales directly in USDC.

# ERC-20 Sales Structure

Libraries:
    SafeMath32 - not needed for Solidity ^0.8.0
    SafeMath - not needed for Solidity ^0.8.0

Modifiers:
    ERC20
    Ownable
    ReentrancyGuard


Storage variables:
    uint32 startBlockTimestamp
    uint32 endBlockTimestamp - period from which users will not be able to purchase anymore
    uint256 Soft Cap - minimum amount of eth
    uint256 Hard Cap - maximum amount of eth
    uint256 OfferingSize
    uint256 Total raised amount
    IRC20 Offering address - token sold;
    address factory
    Stages stage;

Storage mappings:
    (address => uint256) user address => tokens amount - will help monitor the size of one's investment
    

Storage arrays:

Events:
    Claim
    Invest
    StateChange

Constructor:
    Receives all the storage variables as arguments but the owner, which should be the msg.sender (in our case, the factory contract).    

Functions:
    external
        claim       atStage(Stage.Claim) 
        finishsale  atStage(Stage.Open)
        invest      atStage(Stage.Open) payable

    public
        getUserShares - view returns(uint256)
        
        
    internal
        nextStage();
    private


Fallback: None so users are not allowed to send us ether without specific details

# ERC-721 Sales Structure

Storage variables:
Storage mappings:
Storage arrays:
Constructor:
Functions:
Fallback:

# ERC-1155 Sales Structure

Storage variables:
Storage mappings:
Storage arrays:
Constructor:
Functions:
Fallback:

