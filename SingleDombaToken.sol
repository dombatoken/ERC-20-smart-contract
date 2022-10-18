// SPDX-License-Identifier: MIT

/**
 /$$$$$$  /$$$$$$$   /$$$$$$  /$$$$$$$$ /$$$$$$ 
 /$$__  $$| $$__  $$ /$$__  $$|__  $$__//$$__  $$
| $$  \ $$| $$  \ $$| $$  \ $$   | $$  | $$  \ $$
| $$$$$$$$| $$$$$$$ | $$$$$$$$   | $$  | $$$$$$$$
| $$__  $$| $$__  $$| $$__  $$   | $$  | $$__  $$
| $$  | $$| $$  \ $$| $$  | $$   | $$  | $$  | $$
| $$  | $$| $$$$$$$/| $$  | $$   | $$  | $$  | $$
|__/  |__/|_______/ |__/  |__/   |__/  |__/  |__/
**/

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract DombaToken is ERC1155, Ownable {

    string public name;
    string public symbol;
    uint256 public mintPrice = 1 ether;
    uint256 public totalSupply;
    uint256 public maxSupply;
    bool  public isMintedEnabled;
    mapping(address => uint256) public mintedWallets;

    constructor()
        ERC1155("ipfs://QmfZ62wfAdhCTUpiscZcf9o7ggByJA1zZfVsbPgP4Jj5QG/{id}.json")
    {
        name = "Domba";
        symbol = "DBA";
        maxSupply = 0x989680;
    }

    function setURI(string memory newURI) onlyOwner{
        _setURI(newURI);
    }

    function toggleIsMintEnabled() public onlyOwner{
        isMintedEnabled = !isMintedEnabled;
    }

    function setMaxSupply(uint256 maxSupply_) external onlyOwner{
        maxSupply = maxSupply_;
    }

    function mint(address account, uint256 id, uint256 amount) external payable onlyOwner{
        require(isMintedEnabled, "Minting Is Not Enabled");
        require(msg.value == mintPrice, "Not Enough Ether");
        require(amount < maxSupply, "Ammount Exceeds Max Supply");
        require(maxSupply > totalSupply, "All Token Already Sold Out");

        mintedWallets[msg.sender]++;
        totalSupply = totalSupply + amount;
        toggleIsMintEnabled();

        _mint(account, id, amount, "");
    }

    function burn(address account, uint256 id, uint256 amount) public {
        require(msg.sender == account, "unauthorized account");
        totalSupply = totalSupply - amount;
        _burn(account, id, amount);
    }

    function uri(uint256 _tokenId) override public pure returns (string memory){
        return string(
            abi.encodePacked(
            "ipfs://QmfZ62wfAdhCTUpiscZcf9o7ggByJA1zZfVsbPgP4Jj5QG/",
            Strings.toString(_tokenId),
            ".json"
            )
        );
    }

    function withdraw(address payable recipient) external onlyOwner {
        uint256 balance = address(this).balance;
        recipient.transfer(balance);
    }
}
