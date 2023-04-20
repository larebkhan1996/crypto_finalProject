// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;
//Below is an interface for uniswap V2 pair and there are total 6 functions inside of the interface
interface IUniswapV2Pair {

    // This is a function declaration that specifies the signature of the initialize function. It takes two address parameters:
    function initialize(address, address) external;
    //This is a function declaration that specifies the signature of the getReserves function. It takes no parameters and returns three values of type uint112, uint112, and uint32 respectively. This function is used to get the current reserves of the two tokens in the Uniswap V2 pair.
    function getReserves()external returns (uint112, uint112,uint32);

    function transferFrom(address, address,uint256) external returns (bool);

    function swap(uint256,uint256,address, bytes calldata) external;
//This is a function declaration that specifies the signature of the mint function.
    function mint(address) external returns (uint256);

    function burn(address) external returns (uint256, uint256);


}
