// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./erc20.sol";
import "./erc721.sol";

error PriceNotMet(address nftAddress, uint256 tokenId, uint256 price);
error ItemNotForSale(address nftAddress, uint256 tokenId);
error NotListed(address nftAddress, uint256 tokenId);
error AlreadyListed(address nftAddress, uint256 tokenId);
error NoProceeds();
error NotOwner();
error NotApprovedForMarketplace();
error PriceMustBeAboveZero();

//用eth购买nft
contract NftMarketplace is ReentrancyGuard {

    // State Variables

    //NFT contract address => Token ID => Listing(price,seller)
    mapping(address => mapping(uint256 => Listing)) private s_listings;
    //seller address => profit
    mapping(address => uint256) private s_proceeds;
    struct Listing {
        // seller address and nft prize
        uint256 price;
        address seller;
    }
    // Event

    //record listingItem
    event ItemListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );
    //Record seller
    event ItemCanceled(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId
    );
    //Record buyer
    event ItemBought(
        address indexed buyer,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );


    

    // Function modifiers

    //check this nft is not listed
    modifier notListed(
        address nftAddress,
        uint256 tokenId,
        address owner
    ) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        if (listing.price > 0) {
            revert AlreadyListed(nftAddress, tokenId);
        }
        _;
    }
    //Check whether the listing person has this item
    modifier isOwner(
        address nftAddress,
        uint256 tokenId,
        address spender
    ) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (spender != owner) {
            revert NotOwner();
        }
        _;
    }
    //check this nft is listed
    modifier isListed(address nftAddress, uint256 tokenId) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        if (listing.price <= 0) {
            revert NotListed(nftAddress, tokenId);
        }
        _;
    }

    // Function

    //function to list an nft
    function listItem(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    )
        external
        notListed(nftAddress, tokenId, msg.sender)
        isOwner(nftAddress, tokenId, msg.sender)
    {
        if (price <= 0) {
            revert PriceMustBeAboveZero();
        }
        IERC721 nft = IERC721(nftAddress);
        if (nft.getApproved(tokenId) != address(this)) {
            revert NotApprovedForMarketplace();
        }
        s_listings[nftAddress][tokenId] = Listing(price, msg.sender);
        emit ItemListed(msg.sender, nftAddress, tokenId, price);
    }

    //function to cancel a listing
    function cancelListing(
        address nftAddress,
        uint256 tokenId
    )
        external
        isOwner(nftAddress, tokenId, msg.sender)
        isListed(nftAddress, tokenId)
    {
        delete (s_listings[nftAddress][tokenId]);
        emit ItemCanceled(msg.sender, nftAddress, tokenId);
    }

    //function to buy an item
    function buyItem(
        address nftAddress,
        uint256 tokenId
    ) external payable isListed(nftAddress, tokenId) nonReentrant {
        Listing memory listedItem = s_listings[nftAddress][tokenId];
        if (msg.value < listedItem.price) {
            revert PriceNotMet(nftAddress, tokenId, listedItem.price);
        }

        s_proceeds[listedItem.seller] += msg.value;
        delete (s_listings[nftAddress][tokenId]);
        IERC721(nftAddress).safeTransferFrom(
            listedItem.seller,
            msg.sender,
            tokenId
        );
        emit ItemBought(msg.sender, nftAddress, tokenId, listedItem.price);
    }

    //function to update the nft price
    function updateListing(
        address nftAddress,
        uint256 tokenId,
        uint256 newPrice
    )
        external
        isListed(nftAddress, tokenId)
        nonReentrant
        isOwner(nftAddress, tokenId, msg.sender)
    {
        if (newPrice == 0) {
            revert PriceMustBeAboveZero();
        }

        s_listings[nftAddress][tokenId].price = newPrice;
        emit ItemListed(msg.sender, nftAddress, tokenId, newPrice);
    }

    //function to withdraw the proceeds
    function withdrawProceeds() external {
        uint256 proceeds = s_proceeds[msg.sender];
        if (proceeds <= 0) {
            revert NoProceeds();
        }
        s_proceeds[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: proceeds}("");
        require(success, "Transfer failed");
    }

    //---------------Utility functions-----------------

    //function to check the listed nft
    function getListing(
        address nftAddress,
        uint256 tokenId
    ) external view returns (Listing memory) {
        return s_listings[nftAddress][tokenId];
    }
    //get profit you have
    function getProceeds(address seller) external view returns (uint256) {
        return s_proceeds[seller];
    }
}