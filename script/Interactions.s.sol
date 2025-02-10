//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";


contract FundFundMe is Script {
  uint256  SEND_VALUE = 0.01 ether;

  function FundfundMe (address mostRecentlyDeployed) public {
      
      FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
      console.log("Funded fundMe with %s", SEND_VALUE);
  } 

  function run () external {
    address mostrecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe",block.chainid);

    vm.startBroadcast();
    FundfundMe(mostrecentlyDeployed);
    vm.stopBroadcast();


  }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).CheaperWithdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecentlyDeployed);
    }
}