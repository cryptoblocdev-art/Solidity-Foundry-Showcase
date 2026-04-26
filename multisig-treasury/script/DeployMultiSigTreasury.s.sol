// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/*
 * ==================================
 * MultiSigTreasury Script Structure
 * ==================================
 * 1. SPDX & pragma
 * 2. Imports
 * 3. Script contract declaration
 * 4. run() function
 * 5. Deployment config values
 * 6. Broadcast deployment
 * 7. Return deployed contract
 */

import {Script} from "forge-std/Script.sol";
import {MultiSigTreasury} from "src/MultiSigTreasury.sol";

contract DeployMultiSigTreasury is Script {
    function run() external returns (MultiSigTreasury) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address[] memory owners = new address[](3);
        owners[0] = vm.envAddress("OWNER_1");
        owners[1] = vm.envAddress("OWNER_2");
        owners[2] = vm.envAddress("OWNER_3");

        uint256 requiredConfirmations = vm.envUint("REQUIRED_CONFIRMATIONS");

        vm.startBroadcast(deployerPrivateKey);

        MultiSigTreasury treasury = new MultiSigTreasury(
            owners,
            requiredConfirmations
        );

        vm.stopBroadcast();

        return treasury;
    }
}