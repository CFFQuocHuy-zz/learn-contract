// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Withdrawable {
    struct Request {
        address token;
        address user;
        uint256 amount;
        uint256 createdAt;
        uint256 withdrawnAt;
    }

    event Created(
        uint256 request,
        address indexed token,
        address indexed user,
        uint256 amount
    );

    event Cancelled(
        uint256 request,
        address indexed token,
        address indexed user,
        uint256 amount
    );

    event Withdrawn(
        uint256 request,
        address indexed token,
        address indexed user,
        uint256 amount
    );
}
