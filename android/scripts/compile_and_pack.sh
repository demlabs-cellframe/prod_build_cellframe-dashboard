#!/bin/bash

. ./prod_build/general/pre-build.sh
export_variables $(find "./prod_build/android/conf" -maxdepth 1 -type f)

PKG_TYPE=$1
platform=$2
BRAND=$3

shift 3
echo "On compile and pack platform with brand $BRAND"
## Passing by build variables, connected with android.
for var in $@; do
	export ${var//\"/} 
done
SRC_DIR=$(pwd)
RES_PATH=${SRC_DIR}/$RES_PATH
exitcode=0


mkdir -p $SRC_DIR/build/apk


ANDROID_SDK=/opt/android-sdk 
ANDROID_BUILD_TOOLS_VERSION=30.0.3 
	echo $(pwd)
	export_variables $(find "./prod_build/android/conf/$BRAND/" -maxdepth 1 -type f)

echo "extracting version"
VERSION=$(extract_version_number)
echo "version number is $VERSION"

IFS=' '

for androidVersion in $ANDROID_VERSIONS; do

	echo "Build android version: $androidVersion"
	BUILD_VARIANT="Default"
	#cd prod_build/android/essentials/key/
	if [[ $androidVersion == "normal" ]]; then
	#	rm creds.conf release-key.jks
	#	ln -s demlabs-key/creds.conf creds.conf 
	#	ln -s demlabs-key/release-key.jks release-key.jks
	#	cd -
		
	#	TARGET_SDK_VERSION=$SDK_VERSION_NORMAL
		APK_NAME=Cellframe-Dashboard

	elif [[ $androidVersion == "google-play" ]]; then
		BUILD_VARIANT="GooglePlay"

	#	rm creds.conf release-key.jks
	#	ln -s demlabs-key/creds.conf creds.conf 
	#	ln -s demlabs-key/demlabs-release-key.jks release-key.jks
	#	cd -
		
	#	TARGET_SDK_VERSION=$SDK_VERSION_GOOGLE_PLAY
	#	APK_NAME="$BRAND-GooglePlay"

		versionCode=$(cat "./brand/$BRAND/os/android/AndroidManifest.xml" | grep 'android:versionCode' | cut -d'"' -f 8)
		let "versionCode++"
		sed -i "s/android:versionCode=\"[0-9]\+\"/android:versionCode=\"$versionCode\"/g" brand/$BRAND/os/android/AndroidManifest.xml
	fi
	#sed -i "s/android:targetSdkVersion=\"[0-9]\+\"/android:targetSdkVersion=\"$TARGET_SDK_VERSION\"/g" brand/$BRAND/os/android/AndroidManifest.xml
	
	# versionCode=$(cat "./brand/$BRAND/os/android/AndroidManifest.xml" | grep 'android:targetSdkVersion' | cut -d'"' -f 4)

	#. prod_build/android/essentials/key/creds.conf
	[ ! $MOD = "" ] && MOD="-$MOD"
	mkdir -p $WORK_PATH
	wd=$(pwd)
	cd $WORK_PATH
	[ -v WORK_PATH ] && rm -rf * || { echo "WORK_PATH variable is undefined. Indirect launch detected."; exit -1; }

	APK_PATH=android/build/outputs/apk/release
	mkdir -p $APK_PATH
	echo "arch-versions are $ARCH_VERSIONS"
	IFS=" "


	for arch in $ARCH_VERSIONS; do
		mkdir -p $arch
		cd $arch
		export QT_SELECT=$arch
		ANDROID_ANDRQT_HOME=/usr/lib/crossdev/android-$arch/*/bin
		$ANDROID_ANDRQT_HOME/qmake -r -spec android-clang BUILD_VARIANT=$BUILD_VARIANT CONFIG+=release CONFIG+=qml_release BRAND=$BRAND BRAND_TARGET=$BRAND $SRC_DIR/*.pro && \
		$ANDROID_NDK_ROOT/prebuilt/$ANDROID_NDKHOST/bin/make -j$(nproc) && \
		$ANDROID_NDK_ROOT/prebuilt/$ANDROID_NDKHOST/bin/make install INSTALL_ROOT=$(pwd)/android && \
		echo "Deploying in " && pwd && $ANDROID_ANDRQT_HOME/androiddeployqt --output android --verbose --release --input DapChainVpnApplication/*.json --jdk $ANDROID_JAVA_HOME --gradle && echo "androiddeployqt complete" && \
		$ANDROID_SDK/build-tools/$ANDROID_BUILD_TOOLS_VERSION/zipalign -f -v 4 $(pwd)/$APK_PATH/android-release-unsigned.apk $(pwd)/$APK_PATH/android-release-unsigned-aligned.apk && echo "zipalign complete" && \
		$ANDROID_SDK/build-tools/$ANDROID_BUILD_TOOLS_VERSION/apksigner sign -ks $SRC_DIR/prod_build/android/essentials/key/release-key.jks --ks-key-alias $ALIAS --ks-pass pass:$PASS  \
		--v1-signing-enabled true --v2-signing-enabled true \
		--out $(pwd)/$APK_PATH/android-release-signed.apk $(pwd)/$APK_PATH/android-release-unsigned-aligned.apk && \
		mv -v $(pwd)/$APK_PATH/android-release-signed.apk $SRC_DIR/build/apk/"$APK_NAME-${VERSION}-$arch$MOD.apk" || \
		exitcode=$?
		cd $wd
		if [[ $exitcode != 0 ]]; then
			echo "Build failed with exit code $exitcode"
			cd $workdir
			exit $exitcode
		fi

	done
done

cd $workdir