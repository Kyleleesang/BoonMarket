// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Refungible is ERC20{
    uint public nftSharePrice;
    uint public nftShareSupply;
    uint public nftSaleEnd;
//ID for the specific NFT so it can be idenfitied
    uint public nftID;
    IERC721 public nft;
    IERC20 public dai;
    address public NFTadmin;

    constructor(
        string memory _name, 
        string memory _symbol, 
        address _nftAddress, 
        uint _nftID, 
        uint _nftSharePrice, 
        uint _nftShareSupply,
        address _daiAddress
    ) ERC20(_name, _symbol) {
        nftID = _nftID;
        nft = IERC721(_nftAddress);
        nftSharePrice = _nftSharePrice;
        nftShareSupply = _nftShareSupply;
        dai = IERC20(_daiAddress);
        NFTadmin = msg.sender;
    }
//you have to send the NFT to the admin smart contract
    function startSale() external {
        require (msg.sender == NFTadmin, "Only the admin can do this");
        nft.transferFrom(msg.sender, address(this), nftID);
        nftSaleEnd = block.timestamp + 7 * 86400;
    }
    
    function buyNFT(uint shareAmount) external {
        //you need to check to see if the sale has ended before you buy
        require (nftSaleEnd > 0, "The sale hasn't started yet");
        require(block.timestamp <= nftSaleEnd, "The sale has finished");
        //check if the total supply plus the amount they wants to buy is left than the total shares
        require(totalSupply() + shareAmount <= nftShareSupply, "Not enough shares left to buy");
        uint daiAmount = shareAmount * nftSharePrice;
        dai.transferFrom(msg.sender, address(this), daiAmount);
        //mint new tokens to represent his share of the NFT
        _mint(msg.sender, shareAmount);
    }
    //function called by the admin to withdraw the dai and the remaining shares
    function withdrawProfits() external {
        require (msg.sender == NFTadmin, "Only the admin can do this");
        require (block.timestamp > nftSaleEnd, "Sale is not done yet");
        //point to the dai smart contract and figure out the balance of the admin
        uint daiBalance = dai.balanceOf(address(this));
        if (daiBalance > 0) {
            dai.transfer(NFTadmin, daiBalance);
        }
        //send the balance of the NFTshares that arent sold to the investors 
        uint unsoldShareBalance = nftShareSupply - totalSupply();
        if (unsoldShareBalance > 0){
            _mint(NFTadmin, unsoldShareBalance);
        }
    }

}
