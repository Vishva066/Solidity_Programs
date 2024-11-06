// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract CustomToken is ERC20, ERC20Burnable{
    constructor() ERC20("CustomToken", "BEE"){
        _mint(msg.sender, 2100000 * 10 ** decimals());
        //premint which sends the tokens to the contract creator
    }
}