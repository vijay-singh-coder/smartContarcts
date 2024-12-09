// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721Pausable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Web3Builders is ERC721, ERC721Enumerable, ERC721Pausable, Ownable {
    uint256 private _nextTokenId;
    uint256 _maxSupply = 1;
    bool public publicMintOpen;
    bool public allowListMintOpen;
    mapping (address => bool) public allowList;

    constructor(address initialOwner)
        ERC721("Web3Builders", "WE3")
        Ownable(initialOwner)
    {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmY5rPqGTN1rZxMQg2ApiSZc7JiBNs1ryDzXPZpQhC1ibm/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // Populate the Allow List
     function allowListCheck(address[] calldata _addresses)external onlyOwner{
        for (uint256 i=0; i<_addresses.length;i++) {
            allowList[_addresses[i]]=true;
        }
    }
   
    function setMintWindow(bool _publicMintOpen , bool _allowListMintOpen )external onlyOwner{
         publicMintOpen = _publicMintOpen;
         allowListMintOpen = _allowListMintOpen;
        
    }

    //make the mint transaction PAYABLE
    function publicMint() public payable  {
        
        require(totalSupply() < _maxSupply,"We sold out");
        require(msg.value == 0.01 ether, "Not enough fund");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
    }

    function allowListMint() public payable  {
        require(allowList[msg.sender],"You are not authorised");
        require(totalSupply() < _maxSupply,"We sold out");
        require(msg.value == 0.001 ether, "Not enough fund");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
    }

    function withdraw(address _addr) external onlyOwner {
        // get the balance of the contract
        uint256 balalnce = address(this).balance;
        payable(_addr).transfer(balalnce);
    }

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
