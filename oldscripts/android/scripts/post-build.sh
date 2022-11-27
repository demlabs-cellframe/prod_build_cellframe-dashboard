#!/bin/bash

#echo "Stub for post-build actions"
echo "Entering post-build deployment and cleanup"
SCRIPTDIR="prod_build/android/scripts"

$SCRIPTDIR/deploy.sh || { errcode=$?; echo "[ERR] Android deploy errcode $errcode"; exit 30; }
