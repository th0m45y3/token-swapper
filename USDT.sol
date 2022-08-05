// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDT is ERC20 {
    uint maxSupply;

    constructor(uint maxSupply_) payable ERC20("Tether", "USDT") {
        maxSupply = maxSupply_;
    }

    function mint(uint amount_) public {
        super._mint(msg.sender, amount_);
    }

}