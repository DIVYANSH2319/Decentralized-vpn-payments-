// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedVPNPayment {
    address public owner;
    uint256 public vpnPrice; // price in wei

    event VPNAccessPurchased(address indexed user, uint256 amount);
    event PriceUpdated(uint256 oldPrice, uint256 newPrice);

    constructor(uint256 _initialPrice) {
        owner = msg.sender;
        vpnPrice = _initialPrice;
    }

    // Function to purchase VPN access
    function purchaseVPNAccess() external payable {
        require(msg.value >= vpnPrice, "Insufficient payment");
        emit VPNAccessPurchased(msg.sender, msg.value);
    }

    // Function for owner to update VPN price
    function updateVPNPrice(uint256 _newPrice) external {
        require(msg.sender == owner, "Only owner can update price");
        emit PriceUpdated(vpnPrice, _newPrice);
        vpnPrice = _newPrice;
    }

    // Function to withdraw collected funds
    function withdrawFunds() external {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }
}

