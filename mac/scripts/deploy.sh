#!/bin/bash

echo "Deploying to $PACKAGE_PATH"

CELLFRAME_REPO_KEY="~/.ssh/demlabs_publish"
CELLFRAME_FILESERVER_CREDS="admin@pub.cellframe.net"
CELLFRAME_FILESERVER_PATH="~/web/pub.cellframe.net/public_html/macos"
pwd

cd build
PKGFILES=$(ls . | grep .pkg)

[[ -v CI_COMMIT_REF_NAME ]] && [[ $CI_COMMIT_REF_NAME != "master" ]] && SUBDIR="${CI_COMMIT_REF_NAME}" || SUBDIR=""


for pkgfile in $PKGFILES; do
	echo "working with $pkgfile"
	pkgname=$(echo $pkgfile | sed 's/.pkg$//')
	pkgname_public=$(echo $pkgname | cut -d '-' -f1-4,7-) #cutting away Debian-9.12
	pkgname_weblink="$(echo $pkgname | cut -d '-' -f1-2 )-latest" #leaving only necessary entries
	echo "copy $pkgfile in $PACKAGE_PATH"
	mv $pkgfile $PACKAGE_PATH/$pkgname$MOD.pkg || { echo "[ERR] Something went wrong in publishing the package. Now aborting."; exit -4; }
	CODENAME=$(echo $pkgname | rev | cut -d '-' -f1 | rev)
	cp -r ../prod_build/general/essentials/weblink-latest ../prod_build/general/essentials/$pkgname_weblink
	sed -i "/document/s/cellframe.*deb/$pkgname_public$MOD.pkg/" ../prod_build/general/essentials/$pkgname_weblink/index.php
	echo "REF_NAME is $CI_COMMIT_REF_NAME"
	ssh -i $CELLFRAME_REPO_KEY "$CELLFRAME_FILESERVER_CREDS" "mkdir -p $CELLFRAME_FILESERVER_PATH/$SUBDIR"
	scp -i $CELLFRAME_REPO_KEY $PACKAGE_PATH/$pkgname$MOD.pkg "$CELLFRAME_FILESERVER_CREDS:$CELLFRAME_FILESERVER_PATH/$SUBDIR/$pkgname_public$MOD.pkg"
	scp -r -i $CELLFRAME_REPO_KEY ../prod_build/general/essentials/$pkgname_weblink "$CELLFRAME_FILESERVER_CREDS:$CELLFRAME_FILESERVER_PATH/$SUBDIR/"
	rm -r ../prod_build/general/essentials/$pkgname_weblink
done

#	export -n "UPDVER"
cd ..
exit 0

