//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts@4.4.2/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.4.2/access/Ownable.sol";

contract RedirectQR is ERC721, Ownable {
    uint public MAX_SUPPLY = 10;
    uint public MINT_PRICE = 5000000000000000;
    string private NAME = "RedirectQR";
    string private SYMBOL = "RQR";
    string private base_uri = "";

    uint total_supply = 0;

    string public default_qr_redirect_url = "https://en.wikipedia.org/wiki/QR_code";

    mapping(uint=>string) mapRedirectUrl;

    constructor() ERC721(NAME, SYMBOL) {
    }

    function withdrawAmount() external onlyOwner {
        (bool success,) = msg.sender.call{value: address(this).balance}("");
        require(success, "Not able to withdraw funds");
    }

    function _QrMint(string memory url) private {
        uint tokenId = total_supply + 1;
        require(total_supply < MAX_SUPPLY, "All the QR codes were minted.");
        total_supply++;
        _safeMint(msg.sender, tokenId);
        if(bytes(url).length == 0) {
            mapRedirectUrl[tokenId] = default_qr_redirect_url;
        } else {
            mapRedirectUrl[tokenId] = url;
        }
    }

    function setRedirectUrl(uint tokenId, string memory url) public {
        require(_exists(tokenId), "Invalid TokenId");
        require (ownerOf(tokenId) == msg.sender, "Only owner of token can change the redirect url");
        mapRedirectUrl[tokenId] = url;
    }

    function getRedirectUrl(uint tokenId) view public returns (string memory) {
        require(_exists(tokenId), "Invalid TokenId");
        return mapRedirectUrl[tokenId];
    }

    //Only single NFT mint
    function QrMint(string memory url) payable public {
        require(msg.value >= MINT_PRICE, "Insufficient amount. Mint price is .005 eth");
        _QrMint(url);        
    }

    //TODO Need to remove this function as all data is on IPFS at once.
    function setBaseURI(string memory uri) public onlyOwner {
        base_uri = uri;
    }

    function _baseURI() internal override view returns (string memory) {
        return base_uri;
    }
}
