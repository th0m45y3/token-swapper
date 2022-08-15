# token-swapper
The contract [Swapper.sol](https://github.com/th0m45y3/token-swapper/blob/main/Swapper.sol) swaps two tokens between two addresses at the same time. 
Tokens must be approved to the Swapper. The caller must be the owner of token. (contract_1 in swap() function)

The contract verificates token ownnership and aprovness via staticcall, after that swaps tokens via call transfer function.
 
Supports any token, that implements funtions:
 - ownerOf(uint256)
 - getApproved(uint256)
 - transferFrom(address,address,uint256)

or
 - allowance(address,address)
 - transferFrom(address,address,uint256)
 
 Contacts of tokens can NOT implement ERC20 and ERC721 standarts.
 
