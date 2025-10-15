// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title KipuBank
 * @author Michel Massaad
 * @notice A simple banking contract where users can deposit and withdraw ETH.
 * @dev Implements transaction limits, a global deposit cap, custom errors, and follows security best practices.
 */
contract KipuBank {

    // =================================================================================================================
    //                                                   STATE VARIABLES
    // =================================================================================================================

    // --- Immutable & Constant Variables ---
    /// @notice The per-transaction withdrawal limit.
    uint256 public immutable WITHDRAWAL_LIMIT;
    /// @notice The global deposit cap for the entire bank.
    uint256 public immutable BANK_CAP;

    // --- Storage Variables ---
    /// @notice The total amount of ETH currently deposited in the contract.
    uint256 public totalDeposited;
    /// @notice A counter for the total number of deposits made.
    uint256 public depositCount;
    /// @notice A counter for the total number of withdrawals made.
    uint256 public withdrawalCount;
    /// @notice Reentrancy guard flag.
    bool private locked;

    // --- Mappings ---
    /// @notice Mapping from address to user balance.
    mapping(address => uint256) public balances;

    // =================================================================================================================
    //                                                       EVENTS
    // =================================================================================================================

    /// @notice Emitted when a user deposits ETH.
    /// @param user The address of the user who deposited.
    /// @param amount The amount deposited in wei.
    event Deposit(address indexed user, uint256 amount);

    /// @notice Emitted when a user withdraws ETH.
    /// @param user The address of the user who withdrew.
    /// @param amount The amount withdrawn in wei.
    event Withdrawal(address indexed user, uint256 amount);

    // =================================================================================================================
    //                                                      ERRORS
    // =================================================================================================================

    /// @notice Error thrown when the total deposits would exceed the bank's global cap.
    error BankCapExceeded();
    /// @notice Error thrown when a withdrawal amount exceeds the per-transaction limit.
    error WithdrawalLimitExceeded();
    /// @notice Error thrown when a user tries to withdraw more than their balance.
    error InsufficientBalance();
    /// @notice Error thrown when the provided amount is invalid (e.g., 0).
    error InvalidAmount();
    /// @notice Error thrown when a withdrawal transfer fails.
    /// @param errorData The data returned by the failed call.
    error WithdrawalFailed(bytes errorData);
    /// @notice Error for reentrancy guard, thrown when a reentrant call is detected.
    error ReentrantCall();

    // =================================================================================================================
    //                                                      MODIFIERS
    // =================================================================================================================

    /// @notice Prevents reentrancy attacks by locking the contract during a function's execution.
    modifier nonReentrant() {
        if (locked) revert ReentrantCall();
        locked = true;
        _;
        locked = false;
    }

    /// @notice Checks if the provided amount is greater than zero.
    /// @param _amount The amount to check.
    modifier nonZeroAmount(uint256 _amount) {
        if (_amount == 0) revert InvalidAmount();
        _;
    }

    // =================================================================================================================
    //                                                      CONSTRUCTOR
    // =================================================================================================================

    /**
     * @notice Initializes the contract with withdrawal and deposit limits.
     * @param _withdrawalLimit The per-transaction withdrawal limit.
     * @param _bankCap The global deposit cap.
     */
    constructor(uint256 _withdrawalLimit, uint256 _bankCap) {
        WITHDRAWAL_LIMIT = _withdrawalLimit;
        BANK_CAP = _bankCap;
    }

    // =================================================================================================================
    //                                                 EXTERNAL FUNCTIONS
    // =================================================================================================================

    /**
     * @notice Deposits ETH into the user's balance.
     * @dev Reverts if the amount is zero or if the deposit would exceed the global bank cap.
     * @dev Follows the checks-effects-interactions pattern.
     */
    function deposit() external payable nonZeroAmount(msg.value) {
        // --- Checks ---
        if (totalDeposited + msg.value > BANK_CAP) revert BankCapExceeded();

        // --- Effects ---
        // Using unchecked as the check above prevents overflow, saving gas.
        unchecked {
            totalDeposited += msg.value;
        }
        balances[msg.sender] += msg.value;
        depositCount++;

        // --- Interactions (none in this function) ---

        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @notice Withdraws ETH from the user's balance.
     * @param _amount The amount to withdraw in wei.
     * @dev Reverts if the amount is zero, exceeds the withdrawal limit, or if the user has insufficient balance.
     * @dev Follows the checks-effects-interactions pattern.
     */
    function withdrawal(uint256 _amount) external nonReentrant nonZeroAmount(_amount) {
        uint256 userBalance = balances[msg.sender]; // Read state once to save gas

        // --- Checks ---
        if (_amount > WITHDRAWAL_LIMIT) revert WithdrawalLimitExceeded();
        if (_amount > userBalance) revert InsufficientBalance();

        // --- Effects ---
        balances[msg.sender] = userBalance - _amount;
        totalDeposited -= _amount;
        withdrawalCount++;

        // --- Interaction ---
        _transferEth(payable(msg.sender), _amount);

        emit Withdrawal(msg.sender, _amount);
    }

    /**
     * @notice Gets the balance of the message sender.
     * @return The balance in wei.
     */
    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    // =================================================================================================================
    //                                                 PRIVATE FUNCTIONS
    // =================================================================================================================

    /**
     * @notice Internal function that performs a safe ETH transfer using the .call method.
     * @param _to The recipient's address.
     * @param _amount The amount to transfer.
     */
    function _transferEth(address payable _to, uint256 _amount) private {
        (bool success, bytes memory errorData) = _to.call{value: _amount}("");
        if (!success) {
            revert WithdrawalFailed(errorData);
        }
    }
}