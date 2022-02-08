#!/bin/bash

echo "Deploying to $PACKAGE_PATH"
mkdir -p $PACKAGE_PATH
pwd
[ -d build/apk ] && cd build/apk || echo "[ERR] build/apk folder is not created!"
PKGFILES=$(ls . | grep .apk)

MOD=$(echo $MOD | sed 's/-\?static-\?//') && [ ! $MOD = "" ] && MODNAME="-$MOD"
[[ -v CI_COMMIT_REF_NAME ]] && [[ $CI_COMMIT_REF_NAME != "master" ]] && SUBDIR="${CI_COMMIT_REF_NAME}/" || SUBDIR=""
echo $PKGFILES

errcode=0
for pkgfile in $PKGFILES; do
pkgname=$(echo $pkgfile | sed "s/.apk$//")
	echo $VERSION_STRING
	echo "Pkgfile is $pkgfile"
	pkgname_weblink="$(echo $pkgname | sed 's/-\?[0-9]\+\.[0-9]\+-[0-9]\+//' )-latest" #leaving only necessary entries
	mv -v $pkgfile $PACKAGE_PATH/$pkgname$MODNAME.apk || echo "[ERR] Something went wrong in publishing the package. Now aborting."
	# if [[ -v CI_COMMIT_REF_NAME ]] && { [[ $CI_MERGE_REQUEST_TARGET_BRANCH_NAME == "master" ]] || [[ $(echo $CI_COMMIT_REF_NAME | grep "master\|^release\|^pubtest\|^hotfix") ]]; }; then #TMP restriction for master only.
	CODENAME=$(echo $pkgname | rev | cut -d '_' -f1 | rev)
	cp -r ../../prod_build/general/essentials/weblink-latest ../../prod_build/general/essentials/$pkgname_weblink
	sed -i "/document/s/\/.*deb/\/$pkgname$MODNAME.apk/" ../../prod_build/general/essentials/$pkgname_weblink/index.php
	echo "attempting to publish new Cellframe-Dashboard"
	[[ $SUBDIR != "" ]] && ssh -i $CELLFRAMRE_FILESERVER_KEY "$CELLFRAMRE_FILESERVER_CREDS" "mkdir -p $CELLFRAMRE_FILESERVER_PATH/android/$SUBDIR"
	scp -i $CELLFRAMRE_FILESERVER_KEY $PACKAGE_PATH/$pkgname$MODNAME.apk "$CELLFRAMRE_FILESERVER_CREDS:$CELLFRAMRE_FILESERVER_PATH/android/$SUBDIR"
	scp -r -i $CELLFRAMRE_FILESERVER_KEY ../../prod_build/general/essentials/$pkgname_weblink "$CELLFRAMRE_FILESERVER_CREDS:$CELLFRAMRE_FILESERVER_PATH/android/$SUBDIR"
	rm -r ../../prod_build/general/essentials/$pkgname_weblink
	# fi
done
cd ../..
exit $errcode