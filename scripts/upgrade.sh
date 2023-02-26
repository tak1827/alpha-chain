#!/bin/sh

CHAIN_HOME=$(pwd)/.chaindata
CHAIN_ID=alphachain_9000-1

alphachaind tx gov submit-legacy-proposal software-upgrade cosmovisor-test --title=cosmovisor-test-1 --description='cosmovisor test upgrade' --upgrade-height=100 --upgrade-info='{"binaries":{"darwin/arm64":"https://github.com/tak1827/alpha-chain/releases/download/v0.0.3/alphachaind?checksum=sha256:6023f93e5def2c076b7ddf0bedb7d0e6d466005cfcd27e1d4b38d671f9f68dc8"}}' --deposit=10000000aphoton --gas=300000 --from=valkey --keyring-backend=test --yes --home=$CHAIN_HOME --chain-id=$CHAIN_ID --trace --sequence=1

alphachaind tx gov vote 1 yes --from=valkey --keyring-backend=test --yes --home=$CHAIN_HOME --chain-id=$CHAIN_ID --sequence=2
