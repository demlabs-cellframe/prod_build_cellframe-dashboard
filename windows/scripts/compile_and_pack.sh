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


if [ "$1" == "--static" ]; then
	export $QT_SELECT="default" #Returning back the shared library link
fi

}

# defines() {

# [ -e ./build/Nsis.defines.nsh ] && rm ./build/Nsis.defines.nsh
# echo "!define APP_NAME \"$1\"" >> ./build/Nsis.defines.nsh
# echo "!define APP_VERSION \"$(echo $2 | sed 's/-/\./g').0\"" >> ./build/Nsis.defines.nsh
# echo "!define DAP_VER \"$2\"" >> ./build/Nsis.defines.nsh

# }

# pack() {

# 	mkdir -p ./build/
# 	rm -r ./build/*
# 	cp ./brand/$1/DapChainVpnGui/resources/pics/icon_app.ico ./build/
# 	cp -r ./os/windows/drivers ./build/
# 	cp ./os/windows/build.nsi ./build/
# 	cp ./os/windows/ssl/libeay32.dll ./build/
# 	cp ./os/windows/ssl/ssleay32.dll ./build/	
# 	VERSION=$(extract_version_number)
# 	defines $1 $VERSION
# 	cp ./DapChainVpnService/release/KelVPNService.exe ./build/
# 	cp ./DapChainVpnGui/release/KelVPN.exe ./build/
# 	makensis ./build/build.nsi
# 	mv ./build/"$BRAND ${VERSION}.exe" ./build/"${BRAND}-${VERSION}.exe"
# }

error=0
#codename=$(lsb_release -a | grep Codename | cut -f2)
#2DO: add trap command to clean the sources on exit.

cd cellframe-node && git submodule update --init && cd -
sed -i 's/#nsis_build/nsis_build/g' CellFRameDashboardGUI/CellFRameDashboardGUI.pro
sed -i 's/#nsis_build/nsis_build/g' CellFrameDashboardService/CellFrameDashboardService.pro
sed -i 's/#compile.bash/compile.sh/g' CellFRameDashboardGUI/CellFRameDashboardGUI.pro
sed -i 's/#makensis.exe/makensis/g' CellFRameDashboardGUI/CellFRameDashboardGUI.pro

trap cleanup SIGINT
	#[ -v BRAND ] && echo "Brand = $BRAND" || { echo "No brand defined"; BRAND="CellFrameDashboard"; } && \
	$WINDOWS_CROSS_QT/qmake && make -j$(nproc)
	# pack $BRAND
#	for filepkg in $(ls .. | grep .deb | grep -v $codename | grep -v "dbgsym"); do
#		filename=$(echo $filepkg | sed 's/.deb$//')
#		[ ! -v QT_LINUX_PATH ] && mv ../$filepkg build/$filename\_$codename.deb || mv ../$filepkg build/$filepkg
#		cd build && repack $filename\_$codename.deb $codename && cd ..
#	done || error=$?
	cleanup
error_explainer $error
exit $error #2DO: Learn how to sign up the package.
