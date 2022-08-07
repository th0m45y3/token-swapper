// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract USDT is ERC20 {
    AggregatorV3Interface internal priceFeed;
    using SafeMath for uint256;
    uint8 public centDecimals = 16;
    bool locked;

    modifier noReentrancy() {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }

    constructor() payable ERC20("Tether", "USDT") {
        priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331); // kovan ETH to USD
    }

    function getETHPrice() 
    internal view 
    returns(uint) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        
                                    //sub to get amount in cents
        return uint(price).div(10 ** ( priceFeed.decimals() - 2 ));
    }

    function EthToCents(uint amountInCents) 
    public view 
    returns(uint priceForAmount) { // cent * eth
        uint ethPriceInCents_ = getETHPrice();
        priceForAmount = amountInCents.mul( ethPriceInCents_ );
    }

    function CentsToWei(uint amountInCents) 
    public view 
    returns(uint priceForAmount) { // cent * wei / eth
        priceForAmount = amountInCents.mul( 10 ** decimals() ).div( getETHPrice() );
    }

    function balanceOfInCents(address account) 
    public view 
    returns(uint){
        return balanceOf(account).div ( 10 ** centDecimals );
    }

    function mint(uint amountInCents) 
    public payable noReentrancy {
        require(msg.value >= CentsToWei(amountInCents), "Insufficient value");

        (bool success,) = payable(msg.sender).call{value: msg.value}("");
        require(success, "Failed to send money");
        
        super._mint(msg.sender, amountInCents * (10 ** centDecimals) );
    }

    function approveInCents(address spender, uint amountInCents) 
    public {
        uint amount = amountInCents.mul(10 ** centDecimals);
        super.approve(spender, amount);
    }


    function sell(uint amountInCents) 
    public {
        uint weiAmount = CentsToWei(amountInCents);
        require(balanceOf(msg.sender) > weiAmount, "Insufficient funds");

        payable(msg.sender).transfer(weiAmount);
        super._burn(msg.sender, amountInCents * ( 10 ** centDecimals ));
    }

}