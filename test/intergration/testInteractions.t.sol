// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {FundMe} from "../../src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from '../../script/Interactions.s.sol';

contract testInteractions is Test {
    FundMe fundme;
    address USER = makeAddr("user");
    uint256 constant START_VALUE = 10 ether;
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deploy = new DeployFundMe();
        fundme = deploy.run();
        vm.deal(USER, START_VALUE);
    }

  function testUserCanFundAndOwnerWithdraw() public  {
        uint256 preUserBalance = address(USER).balance;
        uint256 preOwnerBalance = address(fundme.getOwner()).balance;

        // Using vm.prank to simulate funding from the USER address
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();

        WithdrawFundMe withdrawfundme = new WithdrawFundMe();
        withdrawfundme.withdrawFundMe(address(fundme));

        uint256 afterUserBalance = address(USER).balance;
        uint256 afterOwnerBalance = address(fundme.getOwner()).balance;

        assert(address(fundme).balance == 0);
        assertEq(afterUserBalance + SEND_VALUE, preUserBalance);
        assertEq(preOwnerBalance + SEND_VALUE, afterOwnerBalance);
    }
}