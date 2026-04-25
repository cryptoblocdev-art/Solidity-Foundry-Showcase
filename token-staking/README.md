# Token Staking System

A Solidity project built with Foundry that includes a capped ERC20 token and a staking contract with time-based rewards

## What Is Staking?

Staking is the process of locking tokens into a smart contract in order to earn rewards over time.

In this project, users deposit `CustomToken` into the `Staking` contract. While those tokens remain staked, rewards accumulate based on the amount staked and the amount of time that has passed.

The staking flow is simple:

1. a user holds `CustomToken`
2. the user approves the `Staking` contract to spend tokens
3. the user stakes a chosen amount
4. rewards build up over time
5. the user can claim rewards
6. the user can unstake some or all of their tokens later

This project uses the same token for both:
- the staking token
- the reward token

That means users stake `CustomToken` and also receive rewards in `CustomToken`.

## Contracts

### `CustomToken.sol`

A capped ERC20 token with:
- initial supply minting
- owner-only minting
- max supply enforcement

### `Staking.sol`

A staking contract that allows users to:
- stake tokens
- earn rewards over time
- claim rewards
- unstake tokens

## Key Concepts

- ERC20 inheritance
- OpenZeppelin integration
- Ownable access control
- capped supply enforcement
- token approvals and transfers
- staking balances
- reward accounting
- time-based reward calculation
- internal reward updates
- Foundry testing
- deployment scripting

## Project Structure

```text
src/
  CustomToken.sol
  Staking.sol

test/
  CustomToken.t.sol
  Staking.t.sol

script/
  DeployCustomToken.s.sol
  DeployStaking.s.sol
```

## Setup

Install dependencies:

```bash
forge install OpenZeppelin/openzeppelin-contracts
```
Build:

```bash
forge build
```
Run all tests:

```bash
forge test
```
Run specific test files:

```bash
forge test --match-path test/CustomToken.t.sol
forge test --match-path test/Staking.t.sol
```
## Environment Variables

Create a `.env` file in the `token-staking` directory:

```bash
touch .env
```
Example values:

```bash
PRIVATE_KEY=0xYOUR_PRIVATE_KEY
MAX_SUPPLY=1000000000000000000000000
INITIAL_SUPPLY=500000000000000000000000
REWARD_RATE=1000000000000000
STAKING_TOKEN=0xYOUR_TOKEN_ADDRESS
REWARD_TOKEN=0xYOUR_TOKEN_ADDRESS
```
## Local Deployment Flow

From this project directory:

```bash
cd token-staking
```
Start Anvil in a new terminal:

```bash
anvil
```
Load environment variables before running the Foundry deploy scripts:

```bash
set -a
source .env
set +a
```

Deploy `CustomToken` with Foundry:

```bash
forge script script/DeployCustomToken.s.sol:DeployCustomToken --rpc-url http://127.0.0.1:8545 --broadcast
```

Update `.env` with the deployed token address for:

- `STAKING_TOKEN`
- `REWARD_TOKEN`

Then deploy `Staking` with Foundry:

```bash
forge script script/DeployStaking.s.sol:DeployStaking --rpc-url http://127.0.0.1:8545 --broadcast
```
## How Users Interact With Staking

From a user's point of view, the staking contract works in four steps:

1. The user must own the staking token.
2. The user approves the staking contract to transfer some of their tokens.
3. The user calls `stake(amount)` on the staking contract.
4. While tokens remain staked, rewards accumulate over time.

The staking contract does not take tokens automatically from a user's wallet.
ERC20 tokens require an approval first. The approval tells the staking contract:
"you may transfer up to this many of my tokens when I call `stake`."

### 1. Get staking tokens

The user needs a balance of the staking token before they can stake. For this
demo, the deployer receives the initial token supply when `CustomToken` is
deployed.

Check a user's token balance:

```bash
cast call <TOKEN_ADDRESS> "balanceOf(address)(uint256)" <USER_ADDRESS> --rpc-url http://127.0.0.1:8545
```
### 2. Approve the staking contract

Before staking, the user approves the staking contract to spend the token:

```bash
cast send <TOKEN_ADDRESS> "approve(address,uint256)" <STAKING_CONTRACT_ADDRESS> <AMOUNT> \
  --private-key <USER_PRIVATE_KEY> \
  --rpc-url http://127.0.0.1:8545
```

Example amount for `100` tokens with 18 decimals:

```text
100000000000000000000
```


### 3. Stake tokens

After approving, the user stakes tokens by calling `stake(amount)`:

```bash
cast send <STAKING_CONTRACT_ADDRESS> "stake(uint256)" <AMOUNT> \
  --private-key <USER_PRIVATE_KEY> \
  --rpc-url http://127.0.0.1:8545
```

When this succeeds, the staking contract transfers the tokens from the user's
wallet into the staking contract and records the user's staked balance.

Check a user's staked balance:

```bash
cast call <STAKING_CONTRACT_ADDRESS> "stakedBalance(address)(uint256)" <USER_ADDRESS> --rpc-url http://127.0.0.1:8545
```

### 4. Earn rewards over time

Rewards are calculated from:

```text
staked amount * reward rate * time elapsed / 1e18
```

The contract updates a user's rewards whenever they stake, unstake, or claim.
Users can preview their current earned rewards with:

```bash
cast call <STAKING_CONTRACT_ADDRESS> "earned(address)(uint256)" <USER_ADDRESS> --rpc-url http://127.0.0.1:8545
```

### 5. Claim rewards

To claim accumulated rewards:

```bash
cast send <STAKING_CONTRACT_ADDRESS> "claimRewards()" \
  --private-key <USER_PRIVATE_KEY> \
  --rpc-url http://127.0.0.1:8545
```

The staking contract must hold enough reward tokens before users claim. If the
staking token and reward token are the same token, the owner can fund rewards by
transferring tokens to the staking contract:

```bash
cast send <TOKEN_ADDRESS> "transfer(address,uint256)" <STAKING_CONTRACT_ADDRESS> <REWARD_AMOUNT> \
  --private-key <DEPLOYER_PRIVATE_KEY> \
  --rpc-url http://127.0.0.1:8545
```

### 6. Unstake tokens

Users can withdraw staked tokens with `unstake(amount)`:

```bash
cast send <STAKING_CONTRACT_ADDRESS> "unstake(uint256)" <AMOUNT> \
  --private-key <USER_PRIVATE_KEY> \
  --rpc-url http://127.0.0.1:8545
```

Unstaking returns the staked tokens to the user and preserves any rewards earned
up to that point. The user can claim those rewards separately with
`claimRewards()`.

## Manual Test Flow

1. Fund the staking contract with reward tokens.
2. Approve the staking contract.
3. Stake tokens.
4. Advance time.
5. Check `earned(address)`.
6. Claim rewards.
7. Unstake tokens.

## Git

```bash
git add .
git commit -m "Rebuild token staking project with tests and deploy scripts"
```

## License

MIT
