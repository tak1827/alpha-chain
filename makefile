# TEST_PACKAGES=$(shell go list ./... | grep -v '/simulation' | grep -v '/cli')
TEST_PACKAGES=./...
VERSION := $(shell echo $(shell git describe --tags) | sed 's/^v//')
COMMIT := $(shell git log -1 --format='%H')
CHAIN_HOME=$(shell pwd)/.chaindata

ldflags = -X github.com/cosmos/cosmos-sdk/version.Name=alphachain \
	-X github.com/cosmos/cosmos-sdk/version.ServerName=wvchaind \
	-X github.com/cosmos/cosmos-sdk/version.Version=$(VERSION) \
	-X github.com/cosmos/cosmos-sdk/version.Commit=$(COMMIT)

BUILD_FLAGS := -tags "$(build_tags)" -ldflags '$(ldflags)'

# docker:
# 	docker run -it -v $(shell pwd):/root/vwbl-chain -w /root/vwbl-chain ttakayuki/vwbl bash

.PHONY: proto
proto:
	@ignite generate proto-go

lint:
	@echo "--> Running linter"
	@go vet ./...
	@golangci-lint run --timeout=10m

fmt:
	@gofmt -w -s -l .
	@misspell -w .

test:
	@echo "--> Running tests"
	@go test -mod=readonly -timeout=1m $(TEST_PACKAGES)

install:
	@echo "--> Installing"
	@go install -mod=readonly $(BUILD_FLAGS) ./cmd/alphachaind

run:
	alphachaind start --home $(CHAIN_HOME) --json-rpc.api eth,txpool,personal,net,debug,web3,miner --api.enable --evm.tracer=json --trace --evm.max-tx-gas-wanted 125677000

init:
	rm -rf $(CHAIN_HOME)/*
	alphachaind init alphachain --chain-id alphachain_9000-1 --home $(CHAIN_HOME) --staking-bond-denom=aphoton

# Change parameter token denominations to aphoton
	cat $(CHAIN_HOME)/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="aphoton"' > $(CHAIN_HOME)/config/tmp_genesis.json && mv $(CHAIN_HOME)/config/tmp_genesis.json $(CHAIN_HOME)/config/genesis.json
	cat $(CHAIN_HOME)/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="aphoton"' > $(CHAIN_HOME)/config/tmp_genesis.json && mv $(CHAIN_HOME)/config/tmp_genesis.json $(CHAIN_HOME)/config/genesis.json
	cat $(CHAIN_HOME)/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="aphoton"' > $(CHAIN_HOME)/config/tmp_genesis.json && mv $(CHAIN_HOME)/config/tmp_genesis.json $(CHAIN_HOME)/config/genesis.json

# Change default parameters
# Increase mem pool size
	sed -i -e "s/size = 5000/size = 500000/g" $(CHAIN_HOME)/config/config.toml
	sed -i -e "s/max_txs_bytes = 1073741824/max_txs_bytes = 4294967296/g" $(CHAIN_HOME)/config/config.toml

	alphachaind config chain-id alphachain_9000-1 --home $(CHAIN_HOME)
	alphachaind config keyring-backend test --home $(CHAIN_HOME)

# additional accounts
	alphachaind keys add alice --home $(CHAIN_HOME) --keyring-backend test --algo eth_secp256k1
	alphachaind add-genesis-account alice 10000000000000000000000000aphoton --home $(CHAIN_HOME) --keyring-backend test
	alphachaind keys add bob --home $(CHAIN_HOME) --keyring-backend test --algo eth_secp256k1
	alphachaind add-genesis-account bob 10000000000000000000000000aphoton --home $(CHAIN_HOME) --keyring-backend test
	alphachaind keys add tom --home $(CHAIN_HOME) --keyring-backend test --algo eth_secp256k1
	alphachaind add-genesis-account tom 10000000000000000000000000aphoton --home $(CHAIN_HOME) --keyring-backend test
# validator
	alphachaind keys add valkey --home $(CHAIN_HOME) --keyring-backend test --algo eth_secp256k1
	alphachaind add-genesis-account valkey 10000000000000000000000000aphoton --home $(CHAIN_HOME) --keyring-backend test
	alphachaind gentx valkey 10000000000aphoton --home $(CHAIN_HOME) --chain-id alphachain_9000-1
	alphachaind collect-gentxs --home $(CHAIN_HOME)
# backup priv_validator_state
	cp $(CHAIN_HOME)/data/priv_validator_state.json $(CHAIN_HOME)/data/priv_validator_state.origin.json
	alphachaind start --home $(CHAIN_HOME) --json-rpc.api eth,txpool,personal,net,debug,web3,miner --api.enable

reset:
	mv $(CHAIN_HOME)/data/priv_validator_state.origin.json .
	rm -rf $(CHAIN_HOME)/data/*
	mv ./priv_validator_state.origin.json $(CHAIN_HOME)/data/
	cp $(CHAIN_HOME)/data/priv_validator_state.origin.json $(CHAIN_HOME)/data/priv_validator_state.json
#	 rm $(CHAIN_HOME)/config/write-file*
