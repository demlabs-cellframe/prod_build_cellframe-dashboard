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

# repack() {

# DEBNAME=$1
# DISTR_CODENAME=$2
# echo "Renaming controlde on $DEBNAME"
# mkdir tmp && cd tmp

# #Просматриваем архив и ищем строку с control.tar
# #Результат заносим в переменную
# CONTROL=$(ar t ../${DEBNAME} | grep control.tar)

# ar x ../$DEBNAME $CONTROL
# tar xf $CONTROL
# VERSION=$(cat control | grep Version | cut -d ':' -f2)
# echo "Version is $VERSION"
# sed -i "s/$VERSION/${VERSION}-${DISTR_CODENAME}/" control
# rm $CONTROL && tar czf $CONTROL *
# ar r ../$DEBNAME $CONTROL
# cd ..
# rm -rf tmp
# }

add_postfix() {

cat debian/control
sed "s/$VERSION/${VERSION}-${DISTR_CODENAME}/" debian/control
cat debian/control
cat debian/changelog
sed "s/$VERSION/${VERSION}-${DISTR_CODENAME}/" debian/changelog
cat debian/changelog
}


cleanup () {

cp /tmp/control_tmp/cellframe-dashboard/control debian/control
cp /tmp/control_tmp/cellframe-dashboard/changelog debian/changelog
rm -r /tmp/control_tmp
make distclean

if [ "$1" == "--static" ]; then
	export $QT_SELECT="default" #Returning back the shared library link
fi

}

. prod_build/general/conf/publish
error=0
codename=$(lsb_release -a | grep Codename | cut -f2)

#2DO: add trap command to clean the sources on exit.
trap cleanup SIGINT
	mkdir -p /tmp/control_tmp/cellframe-dashboard/
	cp debian/control /tmp/control_tmp/cellframe-dashboard/
	cp debian/changelog /tmp/control_tmp/cellframe-dashboard/
	[ -v QT_LINUX_PATH ] && add_postfix

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
