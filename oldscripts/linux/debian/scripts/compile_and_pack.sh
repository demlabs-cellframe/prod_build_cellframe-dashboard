#!/bin/bash
cd ~/demlabs/projects/cellframe-dashboard
set -x
[ -v QT_LINUX_PATH ] && export QT_SELECT=$(qtchooser -l | grep static)

build_node() {
	cd cellframe-node && mkdir build && cd build
	sed -i 's/target_link_libraries(${NODE_TARGET}      ${NODE_LIBRARIES} pthread )/target_link_libraries(${NODE_TARGET}      ${NODE_LIBRARIES} pthread z util expat )/' ../CMakeLists.txt
	${CMAKE_PATH}/cmake ../ && make -j$(nrpoc)
	cd ../../
	pwd
}
error_explainer() {

	case "$1" in
		"0"	) echo "";;
		"1"	) echo "Error in pre-config happened. Please, review logs";;
		"2"	) echo "Error in compilation happened. Please, review logs";;
		*	) echo "Unhandled error $1 happened. Please, review logs";;
	esac
}

cleanup () {

rm -rf cellframe-node/build
make distclean

if [ "$1" == "--static" ]; then
	export $QT_SELECT="default" #Returning back the shared library link
fi

}

error=0
#2DO: add trap command to clean the sources on exit.
trap cleanup SIGINT
codename=$(lsb_release -a | grep Codename | cut -f2)

sed -i "s/#BUILD_TYPE/BUILD_TYPE/" config.pri 
build_node
 dpkg-buildpackage -J -us --changes-option=--build=any -uc || error=$?
if [[ $(ls .. | grep 'dbgsym') != "" ]]; then
	rm -f ../*dbgsym*
fi
mkdir -p build && \
for filepkg in $(ls .. | grep .deb | grep -v $codename); do
	mv ../$filepkg build/$filepkg
done || error=$?
cleanup
error_explainer $error
set +x
exit $error #2DO: Learn how to sign up the package.
