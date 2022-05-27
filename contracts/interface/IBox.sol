// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBox {

    function mint(address _to, uint8 _type, string memory _metadataId) external returns (uint256);
    function burnBox(address _holder, uint256 _boxId) external;
    function getTypeOfBox(uint256 id) external view returns (uint8 boxType);

    event Created(
        address indexed to,
        uint256 indexed tokenId,
        string metadataId,
        uint8 boxType
    );

}