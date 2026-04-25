// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 * =========================
 * Staking Script Structure
 * =========================
 * 1. SPDX & pragma
 * 2. Imports
 * 3. Script contract declaration
 * 4. run() function
 * 5. Deployment config values
 * 6. Broadcast deployment
 * 7. Return deployed contract
 */

import {Script} from "forge-std/Script.sol";
import {Staking} from "src/Staking.sol";

contract DeployStaking is Script {
    error MissingStakingToken();
    error MissingRewardToken();
    error MissingRewardRate();

    function run() external returns (Staking) {
        address stakingToken = vm.envAddress("STAKING_TOKEN");
        address rewardToken = vm.envAddress("REWARD_TOKEN");
        uint256 rewardRate = vm.envUint("REWARD_RATE");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        if (stakingToken == address(0)) revert MissingStakingToken();
        if (rewardToken == address(0)) revert MissingRewardToken();
        if (rewardRate == 0) revert MissingRewardRate();

        vm.startBroadcast(deployerPrivateKey);

        Staking staking = new Staking(stakingToken, rewardToken, rewardRate);

        vm.stopBroadcast();

        return staking;
    }
}
