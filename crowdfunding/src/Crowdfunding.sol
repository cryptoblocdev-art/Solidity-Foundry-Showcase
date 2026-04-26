// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 * =========================
 * Crowdfunding Structure
 * =========================
 * 1. SPDX & pragma
 * 2. Contract declaration
 * 3. Custom errors
 * 4. Events
 * 5. State variables
 * 6. Modifiers
 * 7. Constructor
 * 8. Contribution function
 * 9. Withdrawal function
 * 10. Refund function
 * 11. View functions
 */

contract Crowdfunding {
    error NotCreator();
    error CampaignEnded();
    error CampaignStillActive();
    error GoalNotReached();
    error GoalReached();
    error NoContribution();
    error AlreadyWithdrawn();
    error InvalidAmount();
    error InvalidDeadline();
    error TransferFailed();

    event ContributionReceived(address indexed contributor, uint256 amount);
    event FundsWithdrawn(address indexed creator, uint256 amount);
    event RefundClaimed(address indexed contributor, uint256 amount);

    address public creator;
    uint256 public fundingGoal;
    uint256 public deadline;
    uint256 public totalFunds;
    bool public withdrawn;

    mapping(address => uint256) public contributions;

    modifier onlyCreator() {
        if (msg.sender != creator) revert NotCreator();
        _;
    }

    constructor(uint256 _fundingGoal, uint256 _durationInSeconds) {
        if (_fundingGoal == 0) revert InvalidAmount();
        if (_durationInSeconds == 0) revert InvalidDeadline();

        creator = msg.sender;
        fundingGoal = _fundingGoal;
        deadline = block.timestamp + _durationInSeconds;
    }
	
    function contribute() external payable {
    if (block.timestamp >= deadline) revert CampaignEnded();
    if (msg.value == 0) revert InvalidAmount();

    contributions[msg.sender] += msg.value;
    totalFunds += msg.value;

    emit ContributionReceived(msg.sender, msg.value);
}

	function withdrawFunds() external onlyCreator {
    	if (block.timestamp < deadline) revert CampaignStillActive();
    	if (totalFunds < fundingGoal) revert GoalNotReached();
    	if (withdrawn) revert AlreadyWithdrawn();

    	withdrawn = true;

    	uint256 amount = address(this).balance;
    	(bool success, ) = payable(creator).call{value: amount}("");
    	if (!success) revert TransferFailed();

    	emit FundsWithdrawn(creator, amount);
}

	function claimRefund() external {
    	if (block.timestamp < deadline) revert CampaignStillActive();
    	if (totalFunds >= fundingGoal) revert GoalReached();

    	uint256 amount = contributions[msg.sender];
    	if (amount == 0) revert NoContribution();

    	contributions[msg.sender] = 0;

    	(bool success, ) = payable(msg.sender).call{value: amount}("");
    	if (!success) revert TransferFailed();

    	emit RefundClaimed(msg.sender, amount);
}

	function getTimeLeft() external view returns (uint256) {
    	if (block.timestamp >= deadline) {
        return 0;
    }

    	return deadline - block.timestamp;
}

	function isGoalReached() external view returns (bool) {
    	return totalFunds >= fundingGoal;
	}
}
