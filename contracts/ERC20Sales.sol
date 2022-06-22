//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract ERC20Sales is Ownable, Pausable, ReentrancyGuard{

    using SafeMath for uint256;

    

    uint32 public startBlockTimestamp;
    uint32 public endBlockTimestamp;
    uint256 public softCap;
    uint256 public hardCap;
    uint256 public offeringSize;
    uint256 public totalRaised;
    address public offeringToken;
    address public factory;

    mapping(address => uint256) public accounts;

    

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @return Documents the return variables of a contract’s function state variable
    event Claim (uint256 amount, address account);
    event Finished(uint256 endBlock);
    event Frozen(uint256 currentBlock);
    event Invest (uint256 amount, address account);

    constructor(
        uint32 _startBlock,
        uint32 _endBlock,
        uint256 _softCap,
        uint256 _hardCap,
        uint256 _offeringSize,
        uint256 _totalRaised,
        address _offeringToken
        ){

            startBlockTimestamp = _startBlock;
            endBlockTimestamp = _endBlock;
            softCap = _softCap;
            hardCap = _hardCap;
            offeringSize = _offeringSize;
            totalRaised = _totalRaised;
            offeringToken = _offeringToken;
            factory = msg.sender;

        }

    function invest() external payable nonReentrant whenNotPaused{
        require (msg.value > 10**16 wei, "Invested amount is too low!");
        require (block.timestamp < endBlockTimestamp, "Sale is already over!");

         /*not needed to do SAFEMATH OPERATIONS ON SOLIDITY 0.8+.

        accounts[msg.sender] = accounts[msg.sender] + amount;

        Hardhat threw an overflow error anyway.
        Gotta import SafeMath

        */

        accounts[msg.sender] = accounts[msg.sender].add(msg.value);
        totalRaised = totalRaised.add(msg.value);


        emit Invest(msg.value, msg.sender);


    }



        

        
    

    


}


