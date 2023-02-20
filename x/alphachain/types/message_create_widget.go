package types

import (
	sdk "github.com/cosmos/cosmos-sdk/types"
	sdkerrors "github.com/cosmos/cosmos-sdk/types/errors"
)

const TypeMsgCreateWidget = "create_widget"

var _ sdk.Msg = &MsgCreateWidget{}

func NewMsgCreateWidget(creator string, msg string) *MsgCreateWidget {
	return &MsgCreateWidget{
		Creator: creator,
		Msg:     msg,
	}
}

func (msg *MsgCreateWidget) Route() string {
	return RouterKey
}

func (msg *MsgCreateWidget) Type() string {
	return TypeMsgCreateWidget
}

func (msg *MsgCreateWidget) GetSigners() []sdk.AccAddress {
	creator, err := sdk.AccAddressFromBech32(msg.Creator)
	if err != nil {
		panic(err)
	}
	return []sdk.AccAddress{creator}
}

func (msg *MsgCreateWidget) GetSignBytes() []byte {
	bz := ModuleCdc.MustMarshalJSON(msg)
	return sdk.MustSortJSON(bz)
}

func (msg *MsgCreateWidget) ValidateBasic() error {
	_, err := sdk.AccAddressFromBech32(msg.Creator)
	if err != nil {
		return sdkerrors.Wrapf(sdkerrors.ErrInvalidAddress, "invalid creator address (%s)", err)
	}
	return nil
}
