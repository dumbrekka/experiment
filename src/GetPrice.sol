// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library GetPrice {
    function getLatestPrice(
        AggregatorV3Interface latestPrice
    ) internal view returns (uint) {
        (, int256 answer, , , ) = latestPrice.latestRoundData();
        // forge-lint: disable-next-line(unsafe-typecast)
        return uint(answer * 1e10);
    }

    function conversion(
        uint ethamount,
        AggregatorV3Interface latestPrice
    ) internal view returns (uint) {
        uint ethamountinusd = (ethamount * getLatestPrice(latestPrice)) / 1e18;
        return ethamountinusd;
    }
}
