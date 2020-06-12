package types

import (
	sdk "github.com/cosmos/cosmos-sdk/types"
)

type MsgInit struct {
	Sender sdk.AccAddress `json:"sender" yaml:"sender"`
}

func (msg MsgInit) Route() string {
	return RouterKey
}

func (msg MsgInit) Type() string {
	return "init"
}

func (msg MsgInit) ValidateBasic() error {
	return nil
}

func (msg MsgInit) GetSignBytes() []byte {
	return sdk.MustSortJSON(ModuleCdc.MustMarshalJSON(msg))
}

func (msg MsgInit) GetSigners() []sdk.AccAddress {
	return []sdk.AccAddress{msg.Sender}
}

// TODO: Describe your actions, these will implment the interface of `sdk.Msg`
/*
// verify interface at compile time
var _ sdk.Msg = &Msg<Action>{}

// Msg<Action> - struct for unjailing jailed validator
type Msg<Action> struct {
	ValidatorAddr sdk.ValAddress `json:"address" yaml:"address"` // address of the validator operator
}

// NewMsg<Action> creates a new Msg<Action> instance
func NewMsg<Action>(validatorAddr sdk.ValAddress) Msg<Action> {
	return Msg<Action>{
		ValidatorAddr: validatorAddr,
	}
}

const <action>Const = "<action>"

// nolint
func (msg Msg<Action>) Route() string { return RouterKey }
func (msg Msg<Action>) Type() string  { return <action>Const }
func (msg Msg<Action>) GetSigners() []sdk.AccAddress {
	return []sdk.AccAddress{sdk.AccAddress(msg.ValidatorAddr)}
}

// GetSignBytes gets the bytes for the message signer to sign on
func (msg Msg<Action>) GetSignBytes() []byte {
	bz := ModuleCdc.MustMarshalJSON(msg)
	return sdk.MustSortJSON(bz)
}

// ValidateBasic validity check for the AnteHandler
func (msg Msg<Action>) ValidateBasic() error {
	if msg.ValidatorAddr.Empty() {
		return sdkerrors.Wrap(sdkerrors.ErrInvalidAddress, "missing validator address")
	}
	return nil
}
*/
