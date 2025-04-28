// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedVPNPayment {
    address public owner;
    uint256 public vpnPrice; // price in wei

    mapping(address => uint256) public userPayments;
    mapping(address => bool) public hasAccess;

    event VPNAccessPurchased(address indexed user, uint256 amount);
    event PriceUpdated(uint256 oldPrice, uint256 newPrice);
    event RefundIssued(address indexed user, uint256 amount);
    event AccessGranted(address indexed user);
    event AccessRevoked(address indexed user);
    event ContractPaused(bool paused);
    
    bool public isPaused;
    address public admin;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier whenNotPaused() {
        require(!isPaused, "Contract is paused");
        _;
    }

    constructor(uint256 _initialPrice, address _admin) {
        owner = msg.sender;
        vpnPrice = _initialPrice;
        admin = _admin;
    }

    // Function to purchase VPN access
    function purchaseVPNAccess() external payable whenNotPaused {
        require(msg.value >= vpnPrice, "Insufficient payment");
        userPayments[msg.sender] += msg.value;
        hasAccess[msg.sender] = true;
        emit VPNAccessPurchased(msg.sender, msg.value);
        emit AccessGranted(msg.sender);
    }

    // Function for owner to update VPN price
    function updateVPNPrice(uint256 _newPrice) external onlyOwner {
        emit PriceUpdated(vpnPrice, _newPrice);
        vpnPrice = _newPrice;
    }

    // Function to withdraw collected funds
    function withdrawFunds() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    // Function to refund user if they overpaid
    function refundExcessPayment() external {
        uint256 excessAmount = userPayments[msg.sender] - vpnPrice;
        require(excessAmount > 0, "No excess payment to refund");
        
        userPayments[msg.sender] = vpnPrice; // Ensure only the actual payment is retained
        payable(msg.sender).transfer(excessAmount);
        emit RefundIssued(msg.sender, excessAmount);
    }

    // Function to check if user has access
    function checkVPNAccess() external view returns (bool) {
        return hasAccess[msg.sender];
    }

    // Function to grant admin powers to another address
    function grantAdmin(address _newAdmin) external onlyOwner {
        admin = _newAdmin;
    }

    // Function for admin to pause or unpause the contract
    function togglePause() external onlyAdmin {
        isPaused = !isPaused;
        emit ContractPaused(isPaused);
    }

    // Function to revoke VPN access (owner or admin)
    function revokeAccess(address _user) external onlyAdmin {
        require(hasAccess[_user], "User does not have VPN access");
        hasAccess[_user] = false;
        emit AccessRevoked(_user);
    }

    // Function for owner to transfer ownership
    function transferOwnership(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }
}


