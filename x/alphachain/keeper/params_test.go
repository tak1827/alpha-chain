package keeper_test

import (
	"testing"

	testkeeper "alpha-chain/testutil/keeper"
	"alpha-chain/x/alphachain/types"
	"github.com/stretchr/testify/require"
)

func TestGetParams(t *testing.T) {
	k, ctx := testkeeper.AlphachainKeeper(t)
	params := types.DefaultParams()

	k.SetParams(ctx, params)

	require.EqualValues(t, params, k.GetParams(ctx))
}
