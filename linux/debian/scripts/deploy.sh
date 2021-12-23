#!/bin/bash

echo "Deploying to $PACKAGE_PATH"
echo $wd

CELLFRAME_REPO_CREDS="admin@debian.pub.demlabs.net"
CELLFRAME_REPO_KEY="~/.ssh/demlabs_publish"
CELLFRAME_REPO_PATH="~/web/debian.pub.demlabs.net/public_html"
CELLFRAME_REPO_PORT=34768
CELLFRAME_FILESERVER_CREDS="admin@pub.cellframe.net"
CELLFRAME_FILESERVER_PATH="~/web/pub.cellframe.net/public_html/linux"
pwd

cd build
PKGFILES=$(ls . | grep .deb)
#cd ..

[[ -v CI_COMMIT_REF_NAME ]] && [[ $CI_COMMIT_REF_NAME != "master" ]] && SUBDIR="${CI_COMMIT_REF_NAME}" || SUBDIR=""

#echo "We have $DISTR_CODENAME there"
#echo "On path $REPO_DIR_SRC we have debian files."
for pkgfile in $PKGFILES; do
	pkgname=$(echo $pkgfile | sed 's/.deb$//')
	pkgname_public=$(echo $pkgname | cut -d '-' -f1-4,7-) #cutting away Debian-9.12
	pkgname_weblink="$(echo $pkgname | cut -d '-' -f2,7 )-latest" #leaving only necessary entries
	mv $pkgfile $wd/$PACKAGE_PATH/$pkgname.deb || { echo "[ERR] Something went wrong in publishing the package. Now aborting."; exit -4; }
	CODENAME=$(echo $pkgname | rev | cut -d '-' -f1 | rev)
	cp -r ../prod_build/general/essentials/weblink-latest ../prod_build/general/essentials/$pkgname_weblink
	sed -i "/document/s/cellframe.*deb/$pkgname_public.deb/" ../prod_build/general/essentials/$pkgname_weblink/index.html
	echo "REF_NAME is $CI_COMMIT_REF_NAME"
	ssh -i $CELLFRAME_REPO_KEY "$CELLFRAME_FILESERVER_CREDS" "mkdir -p $CELLFRAME_FILESERVER_PATH/$SUBDIR"
	scp -i $CELLFRAME_REPO_KEY $wd/$PACKAGE_PATH/$pkgname.deb "$CELLFRAME_FILESERVER_CREDS:$CELLFRAME_FILESERVER_PATH/$SUBDIR/$pkgname_public.deb"
	scp -r -i $CELLFRAME_REPO_KEY ../prod_build/general/essentials/$pkgname_weblink "$CELLFRAME_FILESERVER_CREDS:$CELLFRAME_FILESERVER_PATH/$SUBDIR/"
# 	if [[ $CI_COMMIT_REF_NAME == "master" ]]; then
# 		scp -P $CELLFRAME_REPO_PORT -i $CELLFRAME_REPO_KEY $wd/$PACKAGE_PATH/$pkgname.deb "$CELLFRAME_REPO_CREDS:~/aptly/repo_update/$pkgname_public.deb"
# #			ssh -i $CELLFRAME_REPO_KEY "$CELLFRAME_REPO_CREDS" -- "~/aptly/repo_update.sh"
# 	fi
#		ssh -i $CELLFRAME_REPO_KEY "$CELLFRAME_FILESERVER_CREDS" "ln -sf $CELLFRAME_FILESERVER_PATH/$pkgname.deb $CELLFRAME_FILESERVER_PATH/$pkgname-latest.deb"
	rm -r ../prod_build/general/essentials/$pkgname_weblink
done

#	export -n "UPDVER"
cd ..
exit 0
#symlink name-actual to the latest version.
#build/deb/versions - for all files
#build/deb/${PROJECT}-latest - for symlinks.
