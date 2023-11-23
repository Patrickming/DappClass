// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyERC20 is ERC20, ERC20Burnable, Ownable {
    constructor(
        address initialOwner
    ) ERC20("XiaRuoming", "XRM") Ownable(initialOwner) {
        _mint(msg.sender, 1 * 10 ** 8 * 10 ** 18);//固定18精度
    }
}
