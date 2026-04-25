// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 * ============================
 * CustomToken Script Structure
 * ============================
 * 1. SPDX & pragma
 * 2. Imports
 * 3. Script contract declaration
 * 4. run() function
 * 5. Deployment config values
 * 6. Broadcast deployment
 * 7. Return deployed contract
 */

import {Script} from "forge-std/Script.sol";
import {CustomToken} from "src/CustomToken.sol";

contract DeployCustomToken is Script {
    function run() external returns (CustomToken) {
        uint256 maxSupply = vm.envUint("MAX_SUPPLY");
        uint256 initialSupply = vm.envUint("INITIAL_SUPPLY");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        CustomToken token = new CustomToken(maxSupply, initialSupply);

        vm.stopBroadcast();

        return token;
    }
}