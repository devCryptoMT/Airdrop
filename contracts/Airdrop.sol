//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// -----------------------------------------------------------------------------

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

interface IPaymentCircuit {

    function getBalance(address _user) external view returns(uint);

    function getOwner() external view returns(address);

    function getIsWhitelisted(address _user) external view returns(bool);
   
    function getPrice() external view returns(uint);

    function getFinalPrice(address _userAddress) external view returns(uint);

    function withdrawOwnerBalance() payable external returns(bool);

    function runAirdrop(address _token, address[] calldata _addresses, uint256[] calldata _values) payable external returns (bool);

}


contract Airdrop {

    using SafeMath for uint256;

    address owner;
    uint price;

    mapping(address => uint) balances;
    mapping(address => bool) whitelist;

    event AirdropEvent(address token, address[] addresses, uint256[] values);
    event WhitelistSwitch(address owner, address whitelistedAddress, bool isEnabled);
    event PriceChange(address owner, uint oldPrice, uint newPrice);
    event PaymentDone(address owner, address user, uint amount);
    event OwnerWithdraw(address owner, uint amount);

    constructor() {
        owner = msg.sender;
        price = uint(3).mul(10**16); // = 0.03 ETH
        whitelist[msg.sender] = true;
        emit WhitelistSwitch(msg.sender, msg.sender, true);
    }

    function switchWhitelist(address _whitelistedAddress) public returns(bool){
        require(owner == msg.sender, "UNAUTHORIZED_ACCESS");
        bool isEnabled = !whitelist[_whitelistedAddress];
        whitelist[_whitelistedAddress] = isEnabled;
        emit WhitelistSwitch(msg.sender, _whitelistedAddress, isEnabled);
        return true;
    }

    function changePrice(uint _newPrice) public returns(bool){
        require(owner == msg.sender, "UNAUTHORIZED_ACCESS");
        uint oldPrice = price;
        require(oldPrice != _newPrice, "CANT_SET_THE_SAME_VALUE");
        price = _newPrice;
        emit PriceChange(msg.sender, oldPrice, _newPrice);
        return true;
    }

    function withdrawOwnerBalance() payable public returns(bool){
        require(owner == msg.sender, "UNAUTHORIZED_ACCESS");
        uint amount = balances[owner];
        require(amount > 0, "BALANCES_HAS_TO_BE_POSITIVE");
        balances[owner] = uint(0);
        (bool sent, ) = address(msg.sender).call{value: msg.value}("");
        require(sent, "Failed to send Ether");
        emit OwnerWithdraw(msg.sender, amount);
        return true;
    }

    // @dev: To be able to run it, we need to approve from the IERC20 of the token itself the address of this smart contract
    function runAirdrop(address _token, address[] calldata _addresses, uint256[] calldata _values) payable external returns (bool) {
        require(_token != address(0), "TOKEN_ADDRESS_CANT_BE_NULL");
        require(_addresses.length == _values.length, "ELEMENT_LIST_LENGHT_DOESNT_MATCH");
        uint currentPrice = price;
        if(whitelist[msg.sender]){
            require(msg.value == uint(0), "ETHER_AMOUNT-HAS_TO_BE_EQUALS_TO_PRICE");
        } else {
            require(msg.value == currentPrice, "ETHER_AMOUNT-HAS_TO_BE_EQUALS_TO_PRICE");
        }
        address currentOwner = owner;
        balances[currentOwner] = balances[currentOwner].add(currentPrice);
        for (uint index = 0; index < _addresses.length; index += 1) {
            require(_addresses[index] != address(0), "NOT_VALID_ADDRESS_DETECTED");
            require(_values[index] > uint(0), "NOT_VALID_VALUE_DETECTED");
            IERC20(_token).transferFrom(msg.sender, _addresses[index], _values[index]);
        }
        emit PaymentDone(currentOwner, msg.sender, currentPrice);
        emit AirdropEvent(_token, _addresses, _values);
        return true;
    }

    function getBalance(address _user) public view returns(uint){
        return balances[_user];
    }

    function getOwner() public view returns(address){
        return owner;
    }

    function getIsWhitelisted(address _user) public view returns(bool){
        return whitelist[_user];
    }

    function getPrice() public view returns(uint){
        return price;
    }

}
