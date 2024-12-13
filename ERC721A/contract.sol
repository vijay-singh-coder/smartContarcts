// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import "https://github.com/exo-digital-labs/ERC721R/blob/main/contracts/ERC721A.sol";
import "https://github.com/exo-digital-labs/ERC721R/blob/main/contracts/IERC721R.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";


contract Web3Token is  ERC721A, Ownable {

  using Address for address;

    uint256 public constant mintPrice = 1 ether;
    uint256 public constant maxMintPerUser = 5;
    uint256 public constant maxMintSupply = 100;

    uint256 public constant refundPeriod = 3 minutes;
    address public refundAddress;

    string private baseTokenURI;

    mapping(uint256 => uint256) public refundEndTimestamps;
    mapping(uint256 => bool) public hasRefunded;

    constructor() ERC721A("Web3Token", "W3T") Ownable(msg.sender) {
        refundAddress = address(this);
        baseTokenURI = "ipfs://QmbseRTJWSsLfhsiWwuB2R7EtN93TxfoaMz1S5FXtsFEUB/";
    }

    function _baseURI() internal view override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory uri) external onlyOwner {
        baseTokenURI = uri;
    }

    function safeMint(uint256 quantity) public payable {
        require(msg.value >= quantity * mintPrice, "Not enough funds");
        require(_numberMinted(msg.sender) + quantity <= maxMintPerUser, "Mint Limit");
        require(totalSupply() + quantity <= maxMintSupply, "SOLD OUT");

        _safeMint(msg.sender, quantity);
        uint256 refundEndTimestamp = block.timestamp + refundPeriod;

        for (uint256 i = _currentIndex - quantity; i < _currentIndex; i++) {
            refundEndTimestamps[i] = refundEndTimestamp;
        }
    }

    function refund(uint256 tokenId) external {
        require(block.timestamp < getRefundDeadline(tokenId), "Refund Period Expired");
        require(msg.sender == ownerOf(tokenId), "Not your NFT");
        require(address(this).balance >= mintPrice, "Insufficient contract balance for refund");

        hasRefunded[tokenId] = true;
        _transfer(msg.sender, refundAddress, tokenId);
        Address.sendValue(payable(msg.sender), mintPrice);
    }

    function getRefundDeadline(uint256 tokenId) public view returns (uint256) {
        if (hasRefunded[tokenId]) {
            return 0;
        }
        return refundEndTimestamps[tokenId];
    }

    function withdraw() external onlyOwner {
        require(block.timestamp > block.timestamp + refundPeriod, "Refund period not over");
        Address.sendValue(payable(msg.sender), address(this).balance);
    }

}