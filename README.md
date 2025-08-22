# Volstack: Decentralized Options Trading on Stacks

## Overview
Volstack is a smart contract implementation for decentralized options trading on the Stacks blockchain. It allows users to create, exercise, and expire options contracts in a trustless manner.

## Features
- Create call and put options
- Exercise options based on market price
- Automatic expiry mechanism
- Admin controls for contract management
- Built-in profit calculations
- Safety checks for all operations

## Contract Functions

### Admin Functions
- `set-admin`: Update the contract administrator

### User Functions
- `mint-option`: Create a new option contract
- `exercise-option`: Exercise an existing option
- `expire-option`: Expire an option after its expiry date

## Error Codes
```clarity
err-unauthorized (u100)      // Unauthorized access
err-invalid-option (u101)    // Invalid option parameters
err-expired (u102)           // Option has expired
err-not-expired (u103)       // Option hasn't expired yet
err-already-exercised (u104) // Option already exercised
```

## Usage Example
```clarity
;; Mint a new call option
(contract-call? .volstack mint-option true u1000 u100000 u5)

;; Exercise an option
(contract-call? .volstack exercise-option u1 u1200)

;; Expire an option
(contract-call? .volstack expire-option u1)
```

## Requirements
- Clarity Smart Contract Language
- Stacks Blockchain 2.0 or higher

## Security Considerations
- All functions include proper validation checks
- Admin functions are protected with authorization checks
- Options can only be exercised by their owners
- Built-in protection against reentrancy attacks


---
*Note: This is a prototype implementation. Please audit thoroughly before using in production.*
