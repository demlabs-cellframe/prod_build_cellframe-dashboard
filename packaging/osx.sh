#!/bin/bash -e

set -e

if [ ${0:0:1} = "/" ]; then
	HERE=`dirname $0`
else
	CMD=`pwd`/$0
	HERE=`dirname ${CMD}`
fi

PKG_SIGN_POSSIBLE=1

if [ -z "$OSX_PKEY_INSTALLER" ]
then
	echo "No OSX_PKEY_INSTALLER provided. PKG will NOT be signed"
	PKG_SIGN_POSSIBLE=0
fi

if [ -z "$OSX_PKEY_APPLICATION" ]
then
	echo "No OSX_PKEY_APPLICATION provided. PKG will NOT be signed"
	PKG_SIGN_POSSIBLE=0
fi

if [ -z "$OSX_PKEY_INSTALLER_PASS" ]
then
	echo "No OSX_PKEY_INSTALLER_PASS provided. PKG will NOT be signed"
	PKG_SIGN_POSSIBLE=0
fi

if [ -z "$OSX_PKEY_APPLICATION_PASS" ]
then
	echo "No OSX_PKEY_APPLICATION_PASS provided. PKG will NOT be signed"
	PKG_SIGN_POSSIBLE=0
fi

if [ -z "$OSX_APPSTORE_CONNECT_KEY" ]
then
	echo "No OSX_APPSTORE_CONNECT_KEY provided. PKG will NOT be signed"
	PKG_SIGN_POSSIBLE=0
fi

PACK() 
{
    DIST_DIR=$1
    BUILD_DIR=$2
    OUT_DIR=$3

	BRAND=Cellframe-Dashboard

    #USED FOR PREPARATION OF UNIFIED BUNDLE
    #all binaries and some structure files are threre
    PACKAGE_DIR=${DIST_DIR}/osxpackaging

    #USED FOR PROCESSING OF PREPARED BUNDLE: BOM CREATION, ETC
    OSX_PKG_DIR=${DIST_DIR}/pkg

	BRAND_OSX_BUNDLE_DIR=${PACKAGE_DIR}/${BRAND}.app

    #prepare correct packaging structure
    mkdir -p ${PACKAGE_DIR}
    mkdir -p ${OSX_PKG_DIR}

    echo "Creating unified package structure in [$BRAND_OSX_BUNDLE_DIR]"

    #copy base application bundle
    #path to it in BRAND_OSX_BUNDLE_DIR
    cp -r ${DIST_DIR}/${BRAND}.app ${PACKAGE_DIR}

    #copy service binarys and resources
    cp -r ${DIST_DIR}/${BRAND}Service.app/Contents/MacOS/* ${BRAND_OSX_BUNDLE_DIR}/Contents/MacOS/
	cp -r ${DIST_DIR}/${BRAND}Service.app/Contents/Resources/* ${BRAND_OSX_BUNDLE_DIR}/Contents/Resources/


    #copy node binaries and resources
    cp -r ${DIST_DIR}/Cellframe.app/Contents/MacOS/* ${BRAND_OSX_BUNDLE_DIR}/Contents/MacOS/
	cp -r ${DIST_DIR}/Cellframe.app/Contents/Resources/* ${BRAND_OSX_BUNDLE_DIR}/Contents/Resources/

    #copy pkginstall
	cp  ${DIST_DIR}/PKGINSTALL/* ${PACKAGE_DIR}


	echo "Do packaging magic in [$PACKAGE_DIR]"
	cd $wd
	
	#get version info
	source "${HERE}/../version.mk"
    PACKAGE_NAME="cellframe-dashboard_${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}_amd64.pkg"
	PACKAGE_NAME_SIGNED="cellframe-dashboard_${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}_amd64-signed.pkg"
    echo "Building package [$PACKAGE_NAME]"

	#prepare
	PAYLOAD_BUILD=${PACKAGE_DIR}/payload_build
	SCRIPTS_BUILD=${PACKAGE_DIR}/scripts_build

	mkdir -p ${PAYLOAD_BUILD}
	mkdir -p ${SCRIPTS_BUILD}

	cp ${PACKAGE_DIR}/${BRAND}.plist ${PAYLOAD_BUILD}
	cp -r ${BRAND_OSX_BUNDLE_DIR} ${PAYLOAD_BUILD}

	
	cp ${PACKAGE_DIR}/preinstall ${SCRIPTS_BUILD}
	cp ${PACKAGE_DIR}/postinstall ${SCRIPTS_BUILD}

	#create .pkg struture to further xar coommand
	
	#modify plist cause of destination of node-binaries
	sed -i "s/CellframeNode/${BRAND}/g" ${PAYLOAD_BUILD}/${BRAND}.app/Contents/Resources/com.demlabs.cellframe-node.plist

	#code-sign binaries
	if [ "$PKG_SIGN_POSSIBLE" -eq "1" ]; then
		echo "Code-signig binaries"
		#add runtime flag to bypass notarization warnings about hardened runtime.
		rcodesign sign --code-signature-flags runtime --p12-file ${OSX_PKEY_APPLICATION} --p12-password ${OSX_PKEY_APPLICATION_PASS} ${PAYLOAD_BUILD}/${BRAND}.app
	fi

	# create bom file
	mkbom -u 0 -g 80 ${PAYLOAD_BUILD} ${OSX_PKG_DIR}/Bom

	# create Payload
	(cd ${PAYLOAD_BUILD} && find . | cpio -o --format odc --owner 0:80 | gzip -c) > ${OSX_PKG_DIR}/Payload
	# create Scripts
	(cd ${SCRIPTS_BUILD} && find . | cpio -o --format odc --owner 0:80 | gzip -c) > ${OSX_PKG_DIR}/Scripts

	#update PkgInfo
	cp ${PACKAGE_DIR}/PackageInfo ${OSX_PKG_DIR}

	numberOfFiles=$(find ${PAYLOAD_BUILD} | wc -l)
	installKBytes=$(du -k -s ${PAYLOAD_BUILD} | cut -d"$(echo -e '\t')" -f1)
	sed -i "s/numberOfFiles=\"[0-9]\+\"/numberOfFiles=\"$numberOfFiles\"/g" ${OSX_PKG_DIR}/PackageInfo
	sed -i "s/installKBytes=\"[0-9]\+\"/installKBytes=\"$installKBytes\"/" ${OSX_PKG_DIR}/PackageInfo

	(cd $OSX_PKG_DIR && xar --compression none -cf ../../${PACKAGE_NAME} *)
	
	#check if we can sign pkg
	#for certificate preparation see this guide: https://users.wfu.edu/cottrell/productsign/productsign_linux.html
	#for other things see rcodesing help

	if [ "$PKG_SIGN_POSSIBLE" -eq "1" ]; then
		echo "Signig $PACKAGE_NAME to $PACKAGE_NAME_SIGNED"

		cd ${OUT_DIR}
		
		rcodesign sign --p12-file ${OSX_PKEY_INSTALLER} --p12-password ${OSX_PKEY_INSTALLER_PASS} ${PACKAGE_NAME} ${PACKAGE_NAME_SIGNED}
		
		echo "Notarizing package"
		rcodesign notary-submit --api-key-path ${OSX_APPSTORE_CONNECT_KEY} ${PACKAGE_NAME_SIGNED} --staple
		rm ${PACKAGE_NAME}
	fi
}

