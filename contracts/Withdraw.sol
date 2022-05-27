// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Withdraw is Ownable, Pausable, ReentrancyGuard {
    address public signer;

    constructor() {
        signer = msg.sender;
    }

    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
    }

    function pause() public onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() public onlyOwner whenPaused {
        _unpause();
    }
}