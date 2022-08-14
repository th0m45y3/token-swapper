// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

contract Swapper {
    bool private lock = false;

    modifier nonReentrant {
        lock = true;
        _;
        lock = false;
    }

    event Transfer(address contract_1, address contract_2,
                   address indexed user_1, address indexed user_2,
                   uint number_1, uint number_2);


    function tryOwnerOf(address externalContract, uint tokenId) 
    private view
    returns(bool, address) {

        (bool success, bytes memory returnedData) = externalContract.staticcall (
            abi.encodeWithSignature("ownerOf(uint256)", tokenId)
        );

        address addr;
        if (success) addr = abi.decode(returnedData, (address));

        return(success, addr);
    }


    function tryGetApproved(address externalContract, uint tokenId) 
    private view
    returns(bool, address) {

        (bool success, bytes memory returnedData) = externalContract.staticcall (
            abi.encodeWithSignature("getApproved(uint256)", tokenId)
        );
        
        address addr;
        if (success) addr = abi.decode(returnedData, (address));

        return(success, addr);
    }


    function tryAllowance(address externalContract, address owner, address spender) 
    private view
    returns(bool, uint) {

        (bool success, bytes memory returnedData) = externalContract.staticcall(
            abi.encodeWithSignature("allowance(address,address)", owner, spender)
        );

        uint data;
        if (success) data = abi.decode(returnedData, (uint));
        
        return(success, data);
    }


    //number - tokenId or amount
    function tryTransferFrom(address externalContract, address from, address to, uint number) 
    private
    returns(bool) {

        (bool success, ) = externalContract.call{value: 0}(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, number)
        );
        return(success);
    }


    /*
      @dev 
        Swaps tokens of contract_1 and contract_2 between msg.sender and user_2.
        Each contract must support one of two groups of functions:

            [ownerOf(uint256), 
             getApproved(uint256), 
             transferFrom(address,address,uint256)] (ERC721)
            
            OR

            [allowance(address,address), 
             transferFrom(address,address,uint256)] (ERC20)

        Contracts can NOT implement ERC721 and ERC20 standarts.
        
        Requirements:
         - msg.sender must approve token(s) of contract_1 to this contract
         - user_2 must approve token(s) of contract_2 to this contract
     
      @param 
        contract_1 - contract address of token(s) that holds msg.sender
        contract_2 - contract address of token(s) that holds user_2
        [user1 - address of msg.sender]
        user2 - address of the second user
        number_1 - amount of tokens or tokenId that holds msg.sender
        number_2 - amount of tokens or tokenId that holds user_2

    */
    function swap(address contract_1, address contract_2, 
                  address user_2, 
                  uint number_1, uint number_2)
    public nonReentrant {

        (bool success, address owner) = tryOwnerOf(contract_1, number_1);

        if (success) { // suppose contract_1 is ERC721
            require(owner == msg.sender, "contract 1: Caller must be the owner of token");

            (bool subsuccess, address operator) = tryGetApproved(contract_1, number_1);
            require(subsuccess, "contract 1: Failed to call getApprove()");
            require(operator == address(this), "contract 1: Token must be approved");

        } else { // suppose contract_1 is ERC20
            (bool subsuccess, uint amount) = tryAllowance(contract_1, msg.sender, address(this));
            require(subsuccess, "contract 1: Contract is not supported");
            require(amount >= number_1, "contract 1: Insufficient allowance");
        }

        //repeat for contract_2
        (success, owner) = tryOwnerOf(contract_2, number_2);

        if (success) { // suppose contract_2 is ERC721
            require(owner == user_2, "contract 2: User_2 must be the owner of token");

            (bool subsuccess, address operator) = tryGetApproved(contract_2, number_2);
            require(subsuccess, "contract 2: Failed to call getApprove()");
            require(operator == address(this), "contract 2: Token must be approved");

        } else { // suppose contract_2 is ERC20
            (bool subsuccess, uint amount) = tryAllowance(contract_2, user_2, address(this));
            require(subsuccess, "contract 2: Contract is not supported");
            require(amount >= number_2, "contract 2: Insufficient allowance");
        }
        
        //transfer
        (success) = tryTransferFrom(contract_1, msg.sender, user_2, number_1);
        require(success, "contract 1: Failed to call transfer()");

        (success) = tryTransferFrom(contract_2, user_2, msg.sender, number_2);
        require(success, "contract 2: Failed to call transfer()");

        emit Transfer(contract_1, contract_2,
                      msg.sender, user_2,
                      number_1, number_2);
    }
}