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
	mv -v $pkgfile $PACKAGE_PATH/$pkgname.apk || echo "[ERR] Something went wrong in publishing the package. Now aborting."
	# if [[ -v CI_COMMIT_REF_NAME ]] && { [[ $CI_MERGE_REQUEST_TARGET_BRANCH_NAME == "master" ]] || [[ $(echo $CI_COMMIT_REF_NAME | grep "master\|^release\|^pubtest\|^hotfix") ]]; }; then #TMP restriction for master only.
	CODENAME=$(echo $pkgname | rev | cut -d '_' -f1 | rev)
	cp -r ../../prod_build/general/essentials/weblink-latest ../../prod_build/general/essentials/$pkgname_weblink
	sed -i "/document/s/\/.*deb/\/$pkgname.apk/" ../../prod_build/general/essentials/$pkgname_weblink/index.html
	echo "attempting to publish new Cellframe-Dashboard"
	[[ $SUBDIR != "" ]] && ssh -i $CELLFRAME_FILESERVER_KEY "$CELLFRAME_FILESERVER_CREDS" "mkdir -p $CELLFRAME_FILESERVER_PATH/$SUBDIR"
	scp -i $CELLFRAME_FILESERVER_KEY $PACKAGE_PATH/$pkgname$MODNAME.apk "$CELLFRAME_FILESERVER_CREDS:$CELLFRAME_FILESERVER_PATH/$SUBDIR"
	scp -r -i $CELLFRAME_FILESERVER_KEY ../../prod_build/general/essentials/$pkgname_weblink "$CELLFRAME_FILESERVER_CREDS:$CELLFRAME_FILESERVER_PATH/$SUBDIR"
	rm -r ../../prod_build/general/essentials/$pkgname_weblink
done
cd ../..
exit $errcode