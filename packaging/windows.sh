#!/bin/bash -e

set -e

if [ ${0:0:1} = "/" ]; then
	HERE=`dirname $0`
else
	CMD=`pwd`/$0
	HERE=`dirname ${CMD}`
fi


PACK() 
{
    BRAND=$1
    DIST_DIR=$2
    BUILD_DIR=$3
    OUT_DIR=$4
    ARCH=$(dpkg --print-architecture)

    makensis ${DIST_DIR}/build.nsi
    mv ${DIST_DIR}/*installer.exe ${OUT_DIR}
}