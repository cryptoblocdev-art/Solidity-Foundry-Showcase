// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 * =========================
 * CustomToken Structure
 * =========================
 * 1. SPDX & pragma
 * 2. Imports
 * 3. Contract declaration
 * 4. Custom errors
 * 5. State variables
 * 6. Constructor
 * 7. Mint function
 */

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract CustomToken is ERC20, Ownable {
    error MaxSupplyExceeded();
    error InvalidMaxSupply();
    error InvalidAmount();
    error InvalidInitialSupply();

    uint256 public immutable maxSupply;

    constructor(
        uint256 _maxSupply,
        uint256 _initialSupply
    ) ERC20("Custom Token", "CTK") Ownable(msg.sender) {
        if (_maxSupply == 0) revert InvalidMaxSupply();
        if (_initialSupply > _maxSupply) revert InvalidInitialSupply();

        maxSupply = _maxSupply;

        if (_initialSupply > 0) {
            _mint(msg.sender, _initialSupply);
        }
    }

    function mint(address to, uint256 amount) external onlyOwner {
        if (amount == 0) revert InvalidAmount();
        if (totalSupply() + amount > maxSupply) revert MaxSupplyExceeded();

        _mint(to, amount);
    }
}
