package relayer

import (
	"fmt"

	sdk "github.com/cosmos/cosmos-sdk/types"
	sdkerrors "github.com/cosmos/cosmos-sdk/types/errors"
)

// NewHandler creates an sdk.Handler for all the relayer type messages
func NewHandler(k Keeper) sdk.Handler {
	return func(ctx sdk.Context, msg sdk.Msg) (*sdk.Result, error) {
		ctx = ctx.WithEventManager(sdk.NewEventManager())
		switch msg := msg.(type) {
		// TODO: Define your msg cases
		//
		//Example:
		case MsgInit:
			return handleInit(ctx, k, msg)
		default:
			errMsg := fmt.Sprintf("unrecognized %s message type: %T", ModuleName, msg)
			return nil, sdkerrors.Wrap(sdkerrors.ErrUnknownRequest, errMsg)
		}
	}
}

// handle<Action> does x
func handleInit(ctx sdk.Context, k Keeper, msg MsgInit) (*sdk.Result, error) {
	// err := k.<Action>(ctx, msg.ValidatorAddr)
	// if err != nil {
	// 	return nil, err
	// }

	// // TODO: Define your msg events
	// ctx.EventManager().EmitEvent(
	// 	sdk.NewEvent(
	// 		sdk.EventTypeMessage,
	// 		sdk.NewAttribute(sdk.AttributeKeyModule, AttributeValueCategory),
	// 		sdk.NewAttribute(sdk.AttributeKeySender, msg.ValidatorAddr.String()),
	// 	),
	// )

	return &sdk.Result{Events: ctx.EventManager().Events()}, nil
}
