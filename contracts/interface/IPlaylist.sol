// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPlaylist {

    function mint(address _to, string memory _metadataId) external returns (uint256);
    function generatePlaylist(address _to, string memory _metadataId) external returns (uint256);

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids
    ) external;

    event Created(
        address indexed to,
        uint256 indexed tokenId,
        string metadataId
    );

}