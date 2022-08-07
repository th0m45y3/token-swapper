// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract NFT is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private tokenCounter;
    uint public maxMintPerWallet;
    uint public maxSupply;
    uint8 public centDecimals = 16;

    constructor(uint maxmint, uint maxsupply) payable ERC721("Non-fungible token", "NFT") {
        require(maxmint < maxsupply, "maxSupply must be greater than maxMintPerWallet");
        maxMintPerWallet = maxmint;
        maxSupply = maxsupply;
    }

    function mint(uint NFTamount) 
    public {
        require(tokenCounter.current() + NFTamount < maxSupply, "NFT sold out or amount exceeds the limit");
        require(balanceOf(msg.sender) < maxMintPerWallet, "Minting maximum reached for wallet");

        for(uint i = 0; i < NFTamount; i++) { 
            uint tokenId_ = tokenCounter.current() + 1; // starting from 1
            super._safeMint(msg.sender, tokenId_);
            tokenCounter.increment();
        }
    }
}