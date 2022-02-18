#!/bin/bash

echo "Entering build "
SCRIPTDIR="prod_build/android/scripts"

$SCRIPTDIR/compile_and_pack.sh $@ || { errcode=$?; echo "[ERR] Android build errcode $errcode"; exit 20; } 