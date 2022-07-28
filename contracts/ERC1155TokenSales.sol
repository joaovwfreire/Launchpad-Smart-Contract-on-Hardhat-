//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";



contract ERC1155TokenSales is ERC1155, Ownable, ReentrancyGuard {

    
    string public baseMetadataURI; //the token metadata URI
    string public name; //the token name
    string[] public names; //string array of names
    uint[] public ids; //uint array of ids
    uint[] public mintFees; //mintfees
    address public projectOwner;
    address public usdc;
    uint256 public collectedFees;
    

    mapping(string => uint) public nameToId; //name to id mapping
    mapping(uint => string) public idToName; //id to name mapping

    event Mint(uint id, uint amount, address owner);
    event BatchMint(uint[] ids, uint[] amounts, address owner);
    /*
    constructor is executed when the factory contract calls its own deployERC1155 method
    */
    constructor(string memory _contractName, string memory _uri, string[] memory _names, uint[] memory _ids, uint[] memory _mintFees, address _usdcAddress) ERC1155(_uri) {
        names = _names;
        ids = _ids;
        createMapping(); 
        setURI(_uri);
        baseMetadataURI = _uri;
        name = _contractName;
        mintFees = _mintFees;
        usdc = _usdcAddress;
        transferOwnership(msg.sender);
    }   

    /*
    creates a mapping of strings to ids (i.e ["one","two"], [1,2] - "one" maps to 1, vice versa.)
    */
    function createMapping() private {
        /* rewrote for gas fees optimizations.
        here ids.length is being accessed every loop iteration, which is much more expensive than accessing
        a variable defined at this function's scope.
        for (uint id = 0; id < ids.length; id++) {
            nameToId[names[id]] = ids[id];
            idToName[ids[id]] = names[id];
        }
        */
        uint idsLength = ids.length;
        for (uint id = 0; id < idsLength; id++) {
            nameToId[names[id]] = ids[id];
            idToName[ids[id]] = names[id];
        }



    }
    /*
    sets our URI and makes the ERC1155 OpenSea compatible
    */
    function uri(uint256 _tokenid) override public view returns (string memory) {
        return string(
            abi.encodePacked(
                baseMetadataURI,
                Strings.toString(_tokenid),".json"
            )
        );
    }

    function getNames() public view returns(string[] memory) {
        return names;
    }

    /*
    used to change metadata, only owner access
    */
    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    /*
    set a mint fee. only used for mint, not batch.
    */
    function setFee(uint[] calldata _fees) public onlyOwner {
        mintFees = _fees;
    }

    /*
    mint(address account, uint _id, uint256 amount)

    account - address to mint the token to
    _id - the ID being minted
    amount - amount of tokens to mint
    */
    function mint(address account, uint _id, uint256 amount) 
        public payable returns (uint)
    {

        uint pricePerToken = mintFees[_id - 1];
        require(msg.value == pricePerToken * amount, "Wrong amount sent!");
        _mint(account, _id, amount, "");
        emit Mint(_id, amount, account);
        return _id;
    }

    /*
    mintBatch(address to, uint256[] memory _ids, uint256[] memory amounts, bytes memory data)

    to - address to mint the token to
    _ids - the IDs being minted
    amounts - amount of tokens to mint given ID
    bytes - additional field to pass data to function
    */
    function mintBatch(address to, uint256[] memory _ids, uint256[] memory amounts, bytes memory data)
        public payable nonReentrant
    {
        uint[] memory availableIds = ids;
        uint[] memory availableMintFees = mintFees;
        uint idsArrayLength = availableIds.length;
        uint totalCost;

        for(uint8 i = 0; i< _ids.length; i++){
            require(i < availableIds[idsArrayLength -1], "Wrong input");
                // _ids[i] -1 is the index I need to access at availableMintFees and amounts in order to figure out the total cost
                 totalCost += (amounts[_ids[i] -1]) * (availableMintFees[_ids[i] -1]);
        }
        require(msg.value == totalCost, "Wrong amount sent!");

        _mintBatch(to, _ids, amounts, data);
        emit BatchMint(_ids, amounts, to);

        
    }
}
