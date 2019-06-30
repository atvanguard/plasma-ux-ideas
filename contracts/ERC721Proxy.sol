pragma solidity ^0.5.2;

import { IERC721 } from "openzeppelin-solidity/contracts/token/ERC721/IERC721.sol";

contract ERC721Proxy {
  // Mapping from owner to operator approvals
  mapping (address => mapping (address => bool)) private _operatorApprovals;

  // Mapping from owner to operator to token approvals
  mapping (address => mapping (address => mapping (address => bool))) private _tokenApprovals;

  // Mapping from owner to operator to token to token ID approvals
  mapping (address => mapping (address => mapping (address => mapping (uint256 => bool)))) private _tokenIdApprovals;

  function transfer(address to, address token, uint256 tokenId) public {
    IERC721(token).safeTransferFrom(msg.sender, to, tokenId);
  }

  function batchTransfer(address to, address[] calldata tokens, uint256[] calldata tokenIds) external {
    require(tokens.length == tokenIds.length);
    for(uint256 i = 0; i < tokens.length; i++) {
      transfer(to, tokens[i], tokenIds[i]);
    }
  }

  function transferFrom(address from, address to, address token, uint256 tokenId) public {
    require(_isApproved(from, msg.sender, token, tokenId));
    IERC721(token).safeTransferFrom(from, to, tokenId);
  }

  function safeBatchTransferFrom(address from, address to, address[] calldata tokens, uint256[] calldata tokenIds) external {
    require(tokens.length == tokenIds.length);
    for(uint256 i = 0; i < tokens.length; i++) {
      transferFrom(from, to, tokens[i], tokenIds[i]);
    }
  }

  function setApproval(address operator) external {
    _operatorApprovals[msg.sender][operator] = true;
  }

  function setApproval(address operator, address token) external {
    _tokenApprovals[msg.sender][operator][token] = true;
  }

  function setApproval(address operator, address token, uint256 tokenId) external {
    _tokenIdApprovals[msg.sender][operator][token][tokenId] = true;
  }

  function _isApproved(address owner, address spender, address token, uint256 tokenId) internal returns(bool) {
    return _operatorApprovals[owner][spender]
      || _tokenApprovals[owner][spender][token]
      || _tokenIdApprovals[owner][spender][token][tokenId];
  }
}
