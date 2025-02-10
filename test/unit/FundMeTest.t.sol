// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {FundMe} from "../../src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundme;
    address USER = makeAddr("user");
    uint256 constant START_VALUE = 10 ether;
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployfundME = new DeployFundMe();
        fundme = deployfundME.run();
        vm.deal(USER, START_VALUE);
    }

    function testMinimumUSDIsFive() public view {
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }

    function testI_ownerIsEqualToMsg_sender() public view {
        assertEq(fundme.getOwner(), msg.sender); //to see if the owner of the contract is the same person recieving the contract
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundme.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundme.fund{value: 2}(); //{value : 2} gives the fund a value. Like I payed the function an amount
    }

    modifier funded() {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        _;
    }

    function testFundUpdatesFundedDataStructure() public funded {
        uint256 amountfunded = fundme.getAddressToAmountFunded(USER);
        assertEq(SEND_VALUE, amountfunded);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        address funder = fundme.getFunders(0);

        assertEq(USER, funder);
    }

    function testOnlyOwnerCanWithdraw_Cheaper() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundme.CheaperWithdraw();
    }

    //testing strategy
    function testWithdrawWithASingleFunder_Cheaper() public funded {
        //arrange
        uint256 startingOwnerbalance = fundme.getOwner().balance;
        uint256 startingFundMEBalance = address(fundme).balance;

        //act
        vm.prank(fundme.getOwner());
        fundme.CheaperWithdraw();

        //assert
        uint256 endingOnwerbalance = fundme.getOwner().balance;
        uint256 endingFundmeBalance = address(fundme).balance;

        assertEq(endingFundmeBalance, 0);
        assertEq(startingOwnerbalance + startingFundMEBalance, endingOnwerbalance); //this means that the final amount in the owner's wallet should be equal to the amount of money in the contract + the owner's original balance
    }

    function testWithdrawWithMultipleFunders() public funded {
        //arrange
        uint160 numberOfFunders = 10;
        uint160 staringFunderIndex = 1;
        //uint256 is not allowed when  type converting with addresses

        for (uint160 i = staringFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE); // a combo of prank() and deal(). basically saying "address 1 sent 0.1 eth" "address 2 sent 0.1 eth(SEND_VALUE) "e.t.c
            fundme.fund{value: SEND_VALUE}();
        }

        //act
        uint256 startingFundMEBalance = address(fundme).balance;
        uint256 startingOwnerbalance = fundme.getOwner().balance;

        uint256 GasStart = gasleft();
        vm.txGasPrice(GAS_PRICE); //sets the gas price fro the transaction
        vm.startPrank(fundme.getOwner());
        fundme.CheaperWithdraw();
        vm.stopPrank();

        uint256 GasEnd = gasleft();

        uint256 GasUsed = (GasStart + GasEnd) * tx.gasprice;
        console.log(GasUsed);

        //assert
        uint256 endingOnwerbalance = fundme.getOwner().balance;
        uint256 endingFundmeBalance = address(fundme).balance;

        assertEq(endingFundmeBalance, 0);
        assertEq(startingOwnerbalance + startingFundMEBalance, endingOnwerbalance);
    }
}
