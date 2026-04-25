.DEFAULT_GOAL := help
.PHONY: help build test test-token test-staking anvil deploy-token deploy-staking

-include .env
export

RPC_URL ?= $(LOCALHOST_RPC_URL)

help:
	@echo "Available targets:"
	@echo "  make build         - Build contracts"
	@echo "  make test          - Run all tests"
	@echo "  make test-token    - Run CustomToken tests"
	@echo "  make test-staking  - Run Staking tests"
	@echo "  make anvil         - Start local Anvil node"
	@echo "  make deploy-token  - Deploy CustomToken using .env values"
	@echo "  make deploy-staking - Deploy Staking using .env values"

build:
	forge build

test:
	forge test

test-token:
	forge test --match-path test/CustomToken.t.sol

test-staking:
	forge test --match-path test/Staking.t.sol

anvil:
	anvil

deploy-token:
	forge script script/DeployCustomToken.s.sol:DeployCustomToken --rpc-url $(RPC_URL) --broadcast

deploy-staking:
	forge script script/DeployStaking.s.sol:DeployStaking --rpc-url $(RPC_URL) --broadcast
