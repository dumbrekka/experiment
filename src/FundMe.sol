// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {GetPrice} from "./GetPrice.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error brokie();

contract FundMe {
    using GetPrice for uint;
    address private immutable I_OWNER;
    AggregatorV3Interface private ethPrice;

    constructor(address latestPrice) {
        I_OWNER = msg.sender;
        ethPrice = AggregatorV3Interface(latestPrice);
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        if (msg.sender != I_OWNER) {
            revert brokie();
        }
    }

    uint public constant PRICE_USD = 0.0001 * 1e18;
    address[] private s_fudders;
    mapping(address broke => uint lost) private s_loosers;

    function fund() public payable {
        require(msg.value.conversion(ethPrice) >= PRICE_USD, "no, bozzo");
        s_fudders.push(msg.sender);
        s_loosers[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint index; index < s_fudders.length; index++) {
            address fudder = s_fudders[index];
            s_loosers[fudder] = 0;
            s_fudders = new address[](0);
            (bool greatsuccess, ) = payable(msg.sender).call{
                value: address(this).balance
            }("");
            require(greatsuccess, "gg");
        }
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function getInvestAmount(address poor) external view returns (uint) {
        return s_loosers[poor];
    }

    function getPoor(uint index) external view returns (address) {
        return s_fudders[index];
    }

    function getOwner() external view returns (address) {
        return I_OWNER;
    }
}
