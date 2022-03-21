// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract batch is ERC721A, Ownable {
    uint256 MAX_MINTS = 10;
    uint256 MAX_SUPPLY = 1000;

    // User has to pay minimum mintRate to mint NFT
    uint256 public mintRate = 0.001 ether;

    //Royality Fess we are gonna set
    uint96 royalityFees;
    string public contractURI;

    //Royality reciever which is by default owner
    address royalityReciever;
    

    string public baseURI = "ipfs:///";  //specify URI

    constructor(uint96 _royalityFees, string memory _contractURI) ERC721A("blockting", "BT") {
        royalityFees = _royalityFees;
        contractURI = _contractURI;
        royalityReciever=msg.sender;
    
    }

    function mint(uint256 quantity) external payable onlyOwner {                //only owner is able to mint
        // _safeMint's second argument now takes in a quantity, not a tokenId.
        require(quantity + _numberMinted(msg.sender) <= MAX_MINTS, "Exceeded the limit");
        require(totalSupply() + quantity <= MAX_SUPPLY, "Not enough tokens left");
        require(msg.value >= (mintRate * quantity), "Not enough ether sent");
        _safeMint(msg.sender, quantity);
    }

    function withdraw() external payable onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setMintRate(uint256 _mintRate) public onlyOwner {
        mintRate = _mintRate;
    }

    function burn(uint256 tokenId) public virtual {
        _burn(tokenId);

    }
 /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return interfaceId==0x2a55205a || super.supportsInterface(interfaceId);
    }
/**
     * @dev Returns royalty amount as uint256 and address where royalties should go. 
     * 
     * @dev Marketplaces would need to call this during the purchase function of their marketplace - and then implement the transfer of that amount on their end
     */
  
     function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view returns (
        address receiver,
        uint256 royaltyAmount
    ){
        return (royalityReciever, calculateRoyality(_salePrice));

    }
// Function to calculate royality , it can be changed with different scenerio
    function calculateRoyality(uint256 _salePrice) view public  returns (uint256){
        return (_salePrice / 10000) * royalityFees;
    }
//Simple function to set information to be used 
    function setRoyalityInfo(address _reciever, uint96 _royalityFees) public onlyOwner{
        royalityReciever= _reciever;
        royalityFees=_royalityFees;
    }

    function setContractURI(string calldata _contractURI)  public onlyOwner{
        contractURI=_contractURI;
    }

}
