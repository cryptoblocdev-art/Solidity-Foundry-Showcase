<div align="center">

# Token Staking System

**A Foundry-powered ERC20 staking project with capped token supply and time-based rewards.**

![Solidity](https://img.shields.io/badge/Solidity-%5E0.8.20-363636?style=for-the-badge&logo=solidity)
![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-ERC20-4E5EE4?style=for-the-badge)
![Foundry](https://img.shields.io/badge/Built%20with-Foundry-FFDB1C?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-2E8B57?style=for-the-badge)
![Tests](https://img.shields.io/badge/Tests-20%20Passing-2E8B57?style=for-the-badge)

</div>

## Table of Contents

- [Overview](#overview)
- [How It Works](#how-it-works)
- [Features](#features)
- [Contracts](#contracts)
- [Project Structure](#project-structure)
- [Quickstart](#quickstart)
- [Environment](#environment)
- [Local Deployment](#local-deployment)
- [User Flow](#user-flow)
- [Test Coverage](#test-coverage)
- [Tech Stack](#tech-stack)
- [License](#license)

## Overview

This project combines a capped ERC20 token, `CustomToken`, with a staking contract, `Staking`.

Users approve the staking contract, deposit tokens, earn rewards over time, and later claim rewards or unstake their principal. The current demo setup uses `CustomToken` as both the staking token and the reward token.

## How It Works

```text
User owns CTK
    |
    v
User approves Staking contract
    |
    v
User stakes tokens
    |
    v
Rewards accrue over time
    |
    +-- claimRewards() -> receive reward tokens
    |
    +-- unstake()      -> withdraw staked tokens
```

Rewards are calculated with:

```text
staked amount * reward rate * time elapsed / 1e18
```

## Features

| Category | Details |
| --- | --- |
| ERC20 Token | `CustomToken` extends OpenZeppelin ERC20 and Ownable. |
| Supply Cap | Maximum supply is immutable and enforced on every mint. |
| Minting | Only the token owner can mint, and minting cannot exceed the cap. |
| Staking | Users deposit approved staking tokens into the staking contract. |
| Rewards | Rewards accrue over time based on stake size and reward rate. |
| Claims | Users can claim earned rewards without unstaking. |
| Unstaking | Users can withdraw part or all of their staked balance. |
| Safety | Custom errors, zero-address checks, zero-amount checks, and balance validation. |
| Tooling | Foundry scripts, tests, and Makefile commands are included. |

## Contracts

### `src/CustomToken.sol`

| Function | Access | Description |
| --- | --- | --- |
| `constructor(uint256 maxSupply, uint256 initialSupply)` | Deploy | Sets cap and optionally mints initial supply to the deployer. |
| `mint(address to, uint256 amount)` | Owner | Mints new tokens without exceeding `maxSupply`. |
| `maxSupply()` | Public | Returns the immutable supply cap. |

Token details:

| Property | Value |
| --- | --- |
| Name | `Custom Token` |
| Symbol | `CTK` |
| Decimals | `18` |

### `src/Staking.sol`

| Function | Access | Description |
| --- | --- | --- |
| `stake(uint256 amount)` | Public | Transfers approved staking tokens into the contract. |
| `unstake(uint256 amount)` | Public | Withdraws staked tokens and preserves earned rewards. |
| `claimRewards()` | Public | Claims accumulated rewards for the caller. |
| `earned(address account)` | Public view | Returns stored and pending rewards for an account. |

State exposed by the contract:

| Variable | Description |
| --- | --- |
| `stakingToken()` | ERC20 token users deposit. |
| `rewardToken()` | ERC20 token paid as rewards. |
| `rewardRate()` | Reward rate used by the time-based reward formula. |
| `stakedBalance(address)` | Amount currently staked by a user. |
| `rewards(address)` | Stored rewards for a user. |
| `lastUpdated(address)` | Last timestamp used for reward accounting. |

## Project Structure

```text
token-staking/
|-- Makefile
|-- foundry.toml
|-- script/
|   |-- DeployCustomToken.s.sol
|   `-- DeployStaking.s.sol
|-- src/
|   |-- CustomToken.sol
|   `-- Staking.sol
`-- test/
    |-- CustomToken.t.sol
    `-- Staking.t.sol
```

## Quickstart

Move into this project:

```bash
cd token-staking
```

Install dependencies if needed:

```bash
forge install OpenZeppelin/openzeppelin-contracts
```

Build the contracts:

```bash
forge build
```

Run all tests:

```bash
forge test
```

Run focused test files:

```bash
forge test --match-path test/CustomToken.t.sol
forge test --match-path test/Staking.t.sol
```

The included Makefile provides shortcuts:

```bash
make build
make test
make test-token
make test-staking
```

## Environment

Create a `.env` file in `token-staking`:

```bash
touch .env
```

Add deployment values:

```env
PRIVATE_KEY=0xYOUR_PRIVATE_KEY
LOCALHOST_RPC_URL=http://127.0.0.1:8545
MAX_SUPPLY=1000000000000000000000000
INITIAL_SUPPLY=500000000000000000000000
REWARD_RATE=1000000000000000
STAKING_TOKEN=0xYOUR_TOKEN_ADDRESS
REWARD_TOKEN=0xYOUR_TOKEN_ADDRESS
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

Deploy `CustomToken`:

```bash
forge script script/DeployCustomToken.s.sol:DeployCustomToken \
  --rpc-url http://127.0.0.1:8545 \
  --broadcast
```

Update `.env` with the deployed token address:

```env
STAKING_TOKEN=0xDEPLOYED_CUSTOM_TOKEN
REWARD_TOKEN=0xDEPLOYED_CUSTOM_TOKEN
```

Deploy `Staking`:

```bash
forge script script/DeployStaking.s.sol:DeployStaking \
  --rpc-url http://127.0.0.1:8545 \
  --broadcast
```

Fund the staking contract with reward tokens before users claim rewards:

```bash
cast send <TOKEN_ADDRESS> "transfer(address,uint256)" <STAKING_ADDRESS> <REWARD_AMOUNT> \
  --private-key <DEPLOYER_PRIVATE_KEY> \
  --rpc-url http://127.0.0.1:8545
```

## User Flow

Check a user's CTK balance:

```bash
cast call <TOKEN_ADDRESS> "balanceOf(address)(uint256)" <USER_ADDRESS> \
  --rpc-url http://127.0.0.1:8545
```

Approve the staking contract:

```bash
cast send <TOKEN_ADDRESS> "approve(address,uint256)" <STAKING_ADDRESS> <AMOUNT> \
  --private-key <USER_PRIVATE_KEY> \
  --rpc-url http://127.0.0.1:8545
```

Stake tokens:

```bash
cast send <STAKING_ADDRESS> "stake(uint256)" <AMOUNT> \
  --private-key <USER_PRIVATE_KEY> \
  --rpc-url http://127.0.0.1:8545
```

Preview earned rewards:

```bash
cast call <STAKING_ADDRESS> "earned(address)(uint256)" <USER_ADDRESS> \
  --rpc-url http://127.0.0.1:8545
```

Claim rewards:

```bash
cast send <STAKING_ADDRESS> "claimRewards()" \
  --private-key <USER_PRIVATE_KEY> \
  --rpc-url http://127.0.0.1:8545
```

Unstake tokens:

```bash
cast send <STAKING_ADDRESS> "unstake(uint256)" <AMOUNT> \
  --private-key <USER_PRIVATE_KEY> \
  --rpc-url http://127.0.0.1:8545
```

## Test Coverage

The current suite covers:

- Token metadata, owner, supply cap, and initial supply setup
- Initial supply minting to the owner
- Invalid token constructor inputs
- Owner-only minting
- Zero-amount mint rejection
- Max supply enforcement
- Staking constructor setup
- Zero token address and zero reward rate rejection
- Stake balance accounting
- Zero-amount staking rejection
- Unstaking and partial unstaking
- Insufficient staked balance rejection
- Time-based reward accrual
- Reward claiming
- Claim rejection when no rewards exist
- Reward preservation when unstaking

Expected result:

```text
Ran 8 tests for test/CustomToken.t.sol:CustomTokenTest
Ran 12 tests for test/Staking.t.sol:StakingTest
Suite result: ok. 20 passed; 0 failed; 0 skipped
```

## Tech Stack

| Tool | Purpose |
| --- | --- |
| Solidity `^0.8.20` | Smart contract implementation |
| OpenZeppelin Contracts | ERC20 and Ownable base contracts |
| Foundry | Build, test, local chain, and deployment tooling |
| Forge Standard Library | Test utilities and scripting helpers |
| Make | Local command shortcuts |

## License

Released under the MIT License.
