#!/bin/bash

echo "packing things"


cd $wd

. prod_build/general/pre-build.sh
VERSION_INFO=$(extract_version_number)

#prepare
mkdir -p $BUILD_PATH/payload_build
mkdir -p $BUILD_PATH/scripts_build

mv -f $BUILD_PATH/"$APP_NAME".plist $BUILD_PATH/"$APP_NAME".app $BUILD_PATH/payload_build
mv -f $BUILD_PATH/preinstall $BUILD_PATH/postinstall $BUILD_PATH/scripts_build

# create mkbom file
#mkbom -u 0 -g 80 $BUILD_PATH/payload_build $BUILD_PATH/Bom
mkbom -u 0 -g 80 $BUILD_PATH/payload_build $BUILD_PATH/Bom

# create Payload
#  --format odc --owner 0:80
(cd $BUILD_PATH/payload_build && find . | cpio -o --format odc --owner 0:80 | gzip -c) > $BUILD_PATH/Payload
# create Scripts
(cd $BUILD_PATH/scripts_build && find . | cpio -o --format odc --owner 0:80 | gzip -c) > $BUILD_PATH/Scripts

#update PkgInfo
numberOfFiles=$(find $BUILD_PATH/payload_build | wc -l)
installKBytes=$(du -k -s $BUILD_PATH/payload_build | cut -d"$(echo -e '\t')" -f1)

echo $numberOfFiles
sed -i "s/numberOfFiles=\"[0-9]\+\"/numberOfFiles=\"$numberOfFiles\"/g" $BUILD_PATH/PackageInfo
sed -i "s/installKBytes=\"[0-9]\+\"/installKBytes=\"$installKBytes\"/g" $BUILD_PATH/PackageInfo

#rm $BUILD_PATH/PackageInfobak
#clear and build pkg
rm -r $BUILD_PATH/payload_build $BUILD_PATH/scripts_build
(cd $BUILD_PATH && xar --compression none -cf ../"$APP_NAME"-"$VERSION_INFO".pkg *)
(cd $BUILD_PATH && rm -r Bom PackageInfo Payload Scripts)
# #make distclean

# exit 0


