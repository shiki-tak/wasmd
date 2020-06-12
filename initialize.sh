#!/bin/bash

# two wasmd chain initialize shell

WASMD_DATA="$(pwd)/data"

chainid0=wasmd0
chainid1=wasmd1

echo "Generating wasmd configurations..."
mkdir -p $WASMD_DATA && cd $WASMD_DATA

wasmd init -o $chainid0 --chain-id=$chainid0 --home $WASMD_DATA/$chainid0/n0/wasmd &> /dev/null
wasmd init -o $chainid1 --chain-id=$chainid1 --home $WASMD_DATA/$chainid1/n0/wasmd &> /dev/null

echo "Add validator keys"
wasmcli keys add validator0 --chain-id $chainid0 --home $WASMD_DATA/$chainid0/n0/wasmd
wasmcli keys add validator1 --chain-id $chainid1 --home $WASMD_DATA/$chainid1/n0/wasmd

echo "Add genesis account"
wasmd add-genesis-account $(wasmcli keys show validator0 -a --chain-id=$chainid0 --home $WASMD_DATA/$chainid0/n0/wasmd) 1000000000stake,1000000000validatortoken --home $WASMD_DATA/$chainid0/n0/wasmd
wasmd add-genesis-account $(wasmcli keys show validator1 -a --chain-id=$chainid1 --home $WASMD_DATA/$chainid1/n0/wasmd) 1000000000stake,1000000000validatortoken --home $WASMD_DATA/$chainid1/n0/wasmd

echo "Gentx"
wasmd gentx --name validator0 --home $WASMD_DATA/$chainid0/n0/wasmd
wasmd gentx --name validator1 --home $WASMD_DATA/$chainid1/n0/wasmd

echo "Collect gentxs"
wasmd collect-gentxs --home $WASMD_DATA/$chainid0/n0/wasmd
wasmd collect-gentxs --home $WASMD_DATA/$chainid1/n0/wasmd

cfgpth="n0/wasmd/config/config.toml"
if [ "$(uname)" = "Linux" ]; then
  # TODO: Just index *some* specified tags, not all
    sed -i 's/index_all_keys = false/index_all_keys = true/g' $chainid0/$cfgpth
    sed -i 's/index_all_keys = false/index_all_keys = true/g' $chainid1/$cfgpth

    # Set proper defaults and change ports
    sed -i 's/"leveldb"/"goleveldb"/g' $chainid0/$cfgpth
    sed -i 's/"leveldb"/"goleveldb"/g' $chainid1/$cfgpth
    sed -i 's#"tcp://0.0.0.0:26656"#"tcp://0.0.0.0:26556"#g' $chainid1/$cfgpth
    sed -i 's#"tcp://0.0.0.0:26650"#"tcp://0.0.0.0:26551"#g' $chainid1/$cfgpth
    sed -i 's#"localhost:6060"#"localhost:6061"#g' $chainid1/$cfgpth
    sed -i 's#"tcp://127.0.0.1:26658"#"tcp://127.0.0.1:26558"#g' $chainid1/$cfgpth

    # Make blocks run faster than normal
    sed -i 's/timeout_commit = "5s"/timeout_commit = "1s"/g' $chainid0/$cfgpth
    sed -i 's/timeout_commit = "5s"/timeout_commit = "1s"/g' $chainid1/$cfgpth
    sed -i 's/timeout_propose = "3s"/timeout_propose = "1s"/g' $chainid0/$cfgpth
    sed -i 's/timeout_propose = "3s"/timeout_propose = "1s"/g' $chainid1/$cfgpth
else
    # TODO: Just index *some* specified tags, not all
    sed -i '' 's/index_all_keys = false/index_all_keys = true/g' $chainid0/$cfgpth
    sed -i '' 's/index_all_keys = false/index_all_keys = true/g' $chainid1/$cfgpth

    # Set proper defaults and change ports
    sed -i '' 's/"leveldb"/"goleveldb"/g' $chainid0/$cfgpth
    sed -i '' 's/"leveldb"/"goleveldb"/g' $chainid1/$cfgpth
    sed -i '' 's#"tcp://0.0.0.0:26656"#"tcp://0.0.0.0:26556"#g' $chainid1/$cfgpth
    sed -i '' 's#"localhost:6060"#"localhost:6061"#g' $chainid1/$cfgpth
    sed -i '' 's#"tcp://127.0.0.1:26658"#"tcp://127.0.0.1:26558"#g' $chainid1/$cfgpth

    # Make blocks run faster than normal
    sed -i '' 's/timeout_commit = "5s"/timeout_commit = "1s"/g' $chainid0/$cfgpth
    sed -i '' 's/timeout_commit = "5s"/timeout_commit = "1s"/g' $chainid1/$cfgpth
    sed -i '' 's/timeout_propose = "3s"/timeout_propose = "1s"/g' $chainid0/$cfgpth
    sed -i '' 's/timeout_propose = "3s"/timeout_propose = "1s"/g' $chainid1/$cfgpth
fi

