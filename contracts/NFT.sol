
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721{
    constructor(string memory name, string memory symbol)  ERC721(name, symbol){
    }

    function mint(address to, uint tokenID) external {
        _mint(to,tokenID);
    }
}
