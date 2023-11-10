// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "./MyERC20.sol";

contract XRMToken is MyERC20 {

    constructor(
        string memory name_, //xiaruoming
        string memory symbol_,//XRM
        uint256 totalSupply_ //10000000，000000也就是：10000000000000 发行量1000万 精度decimal为6
    ) MyERC20(name_, symbol_) {
        _mint(msg.sender, totalSupply_);
    }
}