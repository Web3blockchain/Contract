// Contract based on https://docs.openzeppelin.com/contracts/3.x/erc721
// SPDX-License-Identifier: MIT

 /*-------------------------------------------------------------------------   
          _____                   _____                   _____          
         /\    \                 /\    \                 /\    \         
        /::\    \               /::\    \               /::\    \        
       /::::\    \             /::::\    \             /::::\    \       
      /::::::\    \           /::::::\    \           /::::::\    \      
     /:::/\:::\    \         /:::/\:::\    \         /:::/\:::\    \     
    /:::/  \:::\    \       /:::/__\:::\    \       /:::/__\:::\    \    
   /:::/    \:::\    \     /::::\   \:::\    \     /::::\   \:::\    \   
  /:::/    / \:::\    \   /::::::\   \:::\    \   /::::::\   \:::\    \  
 /:::/    /   \:::\    \ /:::/\:::\   \:::\    \ /:::/\:::\   \:::\    \ 
/:::/____/     \:::\____/:::/  \:::\   \:::\____/:::/__\:::\   \:::\____\
\:::\    \      \::/    \::/    \:::\  /:::/    \:::\   \:::\   \::/    /
 \:::\    \      \/____/ \/____/ \:::\/:::/    / \:::\   \:::\   \/____/ 
  \:::\    \                      \::::::/    /   \:::\   \:::\    \     
   \:::\    \                      \::::/    /     \:::\   \:::\____\    
    \:::\    \                     /:::/    /       \:::\   \::/    /    
     \:::\    \                   /:::/    /         \:::\   \/____/     
      \:::\    \                 /:::/    /           \:::\    \         
       \:::\____\               /:::/    /             \:::\____\        
        \::/    /               \::/    /               \::/    /        
         \/____/                 \/____/                 \/____/         
                                                                     
-------------------------------------------------------------------------------- */
                                                                    
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract CAEMeta is ERC721Enumerable, Ownable {
    using Strings for uint256;

    bool public _isSaleActive = true;

    // Constants
    uint256 public mintPrice = 0 ether;
    uint256 public maxBalance = 1;
    uint256 public maxMint = 1;

    string baseURI;
    string public notRevealedUri;
    string public baseExtension = ".json";

    mapping(uint256 => string) private _tokenURIs;
    mapping(address => uint256) whitelistt;

    constructor(string memory initBaseURI, string memory initNotRevealedUri)
        ERC721("CAE certificate test", "JTJT")
    {
        setBaseURI(initBaseURI);
        setNotRevealedURI(initNotRevealedUri);
    }

    function mintCAEMeta() public payable {
        require(
            checkwhitelist(),
            "you are not in whitelist"
        );

        require(_isSaleActive, "Sale must be active to mint CAEMetas");
        
        require(
            balanceOf(msg.sender) + 1 <= maxBalance,
            "You have already mint"
        );

        require(
            mintPrice <= msg.value,
            "Not enough Matic sent"
        );

        _mintCAEMeta(1);
    }

    function _mintCAEMeta(uint256 tokenQuantity) internal {
        for (uint256 i = 0; i < tokenQuantity; i++) {
                _safeMint(msg.sender, whitelistt[msg.sender]);
        }
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }

        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
      
        return
            string(abi.encodePacked(base, tokenId.toString(), baseExtension));
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    //only owner
    function flipSaleActive() public onlyOwner {
        _isSaleActive = !_isSaleActive;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function withdraw(address to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(to).transfer(balance);
    }

    //whitelist
    function addUser(address _addressToWhitelist, uint256 s_todenid) public onlyOwner {
        whitelistt[_addressToWhitelist] = s_todenid;
    }

    modifier CheckisnotinWhitelist(address _address){
        require(whitelistt[msg.sender] != 0, "you are not in whitelisted");
        _;
    }

    function checkwhitelist() public view CheckisnotinWhitelist(msg.sender) returns(bool){
       return (true);
    }

    function verifyUser(address _whitelistedAddress) public view returns(uint256) {
      uint256 s_id = whitelistt[_whitelistedAddress];
      return s_id;

    }
}
