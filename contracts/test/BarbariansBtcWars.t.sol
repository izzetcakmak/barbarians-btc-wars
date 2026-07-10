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
    event NameReleased(address indexed player, string oldName);

    function setUp() public {
        game = new BarbariansBtcWars();
        vm.warp(1_752_000_000); // sabit zaman — epoch matematiği deterministik
    }

    /* ---- kayıt ---- */

    function test_RegisterAndPredict() public {
        vm.prank(alice);
        game.register("izzec", 1);
        (string memory name, uint8 team,) = game.players(alice);
        assertEq(name, "izzec");
        assertEq(team, 1);

        uint256 next = game.currentEpoch() + 1;
        vm.expectEmit(true, true, false, true);
        emit Prediction(alice, next, 1, 6412345, "izzec");
        vm.prank(alice);
        game.predict(6412345, next);
    }

    function test_NameUniqueness() public {
        vm.prank(alice);
        game.register("savasci", 1);
        vm.prank(bob);
        vm.expectRevert(BarbariansBtcWars.NameTaken.selector);
        game.register("savasci", 2);
    }

    function test_CaseFoldedUniqueness() public {
        vm.prank(alice);
        game.register("Savasci", 1);
        vm.prank(bob);
        vm.expectRevert(BarbariansBtcWars.NameTaken.selector);
        game.register("SAVASCI", 2);      // büyük/küçük varyant aynı anahtara düşer
        vm.prank(bob);
        vm.expectRevert(BarbariansBtcWars.NameTaken.selector);
        game.register("savasci", 2);
    }

    function test_TurkishNamesFoldAndCollide() public {
        vm.prank(alice);
        game.register(unicode"Boğaçhan", 1);   // ğ + ç içerir
        (string memory name,,) = game.players(alice);
        assertEq(name, unicode"Boğaçhan");
        vm.prank(bob);
        vm.expectRevert(BarbariansBtcWars.NameTaken.selector);
        game.register(unicode"BOĞAÇHAN", 2);   // Türkçe büyük harf katlaması
    }

    function test_DottedIandDotlessICollide() public {
        vm.prank(alice);
        game.register(unicode"İzzet", 1);
        vm.prank(bob);
        vm.expectRevert(BarbariansBtcWars.NameTaken.selector);
        game.register(unicode"ızzet", 2);      // İ ve ı aynı anahtar
    }

    function test_RejectIllegalCharacters() public {
        vm.startPrank(alice);
        vm.expectRevert(BarbariansBtcWars.InvalidName.selector);
        game.register("has space", 1);
        vm.expectRevert(BarbariansBtcWars.InvalidName.selector);
        game.register(unicode"z​wsp", 1);          // görünmez zero-width space
        vm.expectRevert(BarbariansBtcWars.InvalidName.selector);
        game.register(unicode"Wаrrior", 1);             // Kiril 'а' homoglifi
        vm.expectRevert(BarbariansBtcWars.InvalidName.selector);
        game.register("<script>", 1);
        vm.stopPrank();
    }

    function test_NameLengthBoundaries() public {
        // 16 Türkçe 2-bayt karakter = tam 32 bayt: kabul
        vm.prank(alice);
        game.register(unicode"çğıöşüçğıöşüçğıö", 1);
        (string memory name,,) = game.players(alice);
        assertEq(bytes(name).length, 32);
        // 33 bayt: ret
        vm.prank(bob);
        vm.expectRevert(BarbariansBtcWars.InvalidName.selector);
        game.register(unicode"çğıöşüçğıöşüçğıöa", 2);
        // 2 bayt: ret
        vm.prank(bob);
        vm.expectRevert(BarbariansBtcWars.InvalidName.selector);
        game.register("ab", 1);
    }

    function test_RenameFreesOldNameAndEmitsRelease() public {
        vm.prank(alice);
        game.register("eski", 1);
        vm.expectEmit(true, false, false, true);
        emit NameReleased(alice, "eski");
        vm.prank(alice);
        game.register("yeni", 1);
        vm.prank(bob);
        game.register("eski", 2);   // eski ad artık boşta
        (string memory name,,) = game.players(bob);
        assertEq(name, "eski");
    }

    function test_ReRegisterSameNameKeepsOwnership() public {
        vm.prank(alice);
        game.register("sabit", 1);
        vm.prank(alice);
        game.register("sabit", 2);  // aynı ad, takım değişikliğiyle
        (, uint8 team,) = game.players(alice);
        assertEq(team, 2);
        vm.prank(bob);
        vm.expectRevert(BarbariansBtcWars.NameTaken.selector);
        game.register("sabit", 1);
    }

    /* ---- takım ---- */

    function test_TeamChange() public {
        vm.prank(alice);
        game.register("donen", 1);
        vm.prank(alice);
        game.setTeam(2);
        (, uint8 team,) = game.players(alice);
        assertEq(team, 2);
    }

    /* ---- tahmin ---- */

    function test_PredictTargetsNextEpochOnly() public {
        vm.prank(alice);
        game.register("nisanci", 1);
        uint256 cur = game.currentEpoch();
        vm.startPrank(alice);
        vm.expectRevert(BarbariansBtcWars.WrongEpoch.selector);
        game.predict(100, cur);          // içinde bulunulan epoch: yasak (avcılık)
        vm.expectRevert(BarbariansBtcWars.WrongEpoch.selector);
        game.predict(100, cur + 2);      // uzak gelecek: yasak
        game.predict(100, cur + 1);      // sonraki epoch: serbest
        vm.stopPrank();
    }

    function test_LatePredictRevertsInsteadOfMisattributing() public {
        vm.prank(alice);
        game.register("gecikmis", 1);
        uint256 intended = game.currentEpoch() + 1;
        vm.warp(block.timestamp + 120);  // tx sınırı kaçırdı, epoch ilerledi
        vm.prank(alice);
        vm.expectRevert(BarbariansBtcWars.WrongEpoch.selector);
        game.predict(100, intended);
    }

    function test_RevertUnregisteredPredict() public {
        uint256 next = game.currentEpoch() + 1;
        vm.prank(bob);
        vm.expectRevert(BarbariansBtcWars.NotRegistered.selector);
        game.predict(100, next);
    }

    function test_RevertBadInputs() public {
        vm.prank(alice);
        vm.expectRevert(BarbariansBtcWars.InvalidTeam.selector);
        game.register("gecerli", 3);
        vm.prank(alice);
        game.register("gecerli", 2);
        uint256 next = game.currentEpoch() + 1;
        vm.startPrank(alice);
        vm.expectRevert(BarbariansBtcWars.InvalidPrice.selector);
        game.predict(0, next);
        vm.expectRevert(BarbariansBtcWars.InvalidPrice.selector);
        game.predict(1e13, next);        // üst sınır: $100 milyar
        vm.stopPrank();
    }

    function test_EpochAdvances() public {
        uint256 e0 = game.currentEpoch();
        vm.warp(block.timestamp + 120);
        assertEq(game.currentEpoch(), e0 + 1);
    }
}
