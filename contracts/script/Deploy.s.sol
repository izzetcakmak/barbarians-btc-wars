// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {BarbariansBtcWars} from "../src/BarbariansBtcWars.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();
        BarbariansBtcWars game = new BarbariansBtcWars();
        vm.stopBroadcast();
        console.log("BarbariansBtcWars:", address(game));
    }
}
