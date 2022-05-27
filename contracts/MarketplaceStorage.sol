// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract MarketplaceStorage {
  struct Order {
    // Order ID
    bytes32 id;
    // Owner of the NFT
    address seller;
    // NFT registry address
    address nftAddress;
    // Price (in wei) for the published item
    uint256 price;
  }

  // From ERC721 registry assetId to Order (to avoid asset collision)
  mapping (address => mapping(uint256 => Order)) public orderByAssetId;

  uint256 public ownerCutPerMillion;
  uint256 public publicationFeeInWei;

  bytes4 public constant ERC721_Interface = bytes4(0x80ac58cd);

  // EVENTS
  event PlaceOrder(
    bytes32 id,
    address indexed seller,
    address indexed nftAddress,
    uint256 indexed assetId,
    uint256 priceInWei
  );
  event FillOrder(
    bytes32 id,
    address indexed buyer,
    uint256 totalPrice
  );
  event CancelOrder(
    bytes32 id
  );

  event OpenBox(uint256 boxId);

  event ChangedPublicationFee(uint256 publicationFee);
  event ChangedOwnerCutPerMillion(uint256 ownerCutPerMillion);
}