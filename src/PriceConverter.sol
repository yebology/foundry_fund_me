// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter
{
    // internal => hanya bisa diakses kalau didefinisikan di contract lain
    // sebagai contoh ini adalah library, functionnya dibuat internal, jadi apabila ingin menggunakan function library ini
    // di contract lain, maka di contract tersebut harus declare library ini
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) 
    {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData(); // nilai 1 ETH berapa dalam USD (8 desimal)
        return uint256 (answer * 1e10); // dijadikan wei
    }

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns(uint256)
    {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUSD = (ethAmount * ethPrice) / 1e18; // jatuhnya dalam wei juga

        return ethAmountInUSD;
    }
}