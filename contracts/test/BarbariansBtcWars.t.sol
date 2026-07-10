// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {BarbariansBtcWars} from "../src/BarbariansBtcWars.sol";

contract BarbariansBtcWarsTest is Test {
    BarbariansBtcWars game;
    address alice = address(0xA11CE);
    address bob = address(0xB0B);

    event Prediction(
        address indexed player,
        uint256 indexed epoch,
        uint8 team,
        uint64 targetPrice,
        string name
    );

    function setUp() public {
        game = new BarbariansBtcWars();
    }

    function test_RegisterAndPredict() public {
        vm.prank(alice);
        game.register("izzec", 1);
        (string memory name, uint8 team,) = game.players(alice);
        assertEq(name, "izzec");
        assertEq(team, 1);

        uint256 epoch = block.timestamp / 120;
        vm.expectEmit(true, true, false, true);
        emit Prediction(alice, epoch, 1, 6412345, "izzec");
        vm.prank(alice);
        game.predict(6412345);
    }

    function test_NameUniqueness() public {
        vm.prank(alice);
        game.register("savasci", 1);
        vm.prank(bob);
        vm.expectRevert(BarbariansBtcWars.NameTaken.selector);
        game.register("savasci", 2);
    }

    function test_RenameFreesOldName() public {
        vm.prank(alice);
        game.register("eski", 1);
        vm.prank(alice);
        game.register("yeni", 1);
        vm.prank(bob);
        game.register("eski", 2);   // eski ad artık boşta
        (string memory name,,) = game.players(bob);
        assertEq(name, "eski");
    }

    function test_TeamChange() public {
        vm.prank(alice);
        game.register("donen", 1);
        vm.prank(alice);
        game.setTeam(2);
        (, uint8 team,) = game.players(alice);
        assertEq(team, 2);
    }

    function test_RevertUnregisteredPredict() public {
        vm.prank(bob);
        vm.expectRevert(BarbariansBtcWars.NotRegistered.selector);
        game.predict(100);
    }

    function test_RevertBadInputs() public {
        vm.prank(alice);
        vm.expectRevert(BarbariansBtcWars.InvalidName.selector);
        game.register("ab", 1);
        vm.prank(alice);
        vm.expectRevert(BarbariansBtcWars.InvalidTeam.selector);
        game.register("gecerli", 3);
        vm.prank(alice);
        game.register("gecerli", 2);
        vm.prank(alice);
        vm.expectRevert(BarbariansBtcWars.InvalidPrice.selector);
        game.predict(0);
    }

    function test_EpochAdvances() public {
        uint256 e0 = game.currentEpoch();
        vm.warp(block.timestamp + 120);
        assertEq(game.currentEpoch(), e0 + 1);
    }
}
