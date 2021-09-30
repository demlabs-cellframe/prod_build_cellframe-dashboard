#!/bin/bash

NODE_PATH=./cellframe-node

# compile cellframe-dashboard
./prod_build/mac/scripts/compile.sh $1 || { errcode=$?; echo "[ERR] Mac build errcode $errcode";exit $errcode; }

# compile cellframe-node
./cellframe-node/prod_build/mac/scripts/compile.sh $NODE_PATH || { errcode=$?; echo "[ERR] Mac cellframe-node compile $errcode"; exit $errcode; }
#./prod_build/mac/scripts/addqt.sh $1 || { errcode=$?; echo "[ERR] Mac addqtlibs errcode $errcode";exit $errcode; }
./prod_build/mac/scripts/reloc.sh $1 || { errcode=$?; echo "[ERR] Mac reloc errcode $errcode"; exit $errcode; }
#./prod_build/mac/scripts/sign.sh $1 || exit 6
./prod_build/mac/scripts/pack.sh $1 || { errcode=$?; echo "[ERR] Mac pack errcode $errcode"; exit $errcode; }
#./prod_build/mac/scripts/clean.sh || { errcode=$?; echo "[ERR] Mac clean errcode $errcode"; exit $errcode; }
exit 0
