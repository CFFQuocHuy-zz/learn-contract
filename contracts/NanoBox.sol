// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./ExtendERC721.sol";
import "./interface/IBox.sol";

contract Box is IBox, Ownable, ExtendERC721 {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    bytes32 public constant MINT_ROLE = keccak256("MINT_ROLE");
    bytes32 public constant BURN_ROLE = keccak256("BURN_ROLE");

    // 1: Sneaker , 2: Bike, 3: Playlist
    mapping(uint256 => uint8) public typeOfBox;
    mapping(uint8 => uint256[]) public boxByType;

    constructor()ExtendERC721("Nanomix Box", "LUCKY BOX NFT")
    {}

    modifier allowMint() {
        address _sender = _msgSender();
        require(
            owner() == _sender || hasRole(MINT_ROLE, _sender),
            "Must have mint role"
        );
        _;
    }

    modifier allowBurn() {
        address _sender = _msgSender();
        require(
            owner() == _sender || hasRole(BURN_ROLE, _sender),
            "Must have burn role"
        );
        _;
    }

    function setupMintRoleAddress(address _minter) public onlyOwner {
        _setupRole(MINT_ROLE, _minter);
    }

    function setupBurnRoleAddress(address _burner) public onlyOwner {
        _setupRole(BURN_ROLE, _burner);
    }

    // Mint a new box
    function mint(
        address _to,
        uint8 _type,
        string memory _metadataId
    ) external override(IBox) allowMint returns (uint256) {
        require(shouldValidType(_type), "Revert: Invalid Type Of Box");
        require(
            shouldValidMetadata(_metadataId),
            "Revert: Invalid MetadataId Of Box"
        );
        uint256 newBoxId = increment();

        _mint(_to, newBoxId);
        _setMetadata(newBoxId, _metadataId);
        typeOfBox[newBoxId] = _type;
        boxByType[_type].push(newBoxId);
        emit Created(_to, newBoxId, _metadataId, _type);
        return newBoxId;
    }

    function shouldValidMetadata(string memory _metadata)
        internal
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((_metadata))) !=
            keccak256(abi.encodePacked(("0"))));
    }

    function shouldValidType(uint8 _type) internal pure returns (bool) {
        if (_type == 1 || _type == 2 || _type == 3) return true;
        return false;
    }

    function getTypeOfBox(uint256 _boxId) public view override returns (uint8) {
        require(_exists(_boxId), "ExtendERC721: query for nonexistent token");
        return typeOfBox[_boxId];
    }

    function burnBox(address _holder, uint256 _boxId) external override allowBurn {
        _burnFrom(_holder, _boxId);
    }

    function increment() internal returns (uint256) {
        _tokenIds.increment();
        return _tokenIds.current();
    }
}