gclpth="n0/wasmcli/"
wasmcli config --home $chainid0/$gclpth chain-id $chainid0 &> /dev/null
wasmcli config --home $chainid1/$gclpth chain-id $chainid1 &> /dev/null
wasmcli config --home $chainid0/$gclpth output json &> /dev/null
wasmcli config --home $chainid1/$gclpth output json &> /dev/null
wasmcli config --home $chainid0/$gclpth node http://localhost:26650 &> /dev/null
wasmcli config --home $chainid1/$gclpth node http://localhost:26651 &> /dev/null


echo "Start wasmd node"
wasmd start --home $WASMD_DATA/$chainid0/n0/wasmd --rpc.laddr=tcp://0.0.0.0:26650 --pruning=nothing > $WASMD_DATA/$chainid0/$chainid0.log 2>&1 &
wasmd start --home $WASMD_DATA/$chainid1/n0/wasmd --rpc.laddr=tcp://0.0.0.0:26651 --pruning=nothing > $WASMD_DATA/$chainid1/$chainid1.log 2>&1 &

echo "Setup for chainid0 wasmcli..."
wasmcli config chain-id $chainid0 --home $WASMD_DATA/$chainid0/n0/wasmcli
wasmcli config trust-node true --home $WASMD_DATA/$chainid0/n0/wasmcli
wasmcli config node https://rpc.demo-08.cosmwasm.com:443 --home $WASMD_DATA/$chainid0/n0/wasmcli
wasmcli config output json --home $WASMD_DATA/$chainid0/n0/wasmcli
wasmcli config indent true  --home $WASMD_DATA/$chainid0/n0/wasmcli
# this is important, so the cli returns after the tx is in a block,
# and subsequent queries return the proper results
wasmcli config broadcast-mode block --home $WASMD_DATA/$chainid0/n0/wasmcli

# check you can connect
wasmcli query supply total --home $WASMD_DATA/$chainid0/n0/wasmcli
wasmcli query staking validators --home $WASMD_DATA/$chainid0/n0/wasmcli
wasmcli query wasm list-code --node tcp://localhost:26650

# create some local accounts
wasmcli keys add alice --home $WASMD_DATA/$chainid0/n0/wasmcli
# wasmcli keys add bob --home $WASMD_DATA/$chainid0/n0/wasmcli
wasmcli keys list --home $WASMD_DATA/$chainid0/n0/wasmcli

echo "Setup for chainid1 wasmcli..."
wasmcli config chain-id $chainid1 --home $WASMD_DATA/$chainid1/n0/wasmcli
wasmcli config trust-node true --home $WASMD_DATA/$chainid1/n0/wasmcli
wasmcli config node https://rpc.demo-08.cosmwasm.com:443 --home $WASMD_DATA/$chainid1/n0/wasmcli
wasmcli config output json --home $WASMD_DATA/$chainid1/n0/wasmcli
wasmcli config indent true  --home $WASMD_DATA/$chainid1/n0/wasmcli
# this is important, so the cli returns after the tx is in a block,
# and subsequent queries return the proper results
wasmcli config broadcast-mode block --home $WASMD_DATA/$chainid1/n0/wasmcli

# check you can connect
wasmcli query supply total --home $WASMD_DATA/$chainid1/n0/wasmcli
wasmcli query staking validators --home $WASMD_DATA/$chainid1/n0/wasmcli
wasmcli query wasm list-code --node tcp://localhost:26651

# create some local accounts
wasmcli keys add bob --home $WASMD_DATA/$chainid1/n0/wasmcli
wasmcli keys list --home $WASMD_DATA/$chainid1/n0/wasmcli



# deploy contract
# wasmcli tx send $(wasmcli keys show validator0 -a --chain-id $chainid0 --home $WASMD_DATA/$chainid0/n0/wasmcli) $(wasmcli keys show alice -a --chain-id $chainid0 --home $WASMD_DATA/$chainid0/n0/wasmcli) 100stake -y --chain-id $chainid0 --node tcp://localhost:26650
# wasmcli query account $(wasmcli keys show alice -a --chain-id $chainid0 --home $WASMD_DATA/$chainid0/n0/wasmcli) --node tcp://localhost:26650 --chain-id $chainid0 --home $WASMD_DATA/$chainid0/n0/wasmcli

# wasmcli tx wasm store contract.wasm --from alice --gas 42000000 -y --chain-id $chainid0 --home $WASMD_DATA/$chainid0/n0/wasmcli --node tcp://localhost:26650
# INIT='{"name":"erc20", "symbol":"WSM", "decimals":18, "initial_balances":[{"address": "cosmos1xaccafflz7mwrdqcl5k3fk940hqx35hd8klr5x", "amount": "100000000"}]}'
# wasmcli tx wasm instantiate 1 "$INIT" --from alice --amount=50stake --label "wasm-erc20" -y  --node tcp://localhost:26650 --chain-id $chainid0 --home $WASMD_DATA/$chainid0/n0/wasmcli
# wasmcli query wasm list-contract-by-code 1  --node tcp://localhost:26650

# wasmcli query wasm contract $CONTRACT --node tcp://localhost:26650
# wasmcli query account $CONTRACT --node tcp://localhost:26650
# wasmcli query wasm contract-state smart $CONTRACT $BALANCE --node tcp://localhost:26650
