// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/AggregatorV3Interface.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address priceFeed;
    }

    NetworkConfig public activeNetwork;

    constructor() {
        if (block.chainid == 1) {
            activeNetwork = getEthereumEthConfig();
        } else if (block.chainid == 8453) {
            activeNetwork = getBaseEthConfig();
        } else {
            activeNetwork = getorcreateAnvilEthConfig();
        }
    }

    function getBaseEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory baseConfig = NetworkConfig({
            priceFeed: 0x71041dddad3595F9CEd3DcCFBe3D1F4b0a16Bb70
        });
        return baseConfig;
    }

    function getEthereumEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethereumConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethereumConfig;
    }

    function getorcreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetwork.priceFeed != address(0)) {
            return activeNetwork;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPrice = new MockV3Aggregator(8, 3000e8);
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPrice)
        });
        return anvilConfig;
    }
}
