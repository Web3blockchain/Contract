// Contract based on https://docs.openzeppelin.com/contracts/3.x/erc721
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract CAEMeta is ERC721Enumerable, Ownable {
    using Strings for uint256;

    bool public _isSaleActive = true;
    // bool public _revealed = false;

    // Constants
    uint256 public constant MAX_SUPPLY = 10;
    uint256 public mintPrice = 0 ether;
    uint256 public maxBalance = 1;
    uint256 public maxMint = 1;

    string baseURI;
    string public notRevealedUri;
    string public baseExtension = ".json";


    mapping(address => bool) whitelistedAddresses;
    mapping(uint256 => string) private _tokenURIs;
    mapping(address => uint256) whitelistt;

    constructor(string memory initBaseURI, string memory initNotRevealedUri)
        ERC721("CAECAE Meta", "NM")
    {
        setBaseURI(initBaseURI);
        setNotRevealedURI(initNotRevealedUri);
    }

    function mintCAEMeta() public payable {
        require(
            totalSupply() + 1 <= MAX_SUPPLY,
            "Sale would exceed max supply"
        );
        require(
            callisWhitelisted(),
            "you are not in whitelist"
        );

        require(_isSaleActive, "Sale must be active to mint CAEMetas");
        
        require(
            balanceOf(msg.sender) + 1 <= maxBalance,
            "You have already mint"
        );

        require(
            mintPrice <= msg.value,
            "Not enough ether sent"
        );

        _mintCAEMeta(1);
    }

    function _mintCAEMeta(uint256 tokenQuantity) internal {
        for (uint256 i = 0; i < tokenQuantity; i++) {
            uint256 mintIndex = totalSupply();
            if (totalSupply() < MAX_SUPPLY) {
                _safeMint(msg.sender, mintIndex);
            }
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

        // if (_revealed == false) {
        //     return notRevealedUri;
        // }

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
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

    // function flipReveal() public onlyOwner {
    //     _revealed = !_revealed;
    // }

    // function setMintPrice(uint256 _mintPrice) public onlyOwner {
    //     mintPrice = _mintPrice;
    // }

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

    function setMaxBalance(uint256 _maxBalance) public onlyOwner {
        maxBalance = _maxBalance;
    }

    function setMaxMint(uint256 _maxMint) public onlyOwner {
        maxMint = _maxMint;
    }

    function withdraw(address to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(to).transfer(balance);
    }

    //whitelist
    modifier isWhitelisted(address _address) {
        require(whitelistedAddresses[_address], "Whitelist: You need to be whitelisted");
      _;
    }

    function addUser(address _addressToWhitelist) public onlyOwner {
        whitelistedAddresses[_addressToWhitelist] = true;
    }

    // function addUser2(address _addressToWhitelist, uint256 _ipfs) public onlyOwner {
    //     whitelistt[_addressToWhitelist] = _ipfs;
    // }

    function verifyUser(address _whitelistedAddress) public view returns(bool) {
      bool userIsWhitelisted = whitelistedAddresses[_whitelistedAddress];
      return userIsWhitelisted;
    }

    function callisWhitelisted() public view isWhitelisted(msg.sender) returns(bool){
      return (true);
    }

    // modifier CheckisnotinWhitelist(address _address){
    //     require(bytes(whitelistt[msg.sender]).length != 0, "you are not in whitelisted");
    //     _;
    // }

    // function checkwhitelist() public view CheckisnotinWhitelist(msg.sender) returns(bool){
    //    return (true);
    // }
}
