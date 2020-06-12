#!/bin/bash
WASMD_DATA="$(pwd)/data"

chainid0=wasmd0
chainid1=wasmd1

killall wasmd

wasmcli keys delete alice
wasmcli keys delete bob
wasmcli keys delete validator0
wasmcli keys delete validator1

rm -rf ~/.wasmd ~/.wasmcli
rm -rf $WASMD_DATA

wasmd unsafe-reset-all --home $WASMD_DATA/$chainid0/n0/wasmd
wasmd unsafe-reset-all --home $WASMD_DATA/$chainid1/n0/wasmd