// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/*
 * =============================
 * MultiSigTreasury Structure
 * =============================
 * 1. SPDX & pragma
 * 2. Contract declaration
 * 3. Custom errors
 * 4. Events
 * 5. Structs
 * 6. State variables
 * 7. Modifiers
 * 8. Constructor
 * 9. Submit transaction function
 * 10. Confirm transaction function
 * 11. Revoke confirmation function
 * 12. Execute transaction function
 * 13. View functions
 */

contract MultiSigTreasury {
    error NotOwner();
    error InvalidOwner();
    error OwnerNotUnique();
    error InvalidRequiredConfirmations();
    error TransactionDoesNotExist();
    error TransactionAlreadyExecuted();
    error TransactionAlreadyConfirmed();
    error TransactionNotConfirmed();
    error NotEnoughConfirmations();
    error TransferFailed();

    event Deposit(address indexed sender, uint256 amount, uint256 balance);
    event TransactionSubmitted(
        uint256 indexed txIndex,
        address indexed owner,
        address indexed to,
        uint256 value,
        bytes data
    );
    event TransactionConfirmed(uint256 indexed txIndex, address indexed owner);
    event ConfirmationRevoked(uint256 indexed txIndex, address indexed owner);
    event TransactionExecuted(uint256 indexed txIndex, address indexed owner);

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 numConfirmations;
    }

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public requiredConfirmations;

    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public isConfirmed;

    modifier onlyOwner() {
        if (!isOwner[msg.sender]) revert NotOwner();
        _;
    }

    modifier txExists(uint256 txIndex) {
        if (txIndex >= transactions.length) revert TransactionDoesNotExist();
        _;
    }

    modifier notExecuted(uint256 txIndex) {
        if (transactions[txIndex].executed) revert TransactionAlreadyExecuted();
        _;
    }

    modifier notConfirmed(uint256 txIndex) {
        if (isConfirmed[txIndex][msg.sender])
            revert TransactionAlreadyConfirmed();
        _;
    }

    constructor(address[] memory _owners, uint256 _requiredConfirmations) {
        if (
            _owners.length == 0 ||
            _requiredConfirmations == 0 ||
            _requiredConfirmations > _owners.length
        ) {
            revert InvalidRequiredConfirmations();
        }

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            if (owner == address(0)) revert InvalidOwner();
            if (isOwner[owner]) revert OwnerNotUnique();

            isOwner[owner] = true;
            owners.push(owner);
        }

        requiredConfirmations = _requiredConfirmations;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function submitTransaction(
        address to,
        uint256 value,
        bytes calldata data
    ) external onlyOwner {
        uint256 txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: to,
                value: value,
                data: data,
                executed: false,
                numConfirmations: 0
            })
        );

        emit TransactionSubmitted(txIndex, msg.sender, to, value, data);
    }

    function confirmTransaction(
        uint256 txIndex
    )
        external
        onlyOwner
        txExists(txIndex)
        notExecuted(txIndex)
        notConfirmed(txIndex)
    {
        Transaction storage transaction = transactions[txIndex];

        transaction.numConfirmations += 1;
        isConfirmed[txIndex][msg.sender] = true;

        emit TransactionConfirmed(txIndex, msg.sender);
    }

    function revokeConfirmation(
        uint256 txIndex
    ) external onlyOwner txExists(txIndex) notExecuted(txIndex) {
        if (!isConfirmed[txIndex][msg.sender]) revert TransactionNotConfirmed();

        Transaction storage transaction = transactions[txIndex];

        transaction.numConfirmations -= 1;
        isConfirmed[txIndex][msg.sender] = false;

        emit ConfirmationRevoked(txIndex, msg.sender);
    }

    function executeTransaction(
        uint256 txIndex
    ) external onlyOwner txExists(txIndex) notExecuted(txIndex) {
        Transaction storage transaction = transactions[txIndex];

        if (transaction.numConfirmations < requiredConfirmations) {
            revert NotEnoughConfirmations();
        }

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        if (!success) revert TransferFailed();

        emit TransactionExecuted(txIndex, msg.sender);
    }

    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() external view returns (uint256) {
        return transactions.length;
    }

    function getTransaction(
        uint256 txIndex
    )
        external
        view
        returns (
            address to,
            uint256 value,
            bytes memory data,
            bool executed,
            uint256 numConfirmations
        )
    {
        Transaction storage transaction = transactions[txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }
}
