// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 * ========================
 * Staking Test Structure
 * ========================
 * 1. SPDX & pragma
 * 2. Imports
 * 3. Test contract declaration
 * 4. Contract instances
 * 5. Test addresses
 * 6. Config values
 * 7. setUp()
 * 8. Constructor tests
 * 9. Stake tests
 * 10. Unstake tests
 * 11. Reward calculation tests
 * 12. Claim rewards tests
 * 13. Revert and edge case tests
 */

import {Test} from "forge-std/Test.sol";
import {CustomToken} from "src/CustomToken.sol";
import {Staking} from "src/Staking.sol";

contract StakingTest is Test {
    CustomToken token;
    Staking staking;

    address owner = address(1);
    address alice = address(2);
    address bob = address(3);

    uint256 maxSupply = 1_000_000 ether;
    uint256 initialSupply = 500_000 ether;
    uint256 rewardRate = 1e15;

    function setUp() public {
        vm.startPrank(owner);
        token = new CustomToken(maxSupply, initialSupply);
        staking = new Staking(address(token), address(token), rewardRate);

        token.mint(alice, 1_000 ether);
        token.mint(bob, 1_000 ether);

        bool success = token.transfer(address(staking), 100_000 ether);
        assertTrue(success);
        vm.stopPrank();

        vm.prank(alice);
        token.approve(address(staking), type(uint256).max);

        vm.prank(bob);
        token.approve(address(staking), type(uint256).max);
    }

    function testConstructorSetsValuesCorrectly() public view {
        assertEq(address(staking.stakingToken()), address(token));
        assertEq(address(staking.rewardToken()), address(token));
        assertEq(staking.rewardRate(), rewardRate);
    }

    function testConstructorRevertsIfTokenAddressIsZero() public {
        vm.expectRevert(Staking.ZeroAddress.selector);
        new Staking(address(0), address(token), rewardRate);
    }

    function testConstructorRevertsIfRewardRateIsZero() public {
        vm.expectRevert(Staking.InvalidRewardRate.selector);
        new Staking(address(token), address(token), 0);
    }

    function testStakeUpdatesBalanceCorrectly() public {
        vm.prank(alice);
        staking.stake(100 ether);

        assertEq(staking.stakedBalance(alice), 100 ether);
    }

    function testStakeRevertsIfAmountIsZero() public {
        vm.prank(alice);
        vm.expectRevert(Staking.InvalidAmount.selector);
        staking.stake(0);
    }

    function testUnstakeWorksCorrectly() public {
        vm.prank(alice);
        staking.stake(200 ether);

        vm.prank(alice);
        staking.unstake(50 ether);

        assertEq(staking.stakedBalance(alice), 150 ether);
    }

    function testUnstakeRevertsIfInsufficientBalance() public {
        vm.prank(alice);
        staking.stake(100 ether);

        vm.prank(alice);
        vm.expectRevert(Staking.InsufficientStakedBalance.selector);
        staking.unstake(200 ether);
    }

    function testUnstakeRevertsIfAmountIsZero() public {
        vm.prank(alice);
        vm.expectRevert(Staking.InvalidAmount.selector);
        staking.unstake(0);
    }

    function testEarnedRewardsIncreaseOverTime() public {
        vm.prank(alice);
        staking.stake(100 ether);

        vm.warp(block.timestamp + 10);

        uint256 earnedRewards = staking.earned(alice);
        assertEq(earnedRewards, 1 ether);
    }

    function testClaimRewardsWorks() public {
        vm.prank(alice);
        staking.stake(100 ether);

        vm.warp(block.timestamp + 10);

        uint256 balanceBefore = token.balanceOf(alice);

        vm.prank(alice);
        staking.claimRewards();

        uint256 balanceAfter = token.balanceOf(alice);

        assertEq(balanceAfter, balanceBefore + 1 ether);
        assertEq(staking.rewards(alice), 0);
    }

    function testClaimRewardsRevertsIfNoRewards() public {
        vm.prank(alice);
        vm.expectRevert(Staking.NoRewardsToClaim.selector);
        staking.claimRewards();
    }

    function testRewardsArePreservedWhenUnstaking() public {
        vm.prank(alice);
        staking.stake(100 ether);

        vm.warp(block.timestamp + 10);

        vm.prank(alice);
        staking.unstake(50 ether);

        uint256 storedRewards = staking.rewards(alice);
        assertEq(storedRewards, 1 ether);
    }
}
