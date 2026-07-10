// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {BarbariansBtcWars} from "../src/BarbariansBtcWars.sol";

contract Deploy is Script {
    function run() external {
        require(block.chainid == 4663, "yanlis ag: Robinhood Chain (4663) bekleniyor");
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        BarbariansBtcWars game = new BarbariansBtcWars();
        vm.stopBroadcast();
        console.log("BarbariansBtcWars:", address(game));
        console.log("owner:", game.owner());
    }
}
