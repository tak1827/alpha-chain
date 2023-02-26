#!/bin/sh

CHAIN_HOME=$(pwd)/.chaindata
CHAIN_ID=alphachain_9000-1

alphachaind tx gov submit-legacy-proposal software-upgrade cosmovisor-test --title=cosmovisor-test-1 --description='cosmovisor test upgrade' --upgrade-height=50 --upgrade-info='{"binaries":{"darwin/arm64":"https://github.com/tak1827/alpha-chain/releases/download/v0.0.2/alphachaind?checksum=sha256:2dd43260fa8028d6553caa266fc7a75f6913b02e41e4845eac42767106e79405"}}' --deposit=10000000aphoton --gas=300000 --from=valkey --keyring-backend=test --yes --home=$CHAIN_HOME --chain-id=$CHAIN_ID --trace --sequence=1

alphachaind tx gov vote 1 yes --from=valkey --keyring-backend=test --yes --home=$CHAIN_HOME --chain-id=$CHAIN_ID --sequence=2
