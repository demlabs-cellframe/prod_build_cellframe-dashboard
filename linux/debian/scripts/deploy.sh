#!/bin/bash

echo "Deploying to $PACKAGE_PATH"
echo $wd

CELLFRAME_REPO_CREDS="admin@debian.pub.demlabs.net"
CELLFRAME_REPO_KEY="~/.ssh/demlabs_publish"
CELLFRAME_REPO_PATH="~/web/debian.pub.demlabs.net/public_html"
CELLFRAME_FILESERVER_CREDS="admin@pub.cellframe.net"
CELLFRAME_FILESERVER_PATH="~/web/pub.cellframe.net/public_html/linux"
pwd

cd build
PKGFILES=$(ls . | grep .deb)
#cd ..
echo $VERSION_INFO
#echo "We have $DISTR_CODENAME there"
#echo "On path $REPO_DIR_SRC we have debian files."
[[ -v CI_COMMIT_REF_NAME ]] && [[ $CI_COMMIT_REF_NAME != "master" ]] && SUBDIR="${CI_COMMIT_REF_NAME}" || SUBDIR=""

[[ $ONBUILDSERVER == 0 ]] && scp -i $CELLFRAME_REPO_KEY ../prod_build/linux/debian/scripts/publish_remote/reprepro.sh "$CELLFRAME_REPO_CREDS:~/tmp/"
for pkgfile in $PKGFILES; do
	pkgname=$(echo $pkgfile | sed 's/.deb$//')
	mv $pkgfile $wd/$PACKAGE_PATH/$pkgname$MOD.deb || { echo "[ERR] Something went wrong in publishing the package. Now aborting."; exit -4; }
	CODENAME=$(echo $pkgname | rev | cut -d '-' -f1 | rev)
	if [[ $ONBUILDSERVER == 0 ]]; then
	#REPREPRO and file_cellframe_services
	echo "REF_NAME is $CI_COMMIT_REF_NAME"
		scp -i $CELLFRAME_REPO_KEY $wd/$PACKAGE_PATH/$pkgname$MOD.deb "$CELLFRAME_FILESERVER_CREDS:$CELLFRAME_FILESERVER_PATH/$SUBDIR/$pkgname_public$MOD.deb"
		scp -i $CELLFRAME_REPO_KEY $wd/$PACKAGE_PATH/$pkgname$MOD.deb "$CELLFRAME_REPO_CREDS:~/tmp/apt/"
		ssh -i $CELLFRAME_REPO_KEY "$CELLFRAME_REPO_CREDS" "chmod +x ~/tmp/reprepro.sh && ~/tmp/reprepro.sh main $CODENAME ~/tmp/apt/$pkgname$MOD.deb $CELLFRAME_REPO_PATH"
	set +x
		ssh -i $CELLFRAME_REPO_KEY "$CELLFRAME_FILESERVER_CREDS" "mkdir -p $CELLFRAME_FILESERVER_PATH/$SUBDIR"
		scp -i $CELLFRAME_REPO_KEY $wd/$PACKAGE_PATH/$pkgname$MOD.deb "$CELLFRAME_FILESERVER_CREDS:$CELLFRAME_FILESERVER_PATH/$SUBDIR/$pkgname$MOD.deb"
		ssh -i $CELLFRAME_REPO_KEY "$CELLFRAME_FILESERVER_CREDS" "ln -sf $CELLFRAME_FILESERVER_PATH/$pkgname$MOD.deb $CELLFRAME_FILESERVER_PATH/$pkgname$MOD-latest.deb"
	set -x
	fi
done
[[ $ONBUILDSERVER == 0 ]] && ssh -i $CELLFRAME_REPO_KEY "$CELLFRAME_REPO_CREDS" "rm -v ~/tmp/reprepro.sh"

	export -n "UPDVER"
cd ..
exit 0
#symlink name-actual to the latest version.
#build/deb/versions - for all files
#build/deb/${PROJECT}-latest - for symlinks.
