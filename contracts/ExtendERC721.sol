// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IERC721Swappable.sol";

contract ExtendERC721 is ERC721Enumerable, IERC721Swappable, AccessControlEnumerable, Ownable {
    constructor(string memory name_, string memory symbol_)
        ERC721(name_, symbol_)
    {}

    string private baseURIExtended;
    // Optional mapping for metadata
    mapping(uint256 => string) private metadata;
    mapping(string => bool) executed;

    event ChangedMetadataId(uint256 indexed tokenId, string metadataId);

    function setBaseURI(string memory baseURI) external onlyOwner {
        baseURIExtended = baseURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURIExtended;
    }

    function setMetadata(uint256 tokenId, string memory _metadataId)
        external
        onlyOwner
    {
        _setMetadata(tokenId, _metadataId);
        emit ChangedMetadataId(tokenId, _metadataId);
    }

    function _setMetadata(uint256 tokenId, string memory metadataId) internal {
        require(_exists(tokenId), "ExtendERC721: query for nonexistent token");
        require(!executed[metadataId], "Already metadata id");
        metadata[tokenId] = metadataId;
        executed[metadataId] = true;
    }

    function getMetadata(uint256 tokenId) public view returns (string memory) {
        return metadata[tokenId];
    }

    function approveTokens(address to, uint256[] memory tokenIds) public {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];

            super.approve(to, tokenId);
        }
    }

    function walletOfOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(_owner);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }

        return tokensId;
    }

    function walletOfOwner(
        address _owner,
        uint256 _offset,
        uint256 _limit
    ) external override(IERC721Swappable) view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0 || _offset > tokenCount - 1) {
            return new uint256[](0);
        }

        uint256 fetchable = tokenCount - _offset;
        if (_limit > fetchable) {
            _limit = fetchable;
        }

        uint256 returnArrayIndex = 0;
        uint256[] memory tokensId = new uint256[](_limit);
        for (uint256 i = _offset; i < _offset + _limit; i++) {
            tokensId[returnArrayIndex] = tokenOfOwnerByIndex(_owner, i);
            returnArrayIndex++;
        }

        return tokensId;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlEnumerable, ERC721Enumerable, IERC165)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function burn(uint256 tokenId) public override(IERC721Swappable) {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721Burnable: caller is not owner nor approved"
        );

        delete metadata[tokenId];
        _burn(tokenId);
    }
    function _burnFrom(address _holder, uint256 _tokenId) internal {
        require(
            _isApprovedOrOwner(_holder, _tokenId),
            "ERC721Burnable: Holder is not owner nor approved"
        );

        delete metadata[_tokenId];
        _burn(_tokenId);
    }
}