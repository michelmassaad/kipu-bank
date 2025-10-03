// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Contrato KipuBank
 * @author michelmassaad
 * @notice Contrato ....
 */

contract KipuBank {

    // Errores personalizados
    error BankCapExceeded();
    error WithdrawalLimitExceeded();
    error InsufficientBalance();
    error InvalidAmount();

    uint256 public immutable withdrawalLimit; // limite de retiro
    uint256 public immutable bankCap; // limite de retiro

// Los usuarios pueden depositar tokens nativos (ETH) en una bóveda personal.
    // address user = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    mapping(address => uint256) public balances; //saldo final de cada usuario

    constructor(uint256 _withdrawalLimit, uint256 _bankCap) {
        withdrawalLimit = _withdrawalLimit;
        bankCap = _bankCap;
    }

    //si puedes depositar significa que hay que poder recibir los (ETH)
    event Deposit_Eth(address indexed user, uint256 amount);

    function deposit() external payable {
        if (msg.value == 0) revert InvalidAmount();
        if (balances[msg.sender] + msg.value > bankCap) revert BankCapExceeded();

        balances[msg.sender] += msg.value; // ahora reflejamos el ETH real

        emit Deposit_Eth(msg.sender, msg.value);
    }


// Los usuarios pueden retirar fondos de su bóveda, pero solo hasta un umbral fijo por transacción, 
//representado por una variable immutable.
    

    event Withdrawal_Eth(address indexed user, uint256 amount);
    
    // --- MODIFICADORES ---
    bool flag; // usado para evitar ataques de reentrancy
    modifier reentrancyGuard() {
        if (flag != false) revert(); // si ya está en ejecución, revierte
        flag = true;
        _;
        flag = false; // resetea al terminar
    }

    function withdrawal(uint256 amount) external reentrancyGuard {
        //validaciones
        if (amount == 0) revert InvalidAmount();
        if (amount > withdrawalLimit) revert WithdrawalLimitExceeded();
        if (amount > balances[msg.sender]) revert InsufficientBalance();

        address to = msg.sender; //obtengo direccion del remitente
        // uint256 myBalance = balances[msg.sender]; // guardo el balance
        balances[msg.sender] -= amount ;  // evita reentrancy (seguridad)
        (bool success,) = to.call{value: amount}("");
            if (!success) {
            // Restaurar el balance del usuario si la transferencia falla
            balances[msg.sender] += amount;
            revert("Withdrawal failed");
        }
        emit Withdrawal_Eth(msg.sender, amount);
    }



// El contrato impone un límite global de depósitos (bankCap), definido durante el despliegue.

// Las interacciones internas y externas deben seguir buenas prácticas de seguridad y declaraciones revert con errores personalizados si no se cumplen las condiciones.

// Se deben emitir eventos tanto en depósitos como en retiros exitosos.

// El contrato debe llevar registro del número de depósitos y retiros.

// El contrato debe tener al menos una función external, una private y una view.




}

    // - Variables `Immutable` || `Constant`
    // - Variables de almacenamiento

    // - Mapping

    // - Events

    // - Custom Errors

    // - Constructor

    // - Modifier

    // - Función `external payable`

    // - Función `private`

    // - Función `external view`