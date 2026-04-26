// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 * ==============================
 * Crowdfunding Script Structure
 * ==============================
 * 1. SPDX & pragma
 * 2. Imports
 * 3. Script contract declaration
 * 4. run() function
 * 5. Deployment config values
 * 6. Broadcast deployment
 * 7. Return deployed contract
 */

import {Script} from "forge-std/Script.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";

contract DeployCrowdfunding is Script {
    function run() external returns (Crowdfunding) {
        uint256 fundingGoal = 5 ether;
        uint256 duration = 7 days;
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        Crowdfunding crowdfunding = new Crowdfunding(fundingGoal, duration);

        vm.stopBroadcast();

        return crowdfunding;
    }
}
