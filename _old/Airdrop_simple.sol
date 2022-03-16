//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    } 
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Airdrop {

    using SafeMath for uint256;

    event AirdropEvent(address token, address[] addresses, uint256[] values);

    constructor() {
    }

    function runAirdrop(address _token, address[] calldata _addresses, uint256[] calldata _values) payable external returns (bool) {
        require(_token != address(0), "TOKEN_ADDRESS_CANT_BE_NULL");
        require(_addresses.length == _values.length, "ELEMENT_LIST_LENGHT_DOESNT_MATCH");
        for (uint index = 0; index < _addresses.length; index += 1) {
            require(_addresses[index] != address(0), "NOT_VALID_ADDRESS_DETECTED");
            require(_values[index] > uint(0), "NOT_VALID_VALUE_DETECTED");
            IERC20(_token).transferFrom(msg.sender, _addresses[index], _values[index]);
        }
        emit AirdropEvent(_token, _addresses, _values);
        return true;
    }
}
