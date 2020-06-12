package cli

import (
	"fmt"

	"github.com/spf13/cobra"

	"github.com/CosmWasm/wasmd/x/relayer/types"
	"github.com/cosmos/cosmos-sdk/client"
	"github.com/cosmos/cosmos-sdk/client/flags"
	"github.com/cosmos/cosmos-sdk/codec"
)

// GetTxCmd returns the transaction commands for this module
func GetTxCmd(cdc *codec.Codec) *cobra.Command {
	relayerTxCmd := &cobra.Command{
		Use:                        types.ModuleName,
		Short:                      fmt.Sprintf("%s transactions subcommands", types.ModuleName),
		DisableFlagParsing:         true,
		SuggestionsMinimumDistance: 2,
		RunE:                       client.ValidateCmd,
	}

	relayerTxCmd.AddCommand(flags.PostCommands(
		Init(cdc),
		Start(cdc),
	)...)

	return relayerTxCmd
}

func Init(cdc *codec.Codec) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "init [chain-id]",
		Short: "Initiate relayer",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			return nil
		},
	}
	return cmd
}

func Start(cdc *codec.Codec) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "start [path-name]",
		Short: "Start relayer(create clients, connection, and channel between two configured chains with a configured path)",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			return nil
		},
	}
	return cmd
}
