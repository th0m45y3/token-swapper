// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

error NotEnoughAllowance(uint price_);

contract Operator {
    using SafeMath for uint256;

    IERC20 usdt;
    IERC721 nft;
    uint8 public centDecimals = 16;

    constructor(address usdtContractAddress, address nftContractAddress) payable {
        usdt = IERC20(usdtContractAddress);
        nft = IERC721(nftContractAddress);
    }

    event TransferComplete(uint tokenId, address buyer, address seller);
    
    function transferNFT(uint tokenId_, uint priceInCents_, address buyer_) public {
        require(msg.sender == nft.ownerOf(tokenId_), "Caller must be the owner of NFT");
        require(nft.getApproved(tokenId_) == address(this), "Token must be approved");

        uint price = priceInCents_.mul( 10 ** centDecimals);
        require(usdt.allowance(buyer_, address(this)) >= price, "The price is too hight");

        usdt.transferFrom(buyer_, msg.sender, price);
        nft.transferFrom(msg.sender, buyer_, tokenId_);

        emit TransferComplete(tokenId_, buyer_, msg.sender);
    }
}