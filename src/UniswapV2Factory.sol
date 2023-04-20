// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

//The contract is named "UniswapV2Factory" and it has a SPDX-License-Identifier of "Unlicense", which means it is released into the public domain and can be used freely without any restrictions.

import "./UniswapV2Pair.sol";
import "./interfaces/IUniswapV2Pair.sol";

//The factory contract is responsible for creating new Uniswap pairs, which are contracts that represent a trading pair of two tokens.

contract UniswapV2Factory {
    error IdenticalAddresses();
    error PairExists();
    error ZeroAddress();

//Events in Solidity are used to emit data that can be logged on the blockchain and can be used to notify external applications about changes in the contract state.
//The contract emits an event called "PairCreated" with the indexed parameters "token0", "token1", "pair", and "allPairs.length"
   
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

//The contract defines a mapping called "pairs" which maps a pair of token addresses (token0 and token1) to the address of the corresponding Uniswap pair contract. The contract also has a dynamic array called "allPairs" which stores the addresses of all created Uniswap pairs.
   
    mapping(address => mapping(address => address)) public pairs;
    address[] public allPairs;

//The contract has a function called "createPair" which takes two token addresses, "tokenA" and "tokenB", as input and creates a new Uniswap pair contract for the given tokens. The function is marked as "public", which means it can be called from any external contract or account.
  
    function createPair(address tokenA, address tokenB)
        public
        returns (address pair)
    {
        // if "tokenA" and "tokenB" are not the same token address. If they are the same, it reverts the transaction with the "IdenticalAddresses()" error.
        if (tokenA == tokenB) revert IdenticalAddresses();

//the code determines the token with a lower address value as "token0" and the token with a higher address value as "token1". This is done to ensure that the same pair of tokens is always represented by the same Uniswap pair contract, regardless of the order of the input tokens.
      
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);

//The code then checks if "token0" is not the zero address. If it is, it reverts the transaction with the "ZeroAddress()" error.
 
        if (token0 == address(0)) revert ZeroAddress();

//The code further checks if a Uniswap pair contract already exists for the given pair of tokens in the "pairs" mapping. If it does, it reverts the transaction with the "PairExists()" error.
  
        if (pairs[token0][token1] != address(0)) revert PairExists();

//If all the checks pass, the code creates a new Uniswap pair contract using the "create2" assembly function. The "create2" function creates a new contract using a salted deterministic deployment scheme, which ensures that the same pair of tokens always results in the same contract address. The bytecode of the UniswapV2Pair contract is used for the creation, along with the calculated salt value.
 
       bytes memory bytecode = type(UniswapV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

//calling initialize function to initialize the contract

        IUniswapV2Pair(pair).initialize(token0, token1);

        pairs[token0][token1] = pair;
        pairs[token1][token0] = pair;
        allPairs.push(pair);

        emit PairCreated(token0, token1, pair, allPairs.length);
    }
}
