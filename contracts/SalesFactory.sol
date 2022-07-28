//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./ERC20Sales.sol";
import "./ERC721Sales.sol";
import "./ERC1155TokenSales.sol";


contract SalesFactory is Ownable, ReentrancyGuard {

   

    struct Sale {
        uint256 saleFinish;
        address projectOwner;
    }

    using SafeMath for uint256;


    uint256 public newSaleFee;
    uint256 public forwardPaymentDiscount;
    uint256 public feesReceived;
    bool    public isFrozen;

    mapping(address => Sale) public sales;

    ERC20Sales[] public salesOpen20;
    ERC20Sales[] private salesFinished20;
    


    event SaleCreated(address projectOwner, address salesContract, uint256 deadline, uint256 feePayed, bool payedForward);
    event WithdrawFees(uint256 amount);


    constructor(){
       
        newSaleFee = 5;
        forwardPaymentDiscount = 20;
        feesReceived = 0;
        isFrozen = false;

    }

    function withdrawFees() external onlyOwner {
        (msg.sender).call{value: feesReceived};
        feesReceived = 0;
    }

    function startNewErc20Sale(uint256 salesEnd, uint256 _softCap, uint256 _hardCap, uint256 _offeringSize, uint256 _totalRaised, IERC20 _offeringToken) external payable {
        
        if(msg.value != 0){
        require(msg.value == _softCap.div(100).mul(newSaleFee), "Incorrect payment!");
        
        
        
            ERC20Sales sale20 = new ERC20Sales(uint32(block.timestamp), uint32(salesEnd), _softCap, _hardCap, _offeringSize, _totalRaised, _offeringToken);
            salesOpen20.push(sale20);
            sales[address(sale20)].saleFinish = salesEnd;
            sales[address(sale20)].projectOwner = msg.sender;

            emit SaleCreated(msg.sender, address(sale20), salesEnd, msg.value, true);

        }
        
    }

/*
    function start1155Sale(string memory _contractName, string memory _uri, string[] memory _names, uint[] memory _ids, uint[] memory _mintFees) external payable{

            
            ERC1155TokenSales sale1155 = new ERC1155TokenSales(_contractName,_uri, _names, _ids, _mintFees);
            salesOpen1155.push(sale1155);
            sales[address(sale1155)].projectOwner = msg.sender;



    }
*/
    function changeFees(uint256 newFees) external onlyOwner{
        newSaleFee = newFees;
    }

 
}