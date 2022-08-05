// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";

contract Operator {
    constructor() payable {}

    event TransferComplete(uint tokenId, address buyer, address seller);

    function transferNFT(IERC20 usdt_, IERC721 nft_, uint tokenId_, uint price_, address buyer_) public {
        require(msg.sender == nft_.ownerOf(tokenId_), "Caller must be the owner of NFT");
        require(nft_.getApproved(tokenId_) == address(this), "Token must be approved");
        require(usdt_.allowance(buyer_, address(this)) >= price_, "The price is too hight");

        usdt_.transferFrom(buyer_, msg.sender, price_);
        nft_.transferFrom(msg.sender, buyer_, tokenId_);

        emit TransferComplete(tokenId_, buyer_, msg.sender);
    }
}