#!/bin/bash
set -e

if [ ${0:0:1} = "/" ]; then
	HERE=`dirname $0`
else
	CMD=`pwd`/$0
	HERE=`dirname ${CMD}`
fi

export SOURCES=${HERE}/../

#validate input params
. ${HERE}/validate.sh

Help()
{
   echo "cellframe-dashboard build"
   echo "Usage: build.sh [--target ${TARGETS}] [${BUILD_TYPES}]  [OPTIONS]"
   echo "options:   -DWHATEVER=ANYTHING will be passed to qmake as defines"
   echo
}


POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      Help
      shift # past argument
      shift # past value
      ;;
    -t|--target)
      TARGET="$2"
      shift # past argument
      shift # past value
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

BUILD_TYPE="${1:-release}"
BUILD_OPTIONS="${@:2}"

NAME_OUT="$(uname -s)"
case "${NAME_OUT}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    MSYS_NT*)   MACHINE=Git;;
    *)          MACHINE="UNKNOWN:${NAME_OUT}"
esac


DEFAULT_TARGET="linux"
if [ "$MACHINE" == "Mac" ]
then
  DEFAULT_TARGET="osx"
fi

if [ "$MACHINE" == "Linux" ]
then
  DEFAULT_TARGET="linux"
fi

if [ "$MACHINE" == "Git" ]
then
  DEFAULT_TARGET="windows"
fi


BUILD_TARGET="${TARGET:-$DEFAULT_TARGET}"

BUILD_DIR=${PWD}/build_${BUILD_TARGET}_${BUILD_TYPE}


VALIDATE_TARGET $TARGET
VALIDATE_BUILD_TYPE $BUILD_TYPE

#append qmake debug\release qmake options for this
if [ "${BUILD_TYPE}" = "debug" ]; then
    BUILD_OPTIONS[${#BUILD_OPTIONS[@]}]="CONFIG+=debug"
elif [ "${BUILD_TYPE}" = "rwd" ]; then
    BUILD_OPTIONS[${#BUILD_OPTIONS[@]}]="CONFIG+=force_debug_info"
else
    BUILD_OPTIONS[${#BUILD_OPTIONS[@]}]="CONFIG+=release"
fi

. ${HERE}/targets/${BUILD_TARGET}.sh

#all base logic from here
mkdir -p ${BUILD_DIR}/build
mkdir -p ${BUILD_DIR}/dist

echo "Build [${BUILD_TYPE}] binaries for [$BUILD_TARGET] in [${BUILD_DIR}] on $(nproc) threads"
echo "with options: [${BUILD_OPTIONS[@]}]"

cd ${BUILD_DIR}/build

#this will install all to DIST folder for futher packaging
export INSTALL_ROOT=${BUILD_DIR}/dist

#debug out
echo "$QMAKE ../../*.pro  ${BUILD_OPTIONS[@]}"

"${QMAKE[@]}" ../../*.pro  ${BUILD_OPTIONS[@]}
"${MAKE[@]}" -j$(nproc)
"${MAKE[@]}" install
