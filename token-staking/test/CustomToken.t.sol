// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 * ============================
 * CustomToken Test Structure
 * ============================
 * 1. SPDX & pragma
 * 2. Imports
 * 3. Test contract declaration
 * 4. Contract instance
 * 5. Test addresses
 * 6. Config values
 * 7. setUp()
 * 8. Constructor tests
 * 9. Initial supply tests
 * 10. Mint tests
 * 11. Revert tests
 */

import {Test} from "forge-std/Test.sol";
import {CustomToken} from "src/CustomToken.sol";

contract CustomTokenTest is Test {
    CustomToken token;

    address owner = address(1);
    address alice = address(2);
    address bob = address(3);

    uint256 maxSupply = 1_000_000 ether;
    uint256 initialSupply = 100_000 ether;

    function setUp() public {
        vm.prank(owner);
        token = new CustomToken(maxSupply, initialSupply);
    }

    function testConstructorSetsValuesCorrectly() public view {
        assertEq(token.name(), "Custom Token");
        assertEq(token.symbol(), "CTK");
        assertEq(token.maxSupply(), maxSupply);
        assertEq(token.totalSupply(), initialSupply);
        assertEq(token.owner(), owner);
    }

    function testInitialSupplyMintedToOwner() public view {
        assertEq(token.balanceOf(owner), initialSupply);
    }

    function testConstructorRevertsIfMaxSupplyIsZero() public {
        vm.prank(owner);
        vm.expectRevert(CustomToken.InvalidMaxSupply.selector);
        new CustomToken(0, initialSupply);
    }

    function testConstructorRevertsIfInitialSupplyExceedsMaxSupply() public {
        vm.prank(owner);
        vm.expectRevert(CustomToken.InvalidInitialSupply.selector);
        new CustomToken(100 ether, 200 ether);
    }

    function testOwnerCanMint() public {
        uint256 mintAmount = 50_000 ether;

        vm.prank(owner);
        token.mint(alice, mintAmount);

        assertEq(token.balanceOf(alice), mintAmount);
        assertEq(token.totalSupply(), initialSupply + mintAmount);
    }

    function testNonOwnerCannotMint() public {
        vm.prank(alice);
        vm.expectRevert();
        token.mint(bob, 1 ether);
    }

    function testMintRevertsIfAmountIsZero() public {
        vm.prank(owner);
        vm.expectRevert(CustomToken.InvalidAmount.selector);
        token.mint(alice, 0);
    }

    function testMintRevertsIfMaxSupplyExceeded() public {
        uint256 remainingSupply = maxSupply - initialSupply;

        vm.prank(owner);
        token.mint(alice, remainingSupply);

        vm.prank(owner);
        vm.expectRevert(CustomToken.MaxSupplyExceeded.selector);
        token.mint(alice, 1 ether);
    }
}
