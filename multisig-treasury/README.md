<div align="center">

# MultiSig Treasury

**A Foundry-powered Solidity treasury that requires multiple owner confirmations before funds can move.**

![Solidity](https://img.shields.io/badge/Solidity-%5E0.8.20-363636?style=for-the-badge&logo=solidity)
![Foundry](https://img.shields.io/badge/Built%20with-Foundry-FFDB1C?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-2E8B57?style=for-the-badge)
![Tests](https://img.shields.io/badge/Tests-19%20Passing-2E8B57?style=for-the-badge)

</div>

## Table of Contents

- [Overview](#overview)
- [How It Works](#how-it-works)
- [Features](#features)
- [Contract API](#contract-api)
- [Project Structure](#project-structure)
- [Quickstart](#quickstart)
- [Environment](#environment)
- [Local Deployment](#local-deployment)
- [Manual Multisig Flow on Anvil](#manual-multisig-flow-on-anvil)
- [Test Coverage](#test-coverage)
- [Tech Stack](#tech-stack)
- [License](#license)

## Overview

`MultiSigTreasury` is a shared treasury wallet for teams, DAOs, or any group that should not rely on one private key to control funds.

An owner can propose a transaction, other owners can confirm it, and the transaction can only be executed after the configured confirmation threshold is reached.

## How It Works

```text
Deposit ETH
    |
    v
Owner submits transaction
    |
    v
Owners confirm transaction
    |
    v
Threshold reached?
    |
    +-- no  -> wait for more confirmations
    |
    +-- yes -> execute transaction
```

Confirmations can be revoked before execution, giving owners a chance to change their mind if a transaction looks wrong.

## Features

| Category | Details |
| --- | --- |
| Ownership | Multiple approved owners with duplicate and zero-address protection. |
| Threshold | Configurable required confirmation count at deployment. |
| Submissions | Owners can submit ETH transfers or arbitrary calldata transactions. |
| Confirmations | Owners can confirm once and revoke before execution. |
| Execution | Approved transactions execute through low-level `call`. |
| Safety | Custom errors, owner-only modifiers, transaction existence checks, and double-execution prevention. |
| Observability | Events for deposits, submissions, confirmations, revocations, and executions. |
| Tooling | Built, tested, and deployed with Foundry. |

## Contract API

### Core Functions

| Function | Access | Description |
| --- | --- | --- |
| `submitTransaction(address to, uint256 value, bytes data)` | Owner | Creates a pending treasury transaction. |
| `confirmTransaction(uint256 txIndex)` | Owner | Adds the caller's confirmation to a pending transaction. |
| `revokeConfirmation(uint256 txIndex)` | Owner | Removes the caller's confirmation before execution. |
| `executeTransaction(uint256 txIndex)` | Owner | Executes a confirmed transaction. |

### View Functions

| Function | Description |
| --- | --- |
| `getOwners()` | Returns all treasury owners. |
| `getTransactionCount()` | Returns the total number of submitted transactions. |
| `getTransaction(uint256 txIndex)` | Returns transaction target, value, data, execution status, and confirmation count. |

### Events

| Event | Emitted When |
| --- | --- |
| `Deposit` | ETH is sent to the treasury. |
| `TransactionSubmitted` | An owner submits a transaction. |
| `TransactionConfirmed` | An owner confirms a transaction. |
| `ConfirmationRevoked` | An owner revokes a confirmation. |
| `TransactionExecuted` | A confirmed transaction is executed. |

## Project Structure

```text
multisig-treasury/
|-- foundry.toml
|-- script/
|   `-- DeployMultiSigTreasury.s.sol
|-- src/
|   `-- MultiSigTreasury.sol
`-- test/
    `-- MultiSigTreasury.t.sol
```

## Quickstart

Clone the repository, then move into this project:

```bash
cd multisig-treasury
```

Install dependencies if needed:

```bash
forge install
```

Build the contracts:

```bash
forge build
```

Run the test suite:

```bash
forge test
```

Run the multisig tests only:

```bash
forge test --match-path test/MultiSigTreasury.t.sol
```

Run tests with traces:

```bash
forge test -vvv
```

## Environment

Create a `.env` file in `multisig-treasury`:

```bash
touch .env
```

Add deployment values:

```env
PRIVATE_KEY=0xYOUR_PRIVATE_KEY
OWNER_1=0xOWNER_ONE_ADDRESS
OWNER_2=0xOWNER_TWO_ADDRESS
OWNER_3=0xOWNER_THREE_ADDRESS
REQUIRED_CONFIRMATIONS=2
```

## Local Deployment

Start Anvil in a separate terminal:

```bash
anvil
```

Load your environment variables:

```bash
set -a
source .env
set +a
```

Deploy to the local chain:

```bash
forge script script/DeployMultiSigTreasury.s.sol:DeployMultiSigTreasury \
  --rpc-url http://127.0.0.1:8545 \
  --broadcast
```

## Manual Multisig Flow on Anvil

This project can be tested manually on a local Anvil node using three owner accounts.

### Example `.env`

Create a `.env` file in the `multisig-treasury` directory and add real Anvil addresses and private keys:

```env
PRIVATE_KEY=0xDEPLOYER_PRIVATE_KEY

OWNER_1=0xOWNER1_ADDRESS
OWNER_2=0xOWNER2_ADDRESS
OWNER_3=0xOWNER3_ADDRESS

OWNER_1_PK=0xOWNER1_PRIVATE_KEY
OWNER_2_PK=0xOWNER2_PRIVATE_KEY
OWNER_3_PK=0xOWNER3_PRIVATE_KEY

REQUIRED_CONFIRMATIONS=2
RPC_URL=http://127.0.0.1:8545
```

Environment variable notes:

| Variable | Purpose |
| --- | --- |
| `PRIVATE_KEY` | Used to deploy the contract. |
| `OWNER_1`, `OWNER_2`, `OWNER_3` | Multisig owner addresses. |
| `OWNER_1_PK`, `OWNER_2_PK`, `OWNER_3_PK` | Private keys used to manually interact as each owner. |
| `REQUIRED_CONFIRMATIONS` | Number of owner confirmations required before execution. |
| `RPC_URL` | Local Anvil RPC endpoint. |

### 1. Load Environment Variables

```bash
set -a
source .env
set +a
```

### 2. Deploy the Treasury

```bash
forge script script/DeployMultiSigTreasury.s.sol:DeployMultiSigTreasury \
  --rpc-url $RPC_URL \
  --broadcast
```

After deployment, export the treasury address:

```bash
export TREASURY=0xYOUR_DEPLOYED_TREASURY_ADDRESS
```

### 3. Fund the Treasury With ETH

The contract has a `receive()` function, so it can accept ETH directly.

Fund it with `5 ETH` from owner 1:

```bash
cast send $TREASURY \
  --value 5ether \
  --private-key $OWNER_1_PK \
  --rpc-url $RPC_URL
```

Check the treasury balance:

```bash
cast balance $TREASURY --rpc-url $RPC_URL
```

### 4. Submit a Transaction

Set a recipient address:

```bash
export RECIPIENT=0xRECIPIENT_ADDRESS
```

Submit a transaction to send `1 ETH` from the treasury to the recipient:

```bash
cast send $TREASURY \
  "submitTransaction(address,uint256,bytes)" \
  $RECIPIENT 1000000000000000000 0x \
  --private-key $OWNER_1_PK \
  --rpc-url $RPC_URL
```

Notes:

- `1000000000000000000` is `1 ETH` in wei.
- `0x` means empty calldata.
- The first submitted transaction will have index `0`.

Check how many transactions exist:

```bash
cast call $TREASURY "getTransactionCount()(uint256)" --rpc-url $RPC_URL
```

Check transaction details:

```bash
cast call $TREASURY \
  "getTransaction(uint256)(address,uint256,bytes,bool,uint256)" \
  0 \
  --rpc-url $RPC_URL
```

### 5. Confirm the Transaction

Confirm with owner 1:

```bash
cast send $TREASURY \
  "confirmTransaction(uint256)" 0 \
  --private-key $OWNER_1_PK \
  --rpc-url $RPC_URL
```

Confirm with owner 2:

```bash
cast send $TREASURY \
  "confirmTransaction(uint256)" 0 \
  --private-key $OWNER_2_PK \
  --rpc-url $RPC_URL
```

Check transaction details again:

```bash
cast call $TREASURY \
  "getTransaction(uint256)(address,uint256,bytes,bool,uint256)" \
  0 \
  --rpc-url $RPC_URL
```

At this point, the transaction should show:

```text
executed = false
numConfirmations = 2
```

### 6. Execute the Transaction

Once the confirmation threshold is met, any owner can execute it.

Example with owner 1:

```bash
cast send $TREASURY \
  "executeTransaction(uint256)" 0 \
  --private-key $OWNER_1_PK \
  --rpc-url $RPC_URL
```

### 7. Verify Execution

Check the recipient ETH balance:

```bash
cast balance $RECIPIENT --rpc-url $RPC_URL
```

Check the treasury ETH balance:

```bash
cast balance $TREASURY --rpc-url $RPC_URL
```

Check transaction details again:

```bash
cast call $TREASURY \
  "getTransaction(uint256)(address,uint256,bytes,bool,uint256)" \
  0 \
  --rpc-url $RPC_URL
```

Now the transaction should show:

```text
executed = true
numConfirmations = 2
```

### 8. Optional: Test Revoke Confirmation

Submit a second transaction:

```bash
cast send $TREASURY \
  "submitTransaction(address,uint256,bytes)" \
  $RECIPIENT 500000000000000000 0x \
  --private-key $OWNER_1_PK \
  --rpc-url $RPC_URL
```

This new transaction will be index `1`.

Confirm it with owner 1:

```bash
cast send $TREASURY \
  "confirmTransaction(uint256)" 1 \
  --private-key $OWNER_1_PK \
  --rpc-url $RPC_URL
```

Revoke the confirmation:

```bash
cast send $TREASURY \
  "revokeConfirmation(uint256)" 1 \
  --private-key $OWNER_1_PK \
  --rpc-url $RPC_URL
```

Check the transaction again:

```bash
cast call $TREASURY \
  "getTransaction(uint256)(address,uint256,bytes,bool,uint256)" \
  1 \
  --rpc-url $RPC_URL
```

It should now show:

```text
executed = false
numConfirmations = 0
```

## Test Coverage

The current suite covers:

- Valid owner and threshold setup
- Empty owner list rejection
- Zero confirmation threshold rejection
- Threshold greater than owner count rejection
- Zero-address owner rejection
- Duplicate owner rejection
- Owner-only transaction submission
- Owner-only confirmation and execution
- Confirmation revocation
- Duplicate confirmation prevention
- Execution blocked before enough confirmations
- Execution blocked after a transaction has already run
- Missing transaction checks for confirm, revoke, and execute flows

Current result:

```text
Ran 19 tests for test/MultiSigTreasury.t.sol:MultiSigTreasuryTest
Suite result: ok. 19 passed; 0 failed; 0 skipped
```

## Tech Stack

| Tool | Purpose |
| --- | --- |
| Solidity `^0.8.20` | Smart contract implementation |
| Foundry | Build, test, local chain, and deployment tooling |
| Forge Standard Library | Test utilities and scripting helpers |

## License

Released under the MIT License.
