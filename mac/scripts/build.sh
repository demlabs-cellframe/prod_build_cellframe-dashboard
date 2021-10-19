#!/bin/bash

arch=$1
NODE_PATH=./cellframe-node

export QT_MAC_PATH=${OSXCROSS_PATH}/$arch/${QT_PATH}
export CROSS_COMPILE=${arch}${OSX_COMPILE}

sed -i "s/arm64/arm64e/g" cellframe-node/cellframe-sdk/3rdparty/monero_crypto/CMakeLists.txt

# compile cellframe-dashboard
./prod_build/mac/scripts/compile.sh $arch || { errcode=$?; echo "[ERR] Mac build errcode $errcode";exit $errcode; }
# compile cellframe-node
echo "[INF] Compile cellframe-node"
./cellframe-node/prod_build/mac/scripts/compile.sh $NODE_PATH || { errcode=$?; echo "[ERR] Mac cellframe-node compile $errcode"; exit $errcode; }
#./prod_build/mac/scripts/addqt.sh $1 || { errcode=$?; echo "[ERR] Mac addqtlibs errcode $errcode";exit $errcode; }
./prod_build/mac/scripts/reloc.sh || { errcode=$?; echo "[ERR] Mac reloc errcode $errcode"; exit $errcode; }
#./prod_build/mac/scripts/sign.sh $1 || exit 6
./prod_build/mac/scripts/pack.sh $arch || { errcode=$?; echo "[ERR] Mac pack errcode $errcode"; exit $errcode; }
make distclean
rm .qmake.stash

exit 0
