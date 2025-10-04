// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title KipuBank
 * @author Michel Massaad
 * @notice Contrato de banco simple donde los usuarios pueden depositar y retirar ETH
 * @dev Implementa limites por transacción, limite global de depositos, errores personalizados y patron checks-effects-interactions
 */

contract KipuBank {

     // ======= ERRORES PERSONALIZADOS =======
     /// @notice error cuando se supera el límite global de depósitos
    error BankCapExceeded();
    /// @notice error cuando se supera el límite de retiro por transacción
    error WithdrawalLimitExceeded();
    /// @notice error cuando el usuario no tiene suficiente balance
    error InsufficientBalance();
    /// @notice Error cuando el monto es inválido (0)
    error InvalidAmount();
    /// @notice error cuando el retiro falla
    /// @param errorData datos del error de la transferencia
    error WithdrawalFailed(bytes errorData);


    // ====== VARIABLES ======
    /// @notice Límite de retiro por transacción
    uint256 public immutable withdrawalLimit; 
    /// @notice Límite global de depósitos
    uint256 public immutable bankCap; 
    /// @notice Saldo final de cada usuario
    mapping(address => uint256) public balances; 
    /// @notice Contador de depósitos
    uint256 public totalDeposits;                 
    /// @notice Contador de retiros
    uint256 public totalWithdrawals;           

    // ======== EVENTOS ======
     /// @notice Evento emitido cuando se deposita ETH
    /// @param user dirección del usuario que depositó
    /// @param amount cantidad depositada en wei
    event Deposit_Eth(address indexed user, uint256 amount);
    
    /// @notice Evento emitido cuando se retira ETH
    /// @param user dirección del usuario que retiró
    /// @param amount cantidad retirada en wei
    event Withdrawal_Eth(address indexed user, uint256 amount);

    // ====== CONSTRUCTOR ====
    /**
     * @notice Inicializa el contrato con los límites de retiro y depósito
     * @param _withdrawalLimit Límite de retiro por transacción
     * @param _bankCap Límite global de depósitos
     */
    constructor(uint256 _withdrawalLimit, uint256 _bankCap) {
        withdrawalLimit = _withdrawalLimit;
        bankCap = _bankCap;
    }
    
    // ======= MODIFIER ======
    bool flag; 
    /// @notice Evita ataques de reentrancy
    modifier reentrancyGuard() {
        if (flag != false) revert(); // si ya está en ejecución, revierte
        flag = true;
        _;
        flag = false; // resetea al terminar
    }

    // ======== FUNCIONES =====

    /**
     * @notice Deposita ETH en la bóveda del usuario
     * @dev Verifica que el depósito sea mayor a 0 y que no supere el límite global
     * @dev Incrementa el contador total de depósitos
     */

    function deposit() external payable {
        if (msg.value == 0) revert InvalidAmount();
        if (balances[msg.sender] + msg.value > bankCap) revert BankCapExceeded();

        balances[msg.sender] += msg.value; // actualizamos el balance interno del usuario
        totalDeposits += 1;

        emit Deposit_Eth(msg.sender, msg.value);
    }

    /**
     * @notice Retira ETH de la bóveda del usuario
     * @param amount Monto a retirar en wei
     * @dev Verifica límite de retiro por transacción y saldo suficiente
     * @dev Incrementa el contador total de retiros
     */

    function withdrawal(uint256 amount) external reentrancyGuard {
        if (amount == 0) revert InvalidAmount();
        if (amount > withdrawalLimit) revert WithdrawalLimitExceeded();
        if (amount > balances[msg.sender]) revert InsufficientBalance();
        
        balances[msg.sender] -= amount; // efecto (actualización del estado)
        totalWithdrawals++;
        _transferEth(payable(msg.sender), amount); // interacción externa
        emit Withdrawal_Eth(msg.sender, amount);
    }

     /**
     * @notice Función privada que realiza una transferencia segura de ETH
     * @param to Dirección del receptor
     * @param amount Monto a transferir
     */
    function _transferEth(address payable to, uint256 amount) private {
        (bool success, bytes memory errorData) = to.call{value: amount}("");
        if (!success) {
            // revertimos e incluimos el detalle del error
            revert WithdrawalFailed(errorData);
        }
    }

    /**
     * @notice Obtiene el saldo de un usuario
     * @return Balance en wei
     */
    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

}
