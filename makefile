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

install:
	@echo "--> Installing"
	@go install -mod=readonly $(BUILD_FLAGS) ./cmd/alphachaind

run:
	alphachaind start --home ./.chaindata --x-crisis-skip-assert-invariants

init:
	rm -rf ./.chaindata/*
	alphachaind init alphachain --chain-id alphachain --home ./.chaindata
	alphachaind config chain-id alphachain --home ./.chaindata
	alphachaind config keyring-backend test --home ./.chaindata
	alphachaind keys add val --home ./.chaindata
	alphachaind add-genesis-account val 10000000000000000000000000stake --home ./.chaindata --keyring-backend test
	alphachaind gentx val 1000000000stake --home ./.chaindata --chain-id alphachain
	alphachaind collect-gentxs --home ./.chaindata
	alphachaind start --home ./.chaindata --x-crisis-skip-assert-invariants

reset:
	mv ./.chaindata/data/priv_validator_state.origin.json .
	rm -rf ./.chaindata/data/*
	mv ./priv_validator_state.origin.json ./.chaindata/data/
	cp ./.chaindata/data/priv_validator_state.origin.json ./.chaindata/data/priv_validator_state.json
	rm ./.chaindata/config/write-file*
