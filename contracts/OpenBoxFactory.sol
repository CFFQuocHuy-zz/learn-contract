// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "./interface/IBox.sol";
import "./interface/ISneaker.sol";
import "./interface/IBike.sol";
import "./interface/IPlaylist.sol";
import "./interface/IERC721Swappable.sol";

contract OpenBoxFactory is Ownable, Pausable {
    using Address for address;
    using SafeMath for uint256;
    using ECDSA for bytes32;
    // ========== CORE
    address public boxSmartContractAddress;
    address public sneakerSmartContractAddress;
    address public bikeSmartContractAddress;
    address public playlistSmartContractAddress;

    address public signerPublicKey;

    constructor() {}

    function setSignerPublicKey(address _signerPublicKey) public onlyOwner {
        signerPublicKey = _signerPublicKey;
    }

    function setSneakerSmartContractAddress(
        address _sneakerSmartContractAddress
    ) public onlyOwner {
        require(
            _sneakerSmartContractAddress.isContract(),
            "Revert: The sneaker contract address must be a deployed contract"
        );
        sneakerSmartContractAddress = _sneakerSmartContractAddress;
    }

    function setBikeSmartContractAddress(address _bikeSmartContractAddress)
        public
        onlyOwner
    {
        require(
            _bikeSmartContractAddress.isContract(),
            "Revert: The bike contract address must be a deployed contract"
        );
        bikeSmartContractAddress = _bikeSmartContractAddress;
    }

    function setPlaylistSmartContractAddress(
        address _playlistSmartContractAddress
    ) public onlyOwner {
        require(
            _playlistSmartContractAddress.isContract(),
            "Revert: The playlist contract address must be a deployed contract"
        );
        playlistSmartContractAddress = _playlistSmartContractAddress;
    }

    function setBoxSmartContractAddress(address _boxSmartContractAddress)
        public
        onlyOwner
    {
        require(
            _boxSmartContractAddress.isContract(),
            "Revert: The box contract address must be a deployed contract"
        );
        boxSmartContractAddress = _boxSmartContractAddress;
    }

    function openBox(
        uint256 _boxId,
        string memory _metadataId,
        bytes memory _signature
    ) external whenNotPaused returns (uint256 itemId) {
        address _sender = _msgSender();

        IBox _boxSmartContract = IBox(boxSmartContractAddress);
        uint8 _type = _getBoxType(_boxSmartContract, _boxId);

        address signer = keccak256(abi.encode(_boxId, _metadataId))
            .toEthSignedMessageHash()
            .recover(_signature);

        require(signerPublicKey == signer, "Revert: Invalid signature");

        IERC721 boxSmartContractERC721 = IERC721(boxSmartContractAddress);

        // Check owner of box
        require(
            boxSmartContractERC721.ownerOf(_boxId) == _sender,
            "Revert: Only the owner can open box"
        );

        // Check type of box
        require(
            _type == 1 || _type== 2 || _type == 3,
            "Revert: Box are invalid types"
        );

        // Burn box
        _boxSmartContract.burnBox(_sender, _boxId);
        if(_type == 1){
            itemId = ISneaker(sneakerSmartContractAddress).generateSneaker(_sender,_metadataId);
        }else if(_type == 2){
            itemId = IBike(sneakerSmartContractAddress).generateBike(_sender,_metadataId);
        }else if(_type == 3){
            itemId = IBike(sneakerSmartContractAddress).generateBike(_sender,_metadataId);
        }
        return itemId;
    }

    function _getBoxType(IBox _boxSmartContract, uint256 _boxId)
        public
        view
        returns (uint8)
    {
         uint8 boxType = _boxSmartContract.getTypeOfBox(_boxId);
         return boxType;
    }

    function pause() public onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() public onlyOwner whenPaused {
        _unpause();
    }
}
