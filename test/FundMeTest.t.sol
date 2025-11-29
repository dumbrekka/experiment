// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {FundMeDeploy} from "../script/FundMeDeploy.s.sol";
import "forge-std/console.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint constant DEPO_SIT = 10 ether;

    function setUp() external {
        FundMeDeploy fundMeDeploy = new FundMeDeploy();
        fundMe = fundMeDeploy.run();
        vm.deal(USER, DEPO_SIT);
    }

    function testminUsd() public view {
        assertEq(fundMe.PRICE_USD(), 1e18);
    }

    function testZeroEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: DEPO_SIT}();
        _;
    }

    function testListofPoor() public funded {
        uint lost = fundMe.getInvestAmount(USER);
        assertEq(lost, DEPO_SIT);
    }

    function testArraygetPoor() public funded {
        assertEq(USER, fundMe.getPoor(0));
    }

    function testOwner() public {
        vm.prank(USER);
        fundMe.fund{value: DEPO_SIT}();

        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawal() public funded {
        uint startingOwnerBalance = fundMe.getOwner().balance;
        uint startingContractBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        assertEq(
            fundMe.getOwner().balance,
            (startingOwnerBalance + startingContractBalance)
        );

        assertEq(address(fundMe).balance, 0);
    }

    function testWithdrawalmultiple() public funded {
        uint160 addressIndex = 1;
        uint160 fundersN = 200;

        for (uint160 i = addressIndex; i < fundersN; i++) {
            hoax(address(i), DEPO_SIT);
            fundMe.fund{value: DEPO_SIT}();
        }
        uint startingOwnerBalance = fundMe.getOwner().balance;
        uint startingContractBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank;
        assertEq(
            fundMe.getOwner().balance,
            (startingOwnerBalance + startingContractBalance)
        );

        assert(address(fundMe).balance == 0);
    }
}
