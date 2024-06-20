#!/bin/bash
set -e

SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  TARGET=$(readlink "$SOURCE")
  if [[ $TARGET == /* ]]; then
    echo "SOURCE '$SOURCE' is an absolute symlink to '$TARGET'"
    SOURCE=$TARGET
  else
    DIR=$( dirname "$SOURCE" )
    echo "SOURCE '$SOURCE' is a relative symlink to '$TARGET' (relative to '$DIR')"
    SOURCE=$DIR/$TARGET # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  fi
done
echo "SOURCE is '$SOURCE'"
RDIR=$( dirname "$SOURCE" )
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
HERE="$DIR"

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

BUILD_TARGET="${TARGET:-linux}"

BUILD_DIR=${HERE}/../build_${BUILD_TARGET}_${BUILD_TYPE}


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
echo "$QMAKE $HERE/../*.pro  ${BUILD_OPTIONS[@]}"

"${QMAKE[@]}" $HERE/../*.pro  ${BUILD_OPTIONS[@]}
"${MAKE[@]}" -j$(nproc)
"${MAKE[@]}" install
