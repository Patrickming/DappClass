// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarket is ReentrancyGuard {
    struct MarketItem {
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
        bool listed;
    }

    MarketItem[] public items;

    ERC20 public token;

    event MarketItemCreated (
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold,
        bool listed
    );

    constructor(address _token) {
        token = ERC20(_token);
    }

    function getMarketItem(uint itemId)
        public 
        view 
        returns (MarketItem memory)
    {
        return items[itemId];
    }

    function getTotalMarketItems()
        public 
        view 
        returns (uint)
    {
        return items.length;
    }

    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(price > 0, "Price must be at least 1 wei");

        items.push(
            MarketItem(
                items.length,
                nftContract,
                tokenId,
                payable(msg.sender),
                payable(address(0)),
                price,
                false,
                true
            )
        );

        ERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit MarketItemCreated(
            items.length - 1,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            false,
            true
        );
    }

    function createMarketSale(address nftContract, uint256 itemId)
        public
        payable
        nonReentrant
    {
        uint price = items[itemId].price;
        uint tokenId = items[itemId].tokenId;
        require(token.balanceOf(msg.sender) >= price, "You do not have enough tokens");
        require(items[itemId].listed, "Item is not listed currently");

        token.transferFrom(msg.sender, items[itemId].seller, price);
        ERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        items[itemId].owner = payable(msg.sender);
        items[itemId].sold = true;
        items[itemId].listed = false;

        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            items[itemId].seller,
            msg.sender,
            price,
            true,
            false
        );
    }

    function cancelMarketItem(address nftContract, uint256 itemId)
        public
        nonReentrant
    {
        require(items[itemId].seller == msg.sender, "You are not the seller");
        require(!items[itemId].sold, "Item is already sold");
        require(items[itemId].listed, "Item is not listed currently");

        ERC721(nftContract).transferFrom(address(this), msg.sender, items[itemId].tokenId);
        items[itemId].listed = false;

        emit MarketItemCreated(
            itemId,
            nftContract,
            items[itemId].tokenId,
            msg.sender,
            items[itemId].owner,
            items[itemId].price,
            items[itemId].sold,
            false
        );
    }
}
