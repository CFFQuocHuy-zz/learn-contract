// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interface/IERC20Withdrawable.sol";
import "./Withdraw.sol";

contract ERC20Withdraw is IERC20Withdrawable, Withdraw  {
    using Counters for Counters.Counter;

    Counters.Counter private requestCounter;
    mapping(uint256 => address) public acceptedTokens;
    mapping(uint256 => Request) public requests;
    mapping(address => uint256) public activeRequests; // mapping from user's address to request id
    mapping(address => uint256[]) public histories; // mapping from user's address to request ids

    constructor() {
    }

    function setAcceptedToken(address _acceptedToken, uint256 _id) external onlyOwner {
        acceptedTokens[_id] = _acceptedToken;
    }

    function create(uint256 _amount, uint256 _tokenId) external whenNotPaused {
        require(_amount > 0, "Amount must be greater than 0");
        
        address _user = msg.sender;
        address acceptedToken = acceptedTokens[_tokenId];
        
        require(activeRequests[_user] == 0, "A request is already active");

        uint256 _requestId = getNextCounter();

        requests[_requestId] = Request({
            token: acceptedToken,
            user: _user,
            amount: _amount,
            createdAt: block.timestamp,
            withdrawnAt: 0
        });

        activeRequests[_user] = _requestId;

        emit Created(_requestId, acceptedToken, _user, _amount);
    }

    function claim(uint256 _requestId, bytes memory _signature)
        external
        whenNotPaused
        nonReentrant
    {
        address _user = msg.sender;
        require(activeRequests[_user] == _requestId, "Invalid request id");

        Request storage request = requests[_requestId];
        require(request.withdrawnAt == 0, "Already withdrawn");
        require(request.user == _user, "Invalid holder");

        request.withdrawnAt = block.timestamp;
        histories[_user].push(_requestId);
        delete activeRequests[_user];

        bytes32 hash = ECDSA.toEthSignedMessageHash(
            keccak256(abi.encode(_requestId, request.token, _user, request.amount))
        );
        address recovered = ECDSA.recover(hash, _signature);

        require(signer == recovered, "Invalid signature");

        SafeERC20.safeTransfer(IERC20(request.token), _user, request.amount);

        emit Withdrawn(_requestId, request.token, _user, request.amount);
    }

    function cancel(uint256 _requestId) external whenNotPaused {
        address _user = msg.sender;
        require(activeRequests[_user] == _requestId, "Invalid request id");

        Request storage request = requests[_requestId];
        require(request.withdrawnAt == 0, "Already withdrawn");
        require(request.user == _user, "Invalid holder");

        delete activeRequests[_user];

        emit Cancelled(_requestId, request.token, _user, request.amount);
    }

    function getActiveRequest(address _user) external view returns(uint256, Request memory) {
        uint256 requestId = activeRequests[_user];
        return (requestId, requests[requestId]);
    }

    function getHistory(address _user, uint256 _offset, uint256 _limit) external view returns(Request[] memory) {
        uint256[] memory _userHistories = histories[_user];
        uint256 _length = _userHistories.length;

        if (_length == 0 || _offset > _length - 1) {
            return new Request[](0);
        }

        uint256 _fetchable = _length - _offset;
        if (_limit > _fetchable) {
            _limit = _fetchable;
        }

        uint256 _start = _length - _offset;

        Request[] memory _userRequests = new Request[](_limit);
        uint256 _returnArrayIndex = 0;
        while(_returnArrayIndex < _limit) {
            _start--;
            _userRequests[_returnArrayIndex] = requests[_userHistories[_start]];
            _returnArrayIndex++;
        }

        return _userRequests;
    }

    function getNextCounter() internal returns(uint256) {
        requestCounter.increment();
        return requestCounter.current();
    }
}