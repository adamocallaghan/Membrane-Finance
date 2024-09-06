// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStableCoin {
    function mint(address, uint256) external;
    function transferFrom(address, address, uint256) external;
}
