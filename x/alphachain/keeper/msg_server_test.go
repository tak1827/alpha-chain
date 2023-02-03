package keeper_test

import (
	"context"
	"testing"

	keepertest "alpha-chain/testutil/keeper"
	"alpha-chain/x/alphachain/keeper"
	"alpha-chain/x/alphachain/types"
	sdk "github.com/cosmos/cosmos-sdk/types"
)

func setupMsgServer(t testing.TB) (types.MsgServer, context.Context) {
	k, ctx := keepertest.AlphachainKeeper(t)
	return keeper.NewMsgServerImpl(*k), sdk.WrapSDKContext(ctx)
}
