// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { Script } from "forge-std/Script.sol";
import { MockV3Aggregator } from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script
{
    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    constructor()
    {
        if (block.chainid == 11155111)
        {
            activeNetworkConfig = getSepoliaETHConfig();
        }
        else 
        {
            activeNetworkConfig = getOrCreateAnvilETHConfig();
        }
    }

    struct NetworkConfig 
    {
        address priceFeed; // ETH/USD PriceFeed
    }

    function getSepoliaETHConfig() public pure returns (NetworkConfig memory)
    {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getOrCreateAnvilETHConfig() public returns (NetworkConfig memory) 
    {
        if (activeNetworkConfig.priceFeed != address(0))
        {
            return activeNetworkConfig;
        }

        // deploy mocks dulu (mocks itu kek dummy contract, trs return addressnya)
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();
        
        // dideclare di luar startBroadcast() dan stopBroadcast(), supaya bisa diakses secara global oleh class lain
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });

        return anvilConfig;
    }
}