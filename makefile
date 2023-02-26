# TEST_PACKAGES=$(shell go list ./... | grep -v '/simulation' | grep -v '/cli')
TEST_PACKAGES=./...
VERSION := $(shell echo $(shell git describe --tags) | sed 's/^v//')
COMMIT := $(shell git log -1 --format='%H')

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

.PHONY: build
build:
	go build $(BUILD_FLAGS) -o build/alphachaind ./cmd/alphachaind

install:
	@echo "--> Installing"
	@go install -mod=readonly $(BUILD_FLAGS) ./cmd/alphachaind

run:
	alphachaind start --home ./.chaindata --json-rpc.api eth,txpool,personal,net,debug,web3,miner --api.enable --evm.tracer=json --trace --evm.max-tx-gas-wanted 125677000

init:
	rm -rf ./.chaindata/*
	alphachaind init alphachain --chain-id alphachain_9000-1 --home ./.chaindata
	alphachaind config chain-id alphachain_9000-1 --home ./.chaindata
	alphachaind config keyring-backend test --home ./.chaindata
	alphachaind keys add valkey --home ./.chaindata --keyring-backend test --algo eth_secp256k1
	alphachaind add-genesis-account valkey 10000000000000000000000000aphoton --home ./.chaindata --keyring-backend test
	alphachaind gentx valkey 10000000000aphoton --home ./.chaindata --chain-id alphachain_9000-1
	alphachaind collect-gentxs --home ./.chaindata
	alphachaind start --home ./.chaindata --json-rpc.api eth,txpool,personal,net,debug,web3,miner --api.enable

reset:
	mv ./.chaindata/data/priv_validator_state.origin.json .
	rm -rf ./.chaindata/data/*
	mv ./priv_validator_state.origin.json ./.chaindata/data/
	cp ./.chaindata/data/priv_validator_state.origin.json ./.chaindata/data/priv_validator_state.json
	rm ./.chaindata/config/write-file*
