// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;
//Below is an interface which has 2 functions pairts and createPail in which the first one is pure and external and the other is only external
interface IUniswapV2Factory {
    function pairs(address, address) external pure returns (address);

    function createPair(address, address) external returns (address);
}
