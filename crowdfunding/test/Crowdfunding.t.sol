// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 * ============================
 * Crowdfunding Test Structure
 * ============================
 * 1. SPDX & pragma
 * 2. Imports
 * 3. Test contract declaration
 * 4. Contract instance
 * 5. Test addresses
 * 6. Config values
 * 7. setUp()
 * 8. Constructor tests
 * 9. Contribution tests
 * 10. Withdrawal tests
 * 11. Refund tests
 * 12. Revert and edge case tests
 */

import {Test} from "forge-std/Test.sol";
import {Crowdfunding} from "../src/Crowdfunding.sol";

contract CrowdfundingTest is Test {
    Crowdfunding crowdfunding;

    address creator = address(1);
    address alice = address(2);
    address bob = address(3);

    uint256 fundingGoal = 5 ether;
    uint256 duration = 7 days;

    function setUp() public {
        vm.prank(creator);
        crowdfunding = new Crowdfunding(fundingGoal, duration);

        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
    }

    function testConstructorSetsValuesCorrectly() public view {
        assertEq(crowdfunding.creator(), creator);
        assertEq(crowdfunding.fundingGoal(), fundingGoal);
        assertEq(crowdfunding.totalFunds(), 0);
        assertEq(crowdfunding.withdrawn(), false);
    }

    function testContributeUpdatesBalancesCorrectly() public {
        vm.prank(alice);
        crowdfunding.contribute{value: 1 ether}();

        assertEq(crowdfunding.contributions(alice), 1 ether);
        assertEq(crowdfunding.totalFunds(), 1 ether);
    }

    function testContributeRevertsIfAmountIsZero() public {
        vm.prank(alice);
        vm.expectRevert(Crowdfunding.InvalidAmount.selector);
        crowdfunding.contribute{value: 0}();
    }

    function testContributeRevertsAfterDeadline() public {
        vm.warp(block.timestamp + duration + 1);

        vm.prank(alice);
        vm.expectRevert(Crowdfunding.CampaignEnded.selector);
        crowdfunding.contribute{value: 1 ether}();
    }

    function testCreatorCanWithdrawAfterGoalIsReached() public {
        vm.prank(alice);
        crowdfunding.contribute{value: 3 ether}();

        vm.prank(bob);
        crowdfunding.contribute{value: 2 ether}();

        vm.warp(block.timestamp + duration + 1);

        uint256 creatorBalanceBefore = creator.balance;

        vm.prank(creator);
        crowdfunding.withdrawFunds();

        uint256 creatorBalanceAfter = creator.balance;

        assertEq(creatorBalanceAfter - creatorBalanceBefore, 5 ether);
        assertEq(address(crowdfunding).balance, 0);
        assertEq(crowdfunding.withdrawn(), true);
    }

    function testNonCreatorCannotWithdraw() public {
        vm.prank(alice);
        crowdfunding.contribute{value: 5 ether}();

        vm.warp(block.timestamp + duration + 1);

        vm.prank(alice);
        vm.expectRevert(Crowdfunding.NotCreator.selector);
        crowdfunding.withdrawFunds();
    }

    function testWithdrawRevertsIfGoalNotReached() public {
        vm.prank(alice);
        crowdfunding.contribute{value: 1 ether}();

        vm.warp(block.timestamp + duration + 1);

        vm.prank(creator);
        vm.expectRevert(Crowdfunding.GoalNotReached.selector);
        crowdfunding.withdrawFunds();
    }

    function testWithdrawRevertsIfCampaignStillActive() public {
        vm.prank(alice);
        crowdfunding.contribute{value: 5 ether}();

        vm.prank(creator);
        vm.expectRevert(Crowdfunding.CampaignStillActive.selector);
        crowdfunding.withdrawFunds();
    }

    function testContributorCanClaimRefundIfGoalNotReached() public {
        vm.prank(alice);
        crowdfunding.contribute{value: 1 ether}();

        vm.warp(block.timestamp + duration + 1);

        uint256 aliceBalanceBefore = alice.balance;

        vm.prank(alice);
        crowdfunding.claimRefund();

        uint256 aliceBalanceAfter = alice.balance;

        assertEq(aliceBalanceAfter, aliceBalanceBefore + 1 ether);
        assertEq(crowdfunding.contributions(alice), 0);
    }

    function testRefundRevertsIfGoalReached() public {
        vm.prank(alice);
        crowdfunding.contribute{value: 5 ether}();

        vm.warp(block.timestamp + duration + 1);

        vm.prank(alice);
        vm.expectRevert(Crowdfunding.GoalReached.selector);
        crowdfunding.claimRefund();
    }

    function testRefundRevertsIfNoContribution() public {
        vm.warp(block.timestamp + duration + 1);

        vm.prank(alice);
        vm.expectRevert(Crowdfunding.NoContribution.selector);
        crowdfunding.claimRefund();
    }

    function testRefundCannotBeClaimedTwice() public {
        vm.prank(alice);
        crowdfunding.contribute{value: 1 ether}();

        vm.warp(block.timestamp + duration + 1);

        vm.prank(alice);
        crowdfunding.claimRefund();

        vm.prank(alice);
        vm.expectRevert(Crowdfunding.NoContribution.selector);
        crowdfunding.claimRefund();
    }
}
