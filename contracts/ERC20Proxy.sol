pragma solidity ^0.5.2;

import { IERC20 } from "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import { SafeMath } from "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract ERC20Proxy {
  using SafeMath for uint256;

  // Mapping from owner to operator approvals
  mapping (address => mapping (address => bool)) private _operatorApprovals;

  // Mapping from owner to operator to token approvals
  mapping (address => mapping (address => mapping (address => uint256))) private _allowances;

  function transfer(address to, address token, uint256 value) public {
    IERC20(token).transferFrom(msg.sender, to, value);
  }

  function batchTransfer(address to, address[] calldata tokens, uint256[] calldata values) external {
    require(tokens.length == values.length);
    for(uint256 i = 0; i < tokens.length; i++) {
      transfer(to, tokens[i], values[i]);
    }
  }

  function transferFrom(address from, address to, address token, uint256 value) public {
    if (_operatorApprovals[from][msg.sender]) {
      // do nothing
    } else {
      _allowances[from][msg.sender][token].sub(value);
    }
    IERC20(token).transferFrom(from, to, value);
  }

  function safeBatchTransferFrom(address from, address to, address[] calldata tokens, uint256[] calldata values) external {
    require(tokens.length == values.length);
    for(uint256 i = 0; i < tokens.length; i++) {
      transferFrom(from, to, tokens[i], values[i]);
    }
  }

  function setApproval(address operator) external {
    _operatorApprovals[msg.sender][operator] = true;
  }

  function setApproval(address operator, address token, uint256 amount) external {
    _allowances[msg.sender][operator][token] = amount;
  }

  // function _isApproved(address owner, address spender, address token, uint256 value) internal returns(bool) {
  //   return _operatorApprovals[owner][spender]
  //     || _allowances[owner][spender][token] >= value;
  // }
}
