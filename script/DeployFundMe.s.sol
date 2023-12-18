// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { Script } from "forge-std/Script.sol";
import { FundMe } from "../src/FundMe.sol";
import { HelperConfig } from "./HelperConfig.s.sol";

contract DeployFundMe is Script
{
    function run() external returns (FundMe)
    {
        // apapun sebelum start broadcast, bukan termasuk real transaction, tapi bakal dianggep simulate env
        // biar ga spend gas buat ini di real chain
        HelperConfig helperConfig = new HelperConfig();
        // di wrap sama () karena itu struct dan bisa mengisi lebih dari 1 value
        (address ethUsdPriceFeed) = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}