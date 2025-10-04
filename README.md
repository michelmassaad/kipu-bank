# KipuBank 🏦

[![Solidity](https://img.shields.io/badge/Solidity-0.8.x-blue?logo=ethereum&logoColor=white)](https://soliditylang.org/) 

## Descripción
**KipuBank** es un smart contract en **Solidity** que permite a los usuarios depositar y retirar ETH de forma segura.  
Implementa límites por transacción y un límite global de depósitos, usando buenas prácticas de desarrollo, errores personalizados y el patrón **checks-effects-interactions** para proteger contra vulnerabilidades como reentrancy.

---

## Características

- Depositar ETH en una bóveda personal.
- Retirar ETH hasta un **límite fijo** por transacción.
- Límite global de depósitos (`bankCap`) definido en el despliegue.
- Eventos para depósitos y retiros exitosos.
- Contadores de depósitos y retiros.
- Funciones `external`, `private` y `view`.
- Seguridad contra ataques de **reentrancy**.
- Errores personalizados para mayor claridad y seguridad.

---

## Errores Personalizados

| Error | Descripción |
|-------|------------|
| `BankCapExceeded` | Se superó el límite global de depósitos |
| `WithdrawalLimitExceeded` | Se superó el límite de retiro por transacción |
| `InsufficientBalance` | No hay saldo suficiente para retirar |
| `InvalidAmount` | Monto inválido (0) |
| `WithdrawalFailed(bytes errorData)` | La transferencia de ETH falló |

---

## Despliegue

1. Abrir [Remix IDE](https://remix.ethereum.org/).  
2. Crear un archivo `KipuBank.sol` en la carpeta `/contracts`.  
3. Copiar y pegar el código del contrato.  
4. Compilar con Solidity **0.8.x**.  
5. Ir al apartado **Deploy & Run Transactions**.
6. Seleccionar el entorno testnet (`Remix VM` o inyectar proveedor con MetaMask).
7. Ir a la sección **Deploy** para ver los parámetros del constructor.
8. Configurar los parámetros del smart contract:  
   - `_withdrawalLimit` → Límite de retiro por transacción (en wei).  
   - `_bankCap` → Límite global de depósitos (en wei).  
9. Una vez configurados, hacer clic en **Transact**.
10. Para aprender a usar las funciones del contrato, revisa los [Ejemplos de Uso](#ejemplos-de-uso).

---

## Interacción con el contrato

### Funciones principales

| Función | Tipo | Descripción |
|---------|------|------------|
| `deposit()` | external payable | Deposita ETH en la bóveda del usuario |
| `withdrawal(uint256 amount)` | external | Retira ETH de la bóveda del usuario hasta el límite |
| `_transferEth(address payable to, uint256 amount)` | private | Realiza transferencia segura de ETH |
| `getBalance(address user)` | external view | Consulta el saldo de un usuario |

### Eventos

- `Deposit_Eth(address indexed user, uint256 amount)` → Emitido al realizar un depósito.  
- `Withdrawal_Eth(address indexed user, uint256 amount)` → Emitido al realizar un retiro.  

---

## Ejemplo de uso en Remix

1. Llamar a la función `deposit()`, ingresar el monto en **wei** en el apartado de Value y hacer clic en **deposit**.  
2. Llamar a la función `withdrawal(amount)`, ingresar en el contrato el monto a retirar en **wei** y hacer clic en **withdrawal**.  
3. Consultar balances con `getBalance(userAddress)`.  
4. Consultar contadores con `TotalDeposits()` y `TotalWithdrawals()`.  

---

## Seguridad y buenas prácticas

- Uso de **errores personalizados** para mayor claridad.  
- Patrón **checks-effects-interactions** implementado en el retiro.  
- Protección contra **reentrancy** con `reentrancyGuard`.  
- Variables `immutable` para los límites de retiro y depósito.  

---
