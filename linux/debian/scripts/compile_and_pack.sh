#!/bin/bash

set -x
[ -v QT_LINUX_PATH ] && export QT_SELECT=$(qtchooser -l | grep static)


error_explainer() {

	case "$1" in
		"0"	) echo "";;
		"1"	) echo "Error in pre-config happened. Please, review logs";;
		"2"	) echo "Error in compilation happened. Please, review logs";;
		*	) echo "Unhandled error $1 happened. Please, review logs";;
	esac
}

cleanup () {

make distclean

if [ "$1" == "--static" ]; then
	export $QT_SELECT="default" #Returning back the shared library link
fi

}

error=0
#2DO: add trap command to clean the sources on exit.
trap cleanup SIGINT
codename=$(lsb_release -a | grep Codename | cut -f2)

# fixed changelog
versionMaj=$(cat config.pri | grep 'VER_MAJ =' | cut -d'=' -f 2 | sed s/' '//g)
versionMin=$(cat config.pri | grep 'VER_MIN =' | cut -d'=' -f 2 | sed s/' '//g)
versionPatch=$(cat config.pri | grep 'VER_PAT =' | cut -d'=' -f 2 | sed s/' '//g)
sed  -i "0,/$versionMaj.$versionMin-[0-9]\+/{s//$versionMaj.$versionMin-$versionPatch/}" debian/changelog
sed  -i "s/$versionMaj.$versionMin-[0-9]\+/$versionMaj.$versionMin-$versionPatch/" debian/control
#cat debian/changelog

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
