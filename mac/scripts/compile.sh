#!/bin/bash
#if [ -z "$1" ]; then
#    echo "[ERR] Script needs argument - package name. Use one of next :"
#    for i in `ls configs/build_dmg.pkg/| sed 's/\.cfg//'`; do
#	echo "      $i"
#    done
#    exit 1
#fi


./prod_build/mac/scripts/compile.sh $1 || { errcode=$?; echo "[ERR] Mac build errcode $errcode";exit $errcode; }
./prod_build/mac/scripts/addqt.sh $1 || { errcode=$?; echo "[ERR] Mac addqtlibs errcode $errcode";exit $errcode; }
./prod_build/mac/scripts/reloc.sh $1 || { errcode=$?; echo "[ERR] Mac reloc errcode $errcode"; exit $errcode; }
#./prod_build/mac/scripts/sign.sh $1 || exit 6
./prod_build/mac/scripts/pack.sh $1 || { errcode=$?; echo "[ERR] Mac pack errcode $errcode"; exit $errcode; }
#exit 0
