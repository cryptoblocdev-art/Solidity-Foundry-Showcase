// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 * =========================
 * Staking Structure
 * =========================
 * 1. SPDX & pragma
 * 2. Imports
 * 3. Contract declaration
 * 4. Custom errors
 * 5. Events
 * 6. State variables
 * 7. Constructor
 * 8. Reward calculation function
 * 9. Internal reward update function
 * 10. Stake function
 * 11. Unstake function
 * 12. Claim rewards function
 */

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking {
    error InvalidAmount();
    error InsufficientStakedBalance();
    error NoRewardsToClaim();
    error ZeroAddress();
    error InvalidRewardRate();
    error TransferFailed();

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 amount);

    IERC20 public stakingToken;
    IERC20 public rewardToken;
    uint256 public rewardRate;
    uint256 public constant PRECISION = 1e18;

    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public lastUpdated;

    constructor(
        address _stakingToken,
        address _rewardToken,
        uint256 _rewardRate
    ) {
        if (_stakingToken == address(0) || _rewardToken == address(0))
            revert ZeroAddress();
        if (_rewardRate == 0) revert InvalidRewardRate();

        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        rewardRate = _rewardRate;
    }

    function earned(address account) public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - lastUpdated[account];
        uint256 pendingRewards = (stakedBalance[account] *
            rewardRate *
            timeElapsed) / PRECISION;

        return rewards[account] + pendingRewards;
    }

    function _updateRewards(address account) internal {
        rewards[account] = earned(account);
        lastUpdated[account] = block.timestamp;
    }

    function stake(uint256 amount) external {
        if (amount == 0) revert InvalidAmount();

        _updateRewards(msg.sender);

        bool success = stakingToken.transferFrom(
            msg.sender,
            address(this),
            amount
        );
        if (!success) revert TransferFailed();

        stakedBalance[msg.sender] += amount;

        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external {
        if (amount == 0) revert InvalidAmount();
        if (stakedBalance[msg.sender] < amount)
            revert InsufficientStakedBalance();

        _updateRewards(msg.sender);

        stakedBalance[msg.sender] -= amount;

        bool success = stakingToken.transfer(msg.sender, amount);
        if (!success) revert TransferFailed();

        emit Unstaked(msg.sender, amount);
    }

    function claimRewards() external {
        _updateRewards(msg.sender);

        uint256 reward = rewards[msg.sender];
        if (reward == 0) revert NoRewardsToClaim();

        rewards[msg.sender] = 0;

        bool success = rewardToken.transfer(msg.sender, reward);
        if (!success) revert TransferFailed();

        emit RewardsClaimed(msg.sender, reward);
    }
}
