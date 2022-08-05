// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

error Unauthorized(address caller);

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private tokenCounter;
    uint8 public maxMintPerWallet;
    uint8 public maxSupply;

    constructor(uint8 maxMintPerWallet_, uint8 maxSupply_) payable ERC721("Non-fungible token", "NFT") {
        require(maxMintPerWallet_ < maxSupply_, "maxSupply must be greater than maxMintPerWallet");
        maxMintPerWallet = maxMintPerWallet_;
        maxSupply = maxSupply_;
    }

    //helper
    function watchCounter() public view returns(uint){
        return(tokenCounter.current());
    }

    //todo: multiple mint
    function mint() 
        public
        returns (uint) 
    {
        require(tokenCounter.current() < maxSupply, "NFT sold out");
        require(balanceOf(msg.sender) < maxMintPerWallet, "Minting maximum reached for wallet");

        uint tokenId_ = tokenCounter.current() + 1; // starting from 1
        super._safeMint(msg.sender, tokenId_);
        string memory tokenURI_ = tokenURI(tokenId_); //todo
        super._setTokenURI(tokenId_, tokenURI_);
        tokenCounter.increment();
        return(tokenId_);
    }

    //useless
    function approval(address to_, uint tokenId_) public {
        if (msg.sender != ownerOf(tokenId_)) revert Unauthorized(msg.sender);
        super.approve(to_, tokenId_);
    }
}