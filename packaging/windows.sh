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
    DIST_DIR=$1
    BUILD_DIR=$2
    OUT_DIR=$3
    ARCH=$(dpkg --print-architecture)
    source "${HERE}/../version.mk"
    PACKAGE_NAME="cellframe-dashboard_${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}_amd64.exe"

    makensis ${DIST_DIR}/build.nsi
    mv ${DIST_DIR}/*installer.exe ${OUT_DIR}/${PACKAGE_NAME}
}
