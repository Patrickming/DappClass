// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract NFTMarket {
    IERC20  = erc20;
    IERC721 = erc721;
    struct Order {
        address seller;
        uint256 tokenId;
        uint256 price;
    }
    mapping(uint256 => Order) public orderOfId;
    Order[] orders;
    constructor (address _erc20, address _erc721){
        erc20 = IERC20(_erc20);
        erc721 = IERC721(_erc721);
    }

    function buy(uint256 _tokenId) 
}