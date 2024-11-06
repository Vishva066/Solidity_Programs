// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract TokenSale{
    IERC20 token;
    IERC20Metadata tokendetails;

    uint public  tokenPriceInWei = 0.01 ether;

    constructor(address _token) {
        token = IERC20(_token);
        tokendetails = IERC20Metadata(_token);
    }

    function buy() public payable {
        require(msg.value >= tokenPriceInWei, "Not enough money sent");
        uint tokensToTransfer = msg.value / tokenPriceInWei;
        uint remainder = msg.value - tokensToTransfer * tokenPriceInWei;
        token.transfer(msg.sender, tokensToTransfer * 10 ** tokendetails.decimals());
        if (remainder > 0) {
            payable(msg.sender).transfer(remainder);
        }
    }
}