// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract Lockfunds {
    IERC20  token;
    IERC20Metadata  tokendetails;

    uint public tokenPriceInWei = 0.01 ether;
    uint public lockPeriod = 365 days; // Setting the lock period actually unix timestamp

    struct PurchaseInfo {
        uint256 amount;          // Amount of tokens bought
        uint256 releaseTime;     // Time when tokens can be released
    }

    // Mapping of user addresses to their purchase info
    mapping(address => PurchaseInfo) public purchases;

    // Set event to be called after the function is called
    event TokensPurchased(address indexed buyer, uint256 amount, uint256 releaseTime);
    event TokensReleased(address indexed buyer, uint256 amount);

    constructor(address _token) {
        token = IERC20(_token);
        tokendetails = IERC20Metadata(_token);
    }

    function buy() public payable {
        require(msg.value >= tokenPriceInWei, "Not enough money sent");

        // Calculate the number of tokens to transfer and any remainder in ETH
        uint tokensToTransfer = (msg.value / tokenPriceInWei) * (10 ** tokendetails.decimals());
        uint remainder = msg.value % tokenPriceInWei;

        // Update the map
        purchases[msg.sender].amount += tokensToTransfer;
        purchases[msg.sender].releaseTime = block.timestamp + lockPeriod;

        if (remainder > 0) {
            payable(msg.sender).transfer(remainder);
        }
        //Call the event as function is executed
        emit TokensPurchased(msg.sender, tokensToTransfer, purchases[msg.sender].releaseTime);
    }

    function releaseTokens() public {
        //Create an instance of map (purchase)
        PurchaseInfo storage purchase = purchases[msg.sender];
        // Check whether the time has exceeded
        require(block.timestamp >= purchase.releaseTime, "Tokens are still locked");
        //Check whether the there is tokens to be sent to the user
        require(purchase.amount > 0, "No tokens to release");

        uint256 amountToRelease = purchase.amount;

        // Reset user's purchase info before transfer to prevent re-entrancy issues
        purchase.amount = 0;
        purchase.releaseTime = 0;

        // Transfer tokens to the user
        require(token.transfer(msg.sender, amountToRelease), "Token transfer failed");

        emit TokensReleased(msg.sender, amountToRelease);
    }

    //Check the tokens to be received
    function viewPendingTokens() external view returns (uint256) {
        return purchases[msg.sender].amount;
    }

    // Check the time it takes to receive the tokens
    function viewReleaseTime() external view returns (uint256) {
        return purchases[msg.sender].releaseTime;
    }
}
