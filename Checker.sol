// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/ERC165Checker.sol";

contract Checker {
    //bytes4 public id20 = 0x36372b07;
    //bytes4 public id721 = 0x80ac58cd; // works

    function checkType(address token) public view returns(uint8 tokenType) {
        if (ERC165Checker.supportsInterface(token, type(IERC20).interfaceId)) tokenType = 20;
        else if (ERC165Checker.supportsInterface(token, type(IERC721).interfaceId)) tokenType = 72;
        else tokenType = 0;
    }
}