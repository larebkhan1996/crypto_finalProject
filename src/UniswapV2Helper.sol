// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;
//this file is a helper function for all the contracts
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Pair.sol";
import {UniswapV2Pair} from "./UniswapV2Pair.sol";

library UniswapV2Helper {
    error InsufficientAmount();
    error InsufficientLiquidity();
    error InvalidPath();

//This function takes the addresses of a UniswapV2Factory contract, and two tokens (tokenA and tokenB) as input, and returns the reserves of the token pair in the specified factory. It uses the pairFor function to get the address of the UniswapV2Pair contract for the given token pair, and then calls the getReserves function on that contract to get the reserves of tokenA and tokenB.
    
    function getReserves(address factoryAddress,address tokenA,address tokenB) public returns (uint256 reserveA, uint256 reserveB) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(
            pairFor(factoryAddress, token0, token1)
        ).getReserves();
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

//This function takes the amount of an input token, and the reserves of the input and output tokens, and calculates the expected amount of the output token that will be received after the swap. It performs a simple multiplication and division calculation based on the UniswapV2 formula.
   
    function quote(uint256 amountIn,uint256 reserveIn,uint256 reserveOut) public pure returns (uint256 amountOut) {
        if (amountIn == 0) revert InsufficientAmount();
        if (reserveIn == 0 || reserveOut == 0) revert InsufficientLiquidity();

        return (amountIn * reserveOut) / reserveIn;
    }

 //This internal function takes two token addresses as input and returns them in sorted order. It compares the two token addresses and returns them in ascending order.

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1)
    {
        return tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }
//This internal function takes the addresses of a UniswapV2Factory contract, and two tokens (tokenA and tokenB) as input, and calculates the address of the UniswapV2Pair contract for the given token pair. It uses keccak256 hash function to calculate the address based on the factory address, sorted token addresses, and the creation code of the UniswapV2Pair contract.

    function pairFor(address factoryAddress, address tokenA, address tokenB) internal pure returns (address pairAddress) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pairAddress = address(uint160(uint256(keccak256(abi.encodePacked(
                            hex"ff",
                            factoryAddress,
                            keccak256(abi.encodePacked(token0, token1)),
                            keccak256(type(UniswapV2Pair).creationCode)
                        )
                    )
                )
            )
        );
    }

    //This function takes the desired amount of output token, and the reserves of the input and output tokens, and calculates the amount of input token required for the swap. It performs a calculation based on the UniswapV2 formula, taking into account the 0.3% swap fee.


    function getAmountOut(uint256 amountIn,uint256 reserveIn,uint256 reserveOut) public pure returns (uint256) {
        if (amountIn == 0) revert InsufficientAmount();
        if (reserveIn == 0 || reserveOut == 0) revert InsufficientLiquidity();

        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * 1000) + amountInWithFee;

        return numerator / denominator;
    }

    //This function takes the address of a UniswapV2Factory contract, an input amount, and an array of token addresses representing the swap path, and calculates the expected amounts of output tokens for each step along the swap path. It uses the getReserves and getAmountOut functions to calculate the amounts for each step.

    function getAmountsOut(address factory,uint256 amountIn,address[] memory path) public returns (uint256[] memory) {
        if (path.length < 2) revert InvalidPath();
        uint256[] memory amounts = new uint256[](path.length);
        amounts[0] = amountIn;

        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserve0, uint256 reserve1) = getReserves(
                factory,
                path[i],
                path[i + 1]
            );
            amounts[i + 1] = getAmountOut(amounts[i], reserve0, reserve1);
        }

        return amounts;
    }

    //This function takes the desired amount of input token, and the reserves of the input and output tokens, and calculates the amount of output token that will be received after the swap. It performs a calculation based on the UniswapV2 formula, taking into account the 0.3% swap fee.

    function getAmountIn(uint256 amountOut,uint256 reserveIn,uint256 reserveOut) public pure returns (uint256) {
        if (amountOut == 0) revert InsufficientAmount();
        if (reserveIn == 0 || reserveOut == 0) revert InsufficientLiquidity();

        uint256 numerator = reserveIn * amountOut * 1000;
        uint256 denominator = (reserveOut - amountOut) * 997;

        return (numerator / denominator) + 1;
    }

//This function takes the address of a UniswapV2Factory contract, an output amount, and an array of token addresses representing the swap path, and calculates the required amounts of input tokens for each step along the swap path. It uses the getReserves and getAmountIn functions to calculate the amounts for each step.

    function getAmountsIn(address factory,uint256 amountOut,address[] memory path) public returns (uint256[] memory) {
        if (path.length < 2) revert InvalidPath();
        uint256[] memory amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;

        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserve0, uint256 reserve1) = getReserves(
                factory,
                path[i - 1],
                path[i]
            );
            amounts[i - 1] = getAmountIn(amounts[i], reserve0, reserve1);
        }

        return amounts;
    }
}
