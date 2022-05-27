// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface IERC721Swappable is IERC721Enumerable {
    function burn(uint256 _tokenId) external;
    function walletOfOwner(
        address _owner,
        uint256 _offset,
        uint256 _limit
    ) external view returns (uint256[] memory);
}