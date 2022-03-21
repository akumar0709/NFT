// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract MyNFT is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;
    uint96 royalityFees;
    string public contractURI;
    address royalityReciever;
    
    constructor(uint96 _royalityFees, string memory _contractURI) ERC721("MyNFT", "BT") {
        royalityFees = _royalityFees;
        contractURI = _contractURI;
        royalityReciever=msg.sender;
    }
    // User has to pay minimum mintRate to mint NFT
    uint256 public mintRate=0.01 ether;
    uint public MaxSupply =1;
    Counters.Counter private _tokenIdCounter;

 // Base URI to be provided by owner here   
    function _baseURI() internal pure override returns (string memory) {
        return "https://....";
    }

 /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeMint(address to, uint256 tokenId, string memory uri) public onlyOwner payable
    {
        require(totalSupply() <MaxSupply, "Can't Mint more");
        require(msg.value>= mintRate, "Not enough ether to mint");
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.
 /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }
 /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
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
//Function that transfer all money to owner in smart contract like mintRate that is collected
    function withdraw() public onlyOwner{
        require(address(this).balance>0, "Balance is 0");
        payable(owner()).transfer(address(this).balance);
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
