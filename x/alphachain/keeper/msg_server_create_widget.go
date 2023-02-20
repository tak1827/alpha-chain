package keeper

import (
	"context"

	"alpha-chain/x/alphachain/types"
	sdk "github.com/cosmos/cosmos-sdk/types"
)

func (k msgServer) CreateWidget(goCtx context.Context, msg *types.MsgCreateWidget) (*types.MsgCreateWidgetResponse, error) {
	ctx := sdk.UnwrapSDKContext(goCtx)

	// TODO: Handling the message
	_ = ctx

	return &types.MsgCreateWidgetResponse{}, nil
}
