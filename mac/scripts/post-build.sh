#!/bin/bash

echo "VERSION_INFO"
export -n VERSION_INFO

platform=$1
SCRIPTDIR=prod_build/$platform/scripts/
errcode=0
$SCRIPTDIR/deploy.sh || { errcode=$?; echo "[ERR] MacOS deployment errcode $errcode"; }
[ -e "prod_build/$platform/conf/PATHS.bak" ] && mv -v prod_build/$platform/conf/PATHS.bak prod_build/$platform/conf/PATHS
exit $errcode
