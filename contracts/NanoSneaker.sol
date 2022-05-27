// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ExtendERC721.sol";
import "./interface/ISneaker.sol";

contract Sneaker is ISneaker, Ownable, ExtendERC721 {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    bytes32 public constant MINT_ROLE = keccak256("MINT_ROLE");
    bytes32 public constant GENERATE_SNEAKER_FACTORY_ROLE =
        keccak256("GENERATE_SNEAKER_FACTORY_ROLE");

    constructor() ExtendERC721("Nanomix Sneaker", "SNEAKER NFT") {}

    modifier allowMint() {
        address _sender = _msgSender();
        require(hasRole(MINT_ROLE, _sender) || _sender == owner(), "Revert: Must have mint role");
        _;
    }

    modifier isGenerateSneakerFactory() {
        require(
            hasRole(GENERATE_SNEAKER_FACTORY_ROLE, _msgSender()),
            "Revert: Must own sneaker box"
        );
        _;
    }

    function setupMintRoleAddress(address _minter) public onlyOwner {
        _setupRole(MINT_ROLE, _minter);
    }

    // Mint a new sneaker
    function mint(address _to, string memory _metadataId)
        external
        override(ISneaker)
        allowMint
        returns (uint256)
    {
        require(
            shouldValidMetadata(_metadataId),
            "Revert: Invalid MetadataId Of Sneaker"
        );
        uint256 newSneakerId = increment();

        _mint(_to, newSneakerId);
        _setMetadata(newSneakerId, _metadataId);
        emit Created(_to, newSneakerId, _metadataId);
        return newSneakerId;
    }

    function shouldValidMetadata(string memory _metadata)
        internal
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((_metadata))) !=
            keccak256(abi.encodePacked(("0"))));
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids
    ) public override {
        uint256 length = ids.length;

        for (uint256 i = 0; i != length; i++) {
            uint256 sneakerId = ids[i];

            super.safeTransferFrom(from, to, sneakerId);
        }
    }

    function setGenerateSneakerFactoryAddress(address _generator) external onlyOwner {
        _setupRole(GENERATE_SNEAKER_FACTORY_ROLE, _generator);
    }

    function generateSneaker(address _to, string memory _metadataId)
        external
        override(ISneaker)
        isGenerateSneakerFactory
        returns (uint256)
    {
        uint256 newSneakerId = increment();

        _mint(_to, newSneakerId);
        _setMetadata(newSneakerId, _metadataId);

        emit Created(_to, newSneakerId, _metadataId);

        return newSneakerId;
    }

    function increment() internal returns (uint256) {
        _tokenIds.increment();
        return _tokenIds.current();
    }
}
