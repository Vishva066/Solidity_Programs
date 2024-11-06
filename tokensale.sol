// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract TokenSale{
    IERC20 token;
    IERC20Metadata tokendetails;

    uint public  tokenPriceInWei = 0.01 ether; //Setting the token price

    constructor(address _token) {
        token = IERC20(_token); //Calling the previous token contract address
        tokendetails = IERC20Metadata(_token); // Using for accessing the decimals
    }

    function buy() public payable {
        //Check whether funds sent is less than one token
        require(msg.value >= tokenPriceInWei, "Not enough money sent");
        //Checking the token to transfer
        uint tokensToTransfer = msg.value / tokenPriceInWei;
        //Checking any funds left which is not converted to tokens to return back
        uint remainder = msg.value - tokensToTransfer * tokenPriceInWei;
        //Transfering the tokens
        token.transfer(msg.sender, tokensToTransfer * 10 ** tokendetails.decimals());
        //If greater than 0 transfer
        if (remainder > 0) {
            payable(msg.sender).transfer(remainder);
        }
    }
}