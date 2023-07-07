// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract MultiSig {
    //array for owners who is the part of this wallet
    address[] public owners;
    uint256 public numberOfConfirmationRequired;

    //struct for whom we transfer the how much value
    struct Transaction {
        address to;
        uint256 value;
        bool executed;
    }
    //mapping state whether our transaction confirmed  or not

    mapping(uint256 => mapping(address => bool)) isConfirmed;
    Transaction[] public transactions;

    //event
    event TransactionSubmited(uint256 transactionId, address sender, address receiver, uint256 amount);
    event TransactionConfirmed(uint256 transactionId);
    event TransactionExecuted(uint256 transactionId);

    //counstructor
    constructor(address[] memory _owners, uint256 _numberOfConfermationRequired) {
        require(_owners.length > 1, "ownwrs Required must greater than 1");
        require(
            _numberOfConfermationRequired > 0 && _numberOfConfermationRequired <= _owners.length,
            "Num of confermatuion are not in sync"
        );

        for (uint256 i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "invalid owner");
            owners.push(_owners[i]);
        }
        numberOfConfirmationRequired = _numberOfConfermationRequired;
    }

    //anyone want to do any kind of transaction they have to call this submitTransaction() function
    function submitTraqnsaction(address _to) public payable {
        require(_to != address(0), "Invalid reciever's address");
        require(msg.value > 0, "Transfer valid amount");
        //if this conditions are good  we creat id array
        uint256 transactionId = transactions.length;
        transactions.push(Transaction({to: _to, value: msg.value, executed: false}));
        emit TransactionSubmited(transactionId, msg.sender, _to, msg.value);
    }

    //after submitting  transactions  we have to check that it’s  confirm or not
    function confirmTransaction(uint256 _transactionId) public {
        require(_transactionId < transactions.length);
        require(!isConfirmed[_transactionId][msg.sender], "Transaction is already confirm ");
        isConfirmed[_transactionId][msg.sender] = true;
        emit TransactionConfirmed(_transactionId);
        if (isTransactionConfiremed(_transactionId)) {
            executeTransaction(_transactionId);
        }
    }

    function executeTransaction(uint256 _transactionId) public payable {
        require(_transactionId < transactions.length, "invalid transaction Id");
        require(isTransactionConfiremed(_transactionId), "no of confirmation required");
        require(!transactions[_transactionId].executed, "Transactions  already executed ");
        //transactions[_transactionId].executed = true;
        (bool success,) = transactions[_transactionId].to.call{value: transactions[_transactionId].value}("");
        require(success, "Execution  failed");
        transactions[_transactionId].executed = true;
        emit TransactionExecuted(_transactionId);
    }

    //
    function isTransactionConfiremed(uint256 _transactionId) internal view returns (bool) {
        require(_transactionId < transactions.length);
        uint256 confermationCount;

        for (uint256 i = 0; i < owners.length; i++) {
            if (isConfirmed[_transactionId][owners[i]]) {
                confermationCount++;
            }
        }
        return confermationCount >= numberOfConfirmationRequired;
    }
}
