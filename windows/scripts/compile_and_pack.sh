#!/bin/bash
WINDOWS_TOOLCHAIN=$WINDOWS_TOOLCHAIN_PATH/usr/bin
WINDOWS_CROSS_QT=$WINDOWS_TOOLCHAIN_PATH/usr/x86_64-w64-mingw32.static/qt5/bin
export PATH=$WINDOWS_TOOLCHAIN:$PATH

. prod_build/general/conf/version_info
. prod_build/general/pre-build.sh
. prod_build/general/conf/publish

error_explainer() {

	case "$1" in
		"0"	) echo "";;
		"1"	) echo "Error in pre-config happened. Please, review logs";;
		"2"	) echo "Error in compilation happened. Please, review logs";;
		*	) echo "Unhandled error $1 happened. Please, review logs";;
	esac
}

cleanup() {

make distclean
rm -r build_win32

if [ "$1" == "--static" ]; then
	export $QT_SELECT="default" #Returning back the shared library link
fi

}

error=0

#2DO: add trap command to clean the sources on exit.
mkdir -p build_win32/dist/share/

sed -i 's/#nsis_build/nsis_build/g' CellFrameDashboardGUI/CellFrameDashboardGUI.pro
sed -i 's/#nsis_build/nsis_build/g' CellFrameDashboardService/CellFrameDashboardService.pro
sed -i 's/compile.bat/compile.sh/g' CellFrameDashboardGUI/CellFrameDashboardGUI.pro
sed -i 's/makensis.exe/makensis/g' CellFrameDashboardGUI/CellFrameDashboardGUI.pro

trap cleanup SIGINT
	$WINDOWS_CROSS_QT/qmake && make -j$(nproc)  && mkdir build && 
	[ -v BRAND ] && echo "Brand = $BRAND" || { echo "No brand defined"; BRAND="Cellframe-Dashboard"; } && \
	VERSION=$(extract_version_number) && echo "Version = $VERSION" && \
	mv ./build_win32/"$BRAND ${VERSION}.exe" ./build/"${BRAND}-${VERSION}.exe" || error=$?
	cleanup
error_explainer $error
exit $error #2DO: Learn how to sign up the package.
