package alphachain_test

import (
	"testing"

	keepertest "alpha-chain/testutil/keeper"
	"alpha-chain/testutil/nullify"
	"alpha-chain/x/alphachain"
	"alpha-chain/x/alphachain/types"
	"github.com/stretchr/testify/require"
)

func TestGenesis(t *testing.T) {
	genesisState := types.GenesisState{
		Params: types.DefaultParams(),

		// this line is used by starport scaffolding # genesis/test/state
	}

	k, ctx := keepertest.AlphachainKeeper(t)
	alphachain.InitGenesis(ctx, *k, genesisState)
	got := alphachain.ExportGenesis(ctx, *k)
	require.NotNil(t, got)

	nullify.Fill(&genesisState)
	nullify.Fill(got)

	// this line is used by starport scaffolding # genesis/test/assert
}
