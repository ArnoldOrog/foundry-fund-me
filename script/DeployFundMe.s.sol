//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        //before startBroadcast not a real transcation
        HelperConfig helperconfig = new HelperConfig();
        (address priceFeed) = helperconfig.activeNetworkConfig();

        vm.startBroadcast();
        //real transaction. gas costs 😭
        FundMe fundMe = new FundMe(priceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
