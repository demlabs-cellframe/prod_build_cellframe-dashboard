#!/bin/bash

rm -rf cellframe-node/build
rm -f  cellframe-node/sources/main*.c
mv cellframe-node/sources/main.cbak cellframe-node/sources/main.c
mv cellframe-node/sources/main_node_cli.cbak cellframe-node/sources/main_node_cli.c
mv cellframe-node/sources/main_node_tool.cbak cellframe-node/sources/main_node_tool.c

make distclean
