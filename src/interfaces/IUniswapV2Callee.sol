// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;
//The code that denotes that the below is an interface that has 4 parameters - sender, amount of first and second token and additional data
interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external;
}
