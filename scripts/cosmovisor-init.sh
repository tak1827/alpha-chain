#!/bin/sh

CHAIN_HOME=$(pwd)/.chaindata
CHAIN_ID=alphachain_9000-1

# build
make build

export DAEMON_NAME=aphoton
export DAEMON_HOME=$CHAIN_HOME
export DAEMON_RESTART_AFTER_UPGRADE=true

