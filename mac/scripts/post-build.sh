#!/bin/bash

#echo "Stub for post-build actions"
echo "Entering post-build deployment and cleanup"
platform=$1
SCRIPTDIR="prod_build/$platform/scripts"

$SCRIPTDIR/deploy.sh || { echo "[ERR] $platform deploy error" && exit 20; }
$SCRIPTDIR/cleanup.sh || { echo "[ERR] $platform cleanup error" && exit 21; }
