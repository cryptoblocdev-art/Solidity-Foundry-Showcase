# Solidity Foundry Showcase

A portfolio repository containing multiple Solidity projects built with Foundry, focused on smart contract architecture, testing, deployment workflows, and practical Web3 use cases.

## Projects

### [Crowdfunding](./crowdfunding)
An ETH crowdfunding project with contribution tracking, creator withdrawals, and contributor refunds if the funding goal is not reached.

**Highlights:**
- payable functions
- deadline-based campaign logic
- refund flow
- withdrawal flow
- custom errors
- Foundry tests and deployment script

### [Token Staking System](./token-staking)
A capped ERC20 token paired with a staking contract that lets users stake tokens, earn rewards over time, claim rewards, and unstake.

**Highlights:**
- ERC20 token design
- owner-only minting
- capped supply enforcement
- staking and reward accounting
- time-based reward logic
- Foundry tests and deployment scripts

### [MultiSig Treasury](./multisig-treasury)
A multi-owner treasury wallet that requires a configurable number of confirmations before transactions can be executed.

**Highlights:**
- multiple owners
- confirmation threshold
- transaction submission and approval flow
- confirmation revocation
- low-level call execution
- Foundry tests and deployment script

## Repository Structure

```text
Solidity-Foundry-Showcase/
├── crowdfunding/
├── token-staking/
└── multisig-treasury/
```

## Tech Stack

- Solidity
- Foundry
- Forge
- Cast
- Anvil
- OpenZeppelin

## Purpose

This repository is part of my Solidity portfolio and is designed to demonstrate:

- smart contract fundamentals
- secure contract patterns
- testing with Foundry
- deployment scripting
- practical on-chain workflows

## License

MIT
