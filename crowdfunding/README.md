<div align="center">

# Crowdfunding

**A Foundry-powered Solidity campaign contract for deadline-based funding, creator withdrawals, and contributor refunds.**

![Solidity](https://img.shields.io/badge/Solidity-%5E0.8.20-363636?style=for-the-badge&logo=solidity)
![Foundry](https://img.shields.io/badge/Built%20with-Foundry-FFDB1C?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-2E8B57?style=for-the-badge)
![Tests](https://img.shields.io/badge/Tests-12%20Passing-2E8B57?style=for-the-badge)

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
- [Test Coverage](#test-coverage)
- [Tech Stack](#tech-stack)
- [License](#license)

## Overview

`Crowdfunding` is a simple campaign contract where contributors send ETH toward a fixed funding goal before a deadline.

If the campaign succeeds, the creator can withdraw the raised funds after the deadline. If it misses the goal, contributors can claim refunds for their own contributions.

## How It Works

```text
Campaign created
    |
    v
Contributors send ETH before deadline
    |
    v
Deadline reached
    |
    +-- goal reached     -> creator withdraws funds
    |
    +-- goal not reached -> contributors claim refunds
```

The contract keeps contribution balances per address so failed campaigns can return funds to the original contributors.

## Features

| Category | Details |
| --- | --- |
| Campaign Setup | Creator, funding goal, and deadline are set at deployment. |
| Contributions | Anyone can contribute ETH before the deadline. |
| Accounting | Tracks total funds raised and each contributor's balance. |
| Withdrawal | Creator can withdraw once the campaign ends and the goal is reached. |
| Refunds | Contributors can reclaim funds if the campaign ends below goal. |
| Safety | Custom errors, deadline checks, goal checks, and double-withdraw prevention. |
| Observability | Events for contributions, withdrawals, and refunds. |
| Tooling | Built, tested, and deployed with Foundry. |

## Contract API

### Core Functions

| Function | Access | Description |
| --- | --- | --- |
| `contribute()` | Public payable | Adds ETH to the campaign before the deadline. |
| `withdrawFunds()` | Creator | Withdraws campaign funds after a successful campaign. |
| `claimRefund()` | Contributor | Refunds the caller after an unsuccessful campaign. |

### View Functions

| Function | Description |
| --- | --- |
| `getTimeLeft()` | Returns seconds remaining before the campaign deadline. |
| `isGoalReached()` | Returns whether total contributions meet or exceed the funding goal. |
| `contributions(address)` | Returns how much an address contributed. |
| `totalFunds()` | Returns total ETH contributed to the campaign. |

### Events

| Event | Emitted When |
| --- | --- |
| `ContributionReceived` | A contributor sends ETH to the campaign. |
| `FundsWithdrawn` | The creator withdraws after a successful campaign. |
| `RefundClaimed` | A contributor claims a refund after a failed campaign. |

## Project Structure

```text
crowdfunding/
|-- foundry.toml
|-- script/
|   `-- DeployCrowdfunding.s.sol
|-- src/
|   `-- Crowdfunding.sol
`-- test/
    `-- Crowdfunding.t.sol
```

## Quickstart

Move into this project:

```bash
cd crowdfunding
```

Install dependencies if needed:

```bash
forge install
```

Build the contract:

```bash
forge build
```

Run the test suite:

```bash
forge test
```

Run only the crowdfunding tests:

```bash
forge test --match-path test/Crowdfunding.t.sol
```

Run tests with traces:

```bash
forge test -vvv
```

## Environment

Create a `.env` file in `crowdfunding`:

```bash
touch .env
```

Add your deployer key:

```env
PRIVATE_KEY=0xYOUR_PRIVATE_KEY
```

The deploy script currently uses:

| Value | Default |
| --- | --- |
| Funding goal | `5 ether` |
| Duration | `7 days` |

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
forge script script/DeployCrowdfunding.s.sol:DeployCrowdfunding \
  --rpc-url http://127.0.0.1:8545 \
  --broadcast
```

## Test Coverage

The current suite covers:

- Constructor state setup
- Contribution balance tracking
- Zero-value contribution rejection
- Contributions blocked after the deadline
- Creator withdrawal after the goal is reached
- Non-creator withdrawal rejection
- Withdrawal blocked while the campaign is still active
- Withdrawal blocked when the goal is not reached
- Refunds after failed campaigns
- Refunds blocked after successful campaigns
- Refunds blocked for addresses with no contribution
- Double-refund prevention

Expected result:

```text
Ran 12 tests for test/Crowdfunding.t.sol:CrowdfundingTest
Suite result: ok. 12 passed; 0 failed; 0 skipped
```

## Tech Stack

| Tool | Purpose |
| --- | --- |
| Solidity `^0.8.20` | Smart contract implementation |
| Foundry | Build, test, local chain, and deployment tooling |
| Forge Standard Library | Test utilities and scripting helpers |

## License

Released under the MIT License.
