#!/bin/bash -e
#OSX BUILD 
#HAVE TO PROVIDE OSXCROSS_QT_ROOT variable
#HAVE TO PROVIDE OSXCROSS_QT_VERSION variable

set -e

if [ ${0:0:1} = "/" ]; then
	HERE=`dirname $0`
else
	CMD=`pwd`/$0
	HERE=`dirname ${CMD}`
fi



UNAME_OUT="$(uname -s)"
case "${UNAME_OUT}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    MSYS_NT*)   MACHINE=Git;;
    *)          MACHINE="UNKNOWN:${UNAME_OUT}"
esac

if [ "$MACHINE" != "Mac" ]
then
      if [ -z "$OSXCROSS_QT_ROOT" ]
      then
            echo "Please, export OSXCROSS_QT_ROOT variable, pointing to Qt-builds locations for osxcross environment"
            exit 255
      fi


      if [ -z "$OSXCROSS_QT_VERSION" ]
      then
            echo "Please, export OSXCROSS_QT_VERSION variable, scpecifying Qt-version in OSXCROSS_QT_ROOT directory."
            exit 255
      fi

      echo "Using QT ${OSXCROSS_QT_VERSION} from ${OSXCROSS_QT_ROOT}/${OSXCROSS_QT_VERSION}"

      [ ! -d ${OSXCROSS_QT_ROOT}/${OSXCROSS_QT_VERSION} ] && { echo "No QT ${OSXCROSS_QT_VERSION} found in ${OSXCROSS_QT_ROOT}" && exit 255; }

      #define QMAKE & MAKE commands for build.sh script

      QMAKE=(${OSXCROSS_QT_ROOT}/${OSXCROSS_QT_VERSION}/bin/qmake)

      #everything else can be done by default make


      echo "OSXcross target"
else
      echo "Host is $MACHINE, use native build toolchain"

      if [ -f "/Users/$USER/Qt/5.15.14/clang_64/bin/qmake" ] 
      then
            QMAKE=(/Users/$USER/Qt/5.15.14/clang_64/bin/qmake )
            echo "Found QT qmake at $QMAKE, using it preferable"
      else
            if [ -f "/Users/$USER/Qt/5.15.2/clang_64/bin/qmake" ] 
            then
                  QMAKE=(/Users/$USER/Qt/5.15.2/clang_64/bin/qmake)
                  echo "Found QT qmake at $QMAKE, using it preferable"
            else
                  echo "Not found qmake at default qt location, asuming it is in PATH"
                  QMAKE=(qmale)
            fi
      fi
fi

MAKE=(make)

echo "QMAKE=${QMAKE[@]}"
echo "MAKE=${MAKE[@]}"