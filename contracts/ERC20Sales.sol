//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract ERC20Sales is Ownable, ReentrancyGuard{

    enum Stages {
        Open,
        Finished,
        Claim
    }

    struct Account {
        uint256 amount;
        bool claimed;
    }

   

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    

    uint32 public startBlockTimestamp;
    uint32 public endBlockTimestamp;
    uint256 public softCap;
    uint256 public hardCap;
    uint256 public offeringSize;
    uint256 public totalRaised;
    IERC20 public offeringToken;
    address public factory;

    mapping(address => Account) public  accounts;

    Stages public stage = Stages.Open;
    

    

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @return Documents the return variables of a contract’s function state variable
    event Claim (uint256 claimamount, uint256 refundamount, address account);
    event Invest (uint256 amount, address account);
    event StateChange(Stages _stage);

    modifier atStage(Stages _stage) {
        require(stage == _stage, "Contract is not at this stage!");
        _;
    }

    modifier timedTransitions() {
        if (stage == Stages.Open && block.timestamp >= endBlockTimestamp) {
            nextStage();
        }
        if (stage == Stages.Finished && block.timestamp >= (endBlockTimestamp + 900)) {
            nextStage();
        }
        _;
    }

    constructor(
        uint32 _startBlock,
        uint32 _endBlock,
        uint256 _softCap,
        uint256 _hardCap,
        uint256 _offeringSize,
        uint256 _totalRaised,
        IERC20 _offeringToken
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

    function invest() external payable nonReentrant timedTransitions atStage(Stages.Open){
        require (msg.value > 10**16 wei, "Invested amount is too low!");
        require (block.timestamp < endBlockTimestamp, "Sale is already over!");

        accounts[msg.sender].amount += msg.value;
        accounts[msg.sender].claimed = false;
        totalRaised += msg.value;


        emit Invest(msg.value, msg.sender);
    }

    function claim(address _account) external nonReentrant timedTransitions atStage(Stages.Claim){
        require(msg.sender == _account, "Cannot claim for someone else");
        
        accounts[_account].claimed = true;
        uint claims = getClaimAmount(_account);
        uint refunds = getRefundsAmount(_account);
        
        
        offeringToken.transfer(msg.sender, claims);
        
        if(refunds > 0){
            _account.call{value: refunds};
        }


        emit Claim(claims, refunds, _account);
    }


    function getUserShares(address _account) public view returns(uint256){
        return ((accounts[_account].amount).mul(10** 8).div(totalRaised) );
    }

    function getUserBalance(address _account) public view returns(Account memory){
        return(accounts[_account]);
    }

    function getClaimAmount(address _account) public view returns(uint256){ 
        
        return(((accounts[_account].amount).mul(offeringSize).div(totalRaised)));
    }

    function getClaimStatus(address _account) public view returns(bool){ 
        
        return accounts[_account].claimed;
    }

    function getRefundsAmount(address _account) public view returns(uint256){
        if (totalRaised > hardCap){

            return ((totalRaised.sub(hardCap)).mul(getUserShares(_account)).div(10 ** 8));
        } else {
            return 0;
        }
    }

    function nextStage() internal {
        stage = Stages(uint(stage) + 1);
    }


}


