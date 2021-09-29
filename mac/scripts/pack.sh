# #!/bin/bash

# echo "packing things"


# cd $wd

# . prod_build/general/pre-build.sh
# VERSION_INFO=$(extract_version_number)

# #prepare
# mkdir -p $BUILD_PATH/payload_build
# mkdir -p $BUILD_PATH/scripts_build

# mv $BUILD_PATH/"$APP_NAME".plist $BUILD_PATH/"$APP_NAME".app $BUILD_PATH/payload_build
# mv $BUILD_PATH/preinstall $BUILD_PATH/postinstall $BUILD_PATH/scripts_build

# # create mkbom file
# mkbom -u 0 -g 80 $BUILD_PATH/payload_build $BUILD_PATH/Bom

# # create Payload
# (cd $BUILD_PATH/payload_build && find . | cpio -o --format odc --owner 0:80 | gzip -c) > $BUILD_PATH//Payload
# # create Scripts
# (cd $BUILD_PATH/scripts_build && find . | cpio -o --format odc --owner 0:80 | gzip -c) > $BUILD_PATH/Scripts

# #update PkgInfo
# numberOfFiles=$(find $BUILD_PATH/payload_build | wc -l)
# installKBytes=$(du -k -s $BUILD_PATH/payload_build | cut -d"$(echo -e '\t')" -f1)
# sed -i "s/numberOfFiles=\"[0-9]\+\"/numberOfFiles=\"$numberOfFiles\"/g" $BUILD_PATH/PackageInfo
# sed -i "s/installKBytes=\"[0-9]\+\"/installKBytes=\"$installKBytes\"/" $BUILD_PATH/PackageInfo

# #clear and build pkg
# rm -r $BUILD_PATH/payload_build $BUILD_PATH/scripts_build
# (cd $BUILD_PATH && xar --compression none -cf ../"$APP_NAME"-"$VERSION_INFO".pkg *)
# (cd $BUILD_PATH && rm -r Bom PackageInfo Payload Scripts)
# make distclean

# #exit 0

# #!/bin/bash

# echo "packing things"

# mkdir -p $wd/$BUILD_PATH

# ls $wd
# ls $wd/$BUILD_PATH
# cp -r $APP_PATH $wd/$BUILD_PATH/

# ##### -- REMOVE AFTER VARIABLE SCOPE IS RIGHT -- #####
# cd $wd/$SRC_PATH
# . "$wd/prod_build/general/pre-build.sh"
# VERSION_INFO=$(extract_version_number)
# cd $wd
# ##### -- PATCH_END -- #####

# pkgbuild --analyze --root $wd/$BUILD_PATH/ $wd/$BUILD_PATH/$APP_NAME.plist

# plutil -replace BundleIsRelocatable -bool NO $wd/$BUILD_PATH/$APP_NAME.plist

# pkgbuild --install-location /Applications --identifier com.demlabs.$APP_NAME --scripts $wd/prod_build/mac/essentialsq/$PKGSCRIPT_PATH --component-plist $wd/$BUILD_PATH/$APP_NAME.plist --root $wd/$BUILD_PATH/ $wd/$BUILD_PATH/$APP_NAME$VERSION_INFO.pkg

# #### For creating dmg
# #macdeployqt $APP_PATH -verbose=2 -no-strip -no-plugins -dmg

# #if [ -e $BUILD_PATH/SapNetGUI/$APP_NAME.dmg ]; then
# #    mv -f $BUILD_PATH/SapNetGUI/$APP_NAME.dmg $BUILD_PATH
#    echo "[*] Success"
#else
#    echo "[ERR] Nothing was build examine build.log for details"
#    exit 2
#fi

exit 0


