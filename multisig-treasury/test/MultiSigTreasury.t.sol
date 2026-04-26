// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 * ==================================
 * MultiSigTreasury Test Structure
 * ==================================
 * 1. SPDX & pragma
 * 2. Imports
 * 3. Test contract declaration
 * 4. Contract instance
 * 5. Test addresses
 * 6. Config values
 * 7. setUp()
 * 8. Constructor tests
 * 9. Submit transaction tests
 * 10. Confirm transaction tests
 * 11. Revoke confirmation tests
 * 12. Execute transaction tests
 * 13. Revert and edge case tests
 */

import {Test} from "forge-std/Test.sol";
import {MultiSigTreasury} from "src/MultiSigTreasury.sol";

contract MultiSigTreasuryTest is Test {
    MultiSigTreasury treasury;

    address owner1 = address(1);
    address owner2 = address(2);
    address owner3 = address(3);
    address nonOwner = address(4);
    address recipient = address(5);

    uint256 requiredConfirmations = 2;

    function setUp() public {
        address[] memory owners = new address[](3);
        owners[0] = owner1;
        owners[1] = owner2;
        owners[2] = owner3;

        treasury = new MultiSigTreasury(owners, requiredConfirmations);

        vm.deal(address(treasury), 10 ether);
    }

    function testConstructorSetsOwnersAndConfirmations() public view {
        assertEq(treasury.requiredConfirmations(), requiredConfirmations);
        assertEq(treasury.isOwner(owner1), true);
        assertEq(treasury.isOwner(owner2), true);
        assertEq(treasury.isOwner(owner3), true);
        assertEq(treasury.isOwner(nonOwner), false);
    }

    function testConstructorRevertsIfOwnerArrayIsEmpty() public {
        address[] memory owners = new address[](0);

        vm.expectRevert(MultiSigTreasury.InvalidRequiredConfirmations.selector);
        new MultiSigTreasury(owners, 1);
    }

    function testConstructorRevertsIfRequiredConfirmationsIsZero() public {
        address[] memory owners = new address[](2);
        owners[0] = owner1;
        owners[1] = owner2;

        vm.expectRevert(MultiSigTreasury.InvalidRequiredConfirmations.selector);
        new MultiSigTreasury(owners, 0);
    }

    function testConstructorRevertsIfRequiredConfirmationsExceedsOwnerCount() public {
        address[] memory owners = new address[](2);
        owners[0] = owner1;
        owners[1] = owner2;

        vm.expectRevert(MultiSigTreasury.InvalidRequiredConfirmations.selector);
        new MultiSigTreasury(owners, 3);
    }

    function testConstructorRevertsIfOwnerIsZeroAddress() public {
        address[] memory owners = new address[](2);
        owners[0] = owner1;
        owners[1] = address(0);

        vm.expectRevert(MultiSigTreasury.InvalidOwner.selector);
        new MultiSigTreasury(owners, 1);
    }

    function testConstructorRevertsIfOwnerIsDuplicated() public {
        address[] memory owners = new address[](2);
        owners[0] = owner1;
        owners[1] = owner1;

        vm.expectRevert(MultiSigTreasury.OwnerNotUnique.selector);
        new MultiSigTreasury(owners, 1);
    }

    function testOwnerCanSubmitTransaction() public {
        vm.prank(owner1);
        treasury.submitTransaction(recipient, 1 ether, "");

        assertEq(treasury.getTransactionCount(), 1);

        (
            address to,
            uint256 value,
            bytes memory data,
            bool executed,
            uint256 numConfirmations
        ) = treasury.getTransaction(0);

        assertEq(to, recipient);
        assertEq(value, 1 ether);
        assertEq(data.length, 0);
        assertEq(executed, false);
        assertEq(numConfirmations, 0);
    }

    function testNonOwnerCannotSubmitTransaction() public {
        vm.prank(nonOwner);
        vm.expectRevert(MultiSigTreasury.NotOwner.selector);
        treasury.submitTransaction(recipient, 1 ether, "");
    }

    function testOwnerCanConfirmTransaction() public {
        vm.prank(owner1);
        treasury.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        treasury.confirmTransaction(0);

        (, , , , uint256 numConfirmations) = treasury.getTransaction(0);
        assertEq(numConfirmations, 1);
        assertEq(treasury.isConfirmed(0, owner1), true);
    }

    function testOwnerCannotConfirmTwice() public {
        vm.prank(owner1);
        treasury.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        treasury.confirmTransaction(0);

        vm.prank(owner1);
        vm.expectRevert(MultiSigTreasury.TransactionAlreadyConfirmed.selector);
        treasury.confirmTransaction(0);
    }

    function testNonOwnerCannotConfirmTransaction() public {
        vm.prank(owner1);
        treasury.submitTransaction(recipient, 1 ether, "");

        vm.prank(nonOwner);
        vm.expectRevert(MultiSigTreasury.NotOwner.selector);
        treasury.confirmTransaction(0);
    }

    function testOwnerCanRevokeConfirmation() public {
        vm.prank(owner1);
        treasury.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        treasury.confirmTransaction(0);

        vm.prank(owner1);
        treasury.revokeConfirmation(0);

        (, , , , uint256 numConfirmations) = treasury.getTransaction(0);
        assertEq(numConfirmations, 0);
        assertEq(treasury.isConfirmed(0, owner1), false);
    }

    function testCannotRevokeIfNotConfirmed() public {
        vm.prank(owner1);
        treasury.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        vm.expectRevert(MultiSigTreasury.TransactionNotConfirmed.selector);
        treasury.revokeConfirmation(0);
    }

    function testCannotExecuteWithoutEnoughConfirmations() public {
        vm.prank(owner1);
        treasury.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        treasury.confirmTransaction(0);

        vm.prank(owner1);
        vm.expectRevert(MultiSigTreasury.NotEnoughConfirmations.selector);
        treasury.executeTransaction(0);
    }

    function testCanExecuteWithEnoughConfirmations() public {
        vm.prank(owner1);
        treasury.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        treasury.confirmTransaction(0);

        vm.prank(owner2);
        treasury.confirmTransaction(0);

        uint256 recipientBalanceBefore = recipient.balance;

        vm.prank(owner1);
        treasury.executeTransaction(0);

        uint256 recipientBalanceAfter = recipient.balance;

        (, , , bool executed, uint256 numConfirmations) = treasury.getTransaction(0);

        assertEq(recipientBalanceAfter - recipientBalanceBefore, 1 ether);
        assertEq(executed, true);
        assertEq(numConfirmations, 2);
    }

    function testCannotExecuteTwice() public {
        vm.prank(owner1);
        treasury.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner1);
        treasury.confirmTransaction(0);

        vm.prank(owner2);
        treasury.confirmTransaction(0);

        vm.prank(owner1);
        treasury.executeTransaction(0);

        vm.prank(owner2);
        vm.expectRevert(MultiSigTreasury.TransactionAlreadyExecuted.selector);
        treasury.executeTransaction(0);
    }

    function testTransactionMustExistToConfirm() public {
        vm.prank(owner1);
        vm.expectRevert(MultiSigTreasury.TransactionDoesNotExist.selector);
        treasury.confirmTransaction(0);
    }

    function testTransactionMustExistToRevoke() public {
        vm.prank(owner1);
        vm.expectRevert(MultiSigTreasury.TransactionDoesNotExist.selector);
        treasury.revokeConfirmation(0);
    }

    function testTransactionMustExistToExecute() public {
        vm.prank(owner1);
        vm.expectRevert(MultiSigTreasury.TransactionDoesNotExist.selector);
        treasury.executeTransaction(0);
    }
}