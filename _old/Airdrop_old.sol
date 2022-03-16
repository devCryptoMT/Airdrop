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

    function runPayment(address _userAddress) external returns(bool);

    function pendPayment(address _userAddress, uint _amount) external returns(bool);

    function restorePending() external returns(bool);

    function getGatewayBalance() external view returns(address[] memory, uint[] memory);
}


contract Airdrop {

    using SafeMath for uint256;

    address owner;
    uint price;
    uint circuitAddressesNumber;

    enum circuitState {
        NOT_DEFINED,
        ENABLED,
        SUSPENDED,
        DISABLED
    }

    mapping(address => uint) balances;
    mapping(address => bool) whitelist;
    mapping(address => circuitState) circuitMaster;
    mapping(uint => address) smartContractCircuitPaymentList;
    mapping(address => uint) pendentPayment;

    event AirdropEvent(address token, address[] addresses, uint256[] values);
    event WhitelistSwitch(address owner, address whitelistedAddress, bool isEnabled);
    event PriceChange(address owner, uint oldPrice, uint newPrice);
    event BalanceChange(address user, uint oldBalance, uint newBalance, bool isExternal, address contractReference);
    event OwnerWithdraw(address owner, uint amount);
    event CircuitMasterEnabled(address owner, address smartContractAddress, circuitState circuitState);

    constructor() {
        owner = msg.sender;
        price = uint(3).mul(10**16); // = 0.03 ETH
        whitelist[msg.sender] = true;
        circuitMaster[address(this)] = circuitState.ENABLED;        
        emit CircuitMasterEnabled(msg.sender, address(this), circuitState.ENABLED);
        emit WhitelistSwitch(msg.sender, msg.sender, true);
    }

    function createNewPaymentCircuitConnection(address _smartContractAddress) public returns(bool){
        require(owner == msg.sender, "UNAUTHORIZED_ACCESS");  
        require(_smartContractAddress != address(this), "OWN_PAYMENT_ADDRESS_IS_USED_BY_DEFAULT");
        require(circuitMaster[_smartContractAddress] == circuitState.NOT_DEFINED, "SMART CONTRACT ALREADY IN TYHE PAYMENT CIRCUIT"); 
        circuitMaster[_smartContractAddress] = circuitState.ENABLED;
        uint index = circuitAddressesNumber;
        smartContractCircuitPaymentList[index] = _smartContractAddress;
        circuitAddressesNumber = index.add(1);
        emit CircuitMasterEnabled(msg.sender, _smartContractAddress, circuitState.ENABLED);
        return true;
    }

    function suspendPaymentCircuitConnection(address _smartContractAddress) public returns(bool){
        require(owner == msg.sender, "UNAUTHORIZED_ACCESS");  
        require(_smartContractAddress != address(this), "CAN'T_SUSPEND_OWN_PAYMENT_ADDRESS");
        require(circuitMaster[_smartContractAddress] == circuitState.ENABLED, "SMART CONTRACT HAS TO BE ENABLED IN TYHE PAYMENT CIRCUIT"); 
        circuitMaster[_smartContractAddress] = circuitState.SUSPENDED;
        emit CircuitMasterEnabled(msg.sender, _smartContractAddress, circuitState.SUSPENDED);
        return true;
    }

    function reactivatePaymentCircuitConnection(address _smartContractAddress) public returns(bool){
        require(owner == msg.sender, "UNAUTHORIZED_ACCESS");  
        require(circuitMaster[_smartContractAddress] == circuitState.SUSPENDED, "SMART CONTRACT HAS TO BE SUSPENDED IN TYHE PAYMENT CIRCUIT"); 
        circuitMaster[_smartContractAddress] = circuitState.ENABLED;
        emit CircuitMasterEnabled(msg.sender, _smartContractAddress, circuitState.ENABLED);
        return true;
    }

    function permanentDisablePaymentCircuitConnection(address _smartContractAddress) public returns(bool){
        require(owner == msg.sender, "UNAUTHORIZED_ACCESS");  
        require(_smartContractAddress != address(this), "CAN'T_DISABLE_OWN_PAYMENT_ADDRESS");
        require(circuitMaster[_smartContractAddress] == circuitState.ENABLED || circuitMaster[_smartContractAddress] == circuitState.SUSPENDED, "SMART CONTRACT HAS TO BE ENABLED OR SUSPENDED IN TYHE PAYMENT CIRCUIT"); 
        circuitMaster[_smartContractAddress] = circuitState.DISABLED;
        emit CircuitMasterEnabled(msg.sender, _smartContractAddress, circuitState.DISABLED);
        return true;
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

    function getFinalPrice(address _userAddress) public view returns(uint){
        uint finalPrice;
        uint ETHER = 10 ** 18;
        uint DEC_ETHER = 10 ** 17;
        uint userBalance = balances[_userAddress];
        if(whitelist[_userAddress]){
            finalPrice = 0;
        } else {
            if(userBalance > ETHER){
                finalPrice = price.mul(50).div(100);                            // 50% DISCOUNT
            }
            if(userBalance < 8 * DEC_ETHER && userBalance <= ETHER){
                finalPrice = price.mul(60).div(100);                            // 40% DISCOUNT
            }
            if(userBalance > 6 * DEC_ETHER && userBalance <= 8 * DEC_ETHER){
                finalPrice = price.mul(70).div(100);                            // 30% DISCOUNT
            }
            if(userBalance > 4 * DEC_ETHER && userBalance <= 6 * DEC_ETHER){
                finalPrice = price.mul(80).div(100);                            // 20% DISCOUNT
            }
            if(userBalance > 2 * DEC_ETHER && userBalance <= 4 * DEC_ETHER){
                finalPrice =  price.mul(90).div(100);                           // 10% DISCOUNT
            }
            if(userBalance > 0 && userBalance <= 2 * DEC_ETHER){
                finalPrice =  price;                                            // NO DISCOUNT
            }
        }  
        return finalPrice;
    }

    function increaseBalance() payable public returns(bool){
        require(msg.value > 0, "VALUE_CANT_BE_NULL");
        uint userBalance = balances[msg.sender];
        uint ownerBalance = balances[owner];
        balances[msg.sender] = userBalance.add(msg.value);
        balances[owner] = ownerBalance.add(msg.value);
        emit BalanceChange(msg.sender, userBalance, userBalance.add(msg.value), false, address(this));
        emit BalanceChange(msg.sender, userBalance, ownerBalance.add(msg.value), false, address(this));
        return true;
    }

    function withdrawOwnerBalance() payable public returns(bool){
        require(owner == msg.sender, "UNAUTHORIZED_ACCESS");
        uint amount = balances[owner];
        require(amount > 0, "BALANCES_HAS_TO_BE_POSITIVE");
        (bool sent, ) = address(msg.sender).call{value: msg.value}("");
        require(sent, "Failed to send Ether");
        emit OwnerWithdraw(msg.sender, amount);
        return true;
    }

    // @dev: To be able to run it, we need to approve from the IERC20 of the token itself the address of this smart contract
    function runAirdrop(address _token, address[] calldata _addresses, uint256[] calldata _values) payable external returns (bool) {
        require(_token != address(0), "TOKEN_ADDRESS_CANT_BE_NULL");
        require(_addresses.length == _values.length, "ELEMENT_LIST_LENGHT_DOESNT_MATCH");
        uint finalPrice = getFinalPrice(msg.sender);
        uint userBalance = balances[msg.sender];
        address smartContractFoundWithBalance;
        bool hasSufficientFunds = false;
        bool isInternal = true;
        uint newBalance;
        IPaymentCircuit IPC;

        if(userBalance >= finalPrice){
            newBalance = userBalance.sub(finalPrice);
            balances[msg.sender] = newBalance;
            hasSufficientFunds = true;
        } else {
            for(uint index = 0; index < circuitAddressesNumber; index++){
                smartContractFoundWithBalance = smartContractCircuitPaymentList[index];
                IPC = IPaymentCircuit(smartContractFoundWithBalance);
                if(IPC.pendPayment(msg.sender, finalPrice)){
                    hasSufficientFunds = true;
                    isInternal = false;
                    index = circuitAddressesNumber; // Get out at first recognizable address
                }
            }
        }
        require(hasSufficientFunds, "INSUFFICIENT_FUNDS");
        for (uint index = 0; index < _addresses.length; index += 1) {
            require(_addresses[index] != address(0), "NOT_VALID_ADDRESS_DETECTED");
            require(_values[index] > uint(0), "NOT_VALID_VALUE_DETECTED");
            IERC20(_token).transferFrom(msg.sender, _addresses[index], _values[index]);
        }

        address addressRef;
        if(!isInternal){
            IPC = IPaymentCircuit(smartContractFoundWithBalance);
            userBalance = IPC.getBalance(msg.sender);
            require(IPC.runPayment(msg.sender), "CANT_SCALE_PENDING_PAYMENT");
            newBalance = IPC.getBalance(msg.sender);
            addressRef = smartContractFoundWithBalance;
        } else {
            addressRef = address(this);
        }

        emit AirdropEvent(_token, _addresses, _values);
        emit BalanceChange(msg.sender, userBalance, newBalance, isInternal, addressRef);
        return true;
    }

    // DEFAULT FUNCTIONS FOR INTERFACES

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

    function runPayment(address _userAddress) public returns(bool){
        require(circuitMaster[msg.sender] == circuitState.ENABLED, "SMARTCONTRACT_NOT_IN_CIRCUIT_PAYMENT");
        uint balance = balances[_userAddress];
        uint pendentPaymentBalance = pendentPayment[_userAddress];
        require(balance >= pendentPaymentBalance, "INSUFFICIENT_BALANCE_FOR_THAT_USER");
        balances[_userAddress] = balance.sub(pendentPaymentBalance);
        emit BalanceChange(_userAddress, balance, balance.sub(pendentPaymentBalance), true, address(this));
        return true;
    }

    function pendPayment(address _userAddress, uint _amount) public returns(bool){
        require(circuitMaster[msg.sender] == circuitState.ENABLED, "SMARTCONTRACT_NOT_IN_CIRCUIT_PAYMENT");
        uint balance = balances[_userAddress];
        require(balance >= _amount, "INSUFFICIENT_BALANCE_FOR_THAT_USER");
        pendentPayment[_userAddress] = pendentPayment[_userAddress].add(_amount); 
        return true;
    }

    function restorePending() public returns(bool){
        uint pendentPaymentBalance = pendentPayment[msg.sender];
        require(pendentPaymentBalance > 0, "PENDENT_PAYMENT_CANT_BE_NULL");
        balances[msg.sender].add(pendentPaymentBalance);
        pendentPayment[msg.sender] = 0; 
        return true;
    }

    function getGatewayBalance() public view returns(address[] memory, uint[] memory){
        IPaymentCircuit IPC;
        address[] memory resultAddresses;
        uint[] memory resultValues;
        address smartContractOnCircuit;
        uint balance;
        uint resultIndex = 0;
        // External smart contracts
        for(uint index = 0; index < circuitAddressesNumber; index++){
            smartContractOnCircuit = smartContractCircuitPaymentList[index];
            IPC = IPaymentCircuit(smartContractOnCircuit);
            balance = IPC.getBalance(msg.sender);
            if(balance > 0){
                resultAddresses[resultIndex] = smartContractOnCircuit;
                resultValues[resultIndex] = balance;
            }
            resultIndex = resultIndex.add(1);
        }
        //Internal smart contra
        balance = getBalance(msg.sender);
        if(balance > 0){
            resultAddresses[resultIndex] = address(this);
            resultValues[resultIndex] = balance;
        }
        return (resultAddresses, resultValues);
    }
}
