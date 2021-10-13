#!/bin/bash

PLATFORM_CANDIDATES=$1
CHROOT_PREFIX="builder"
CHROOTS_PATH=$1
PLATFORMS=""
PKG_FORMAT=$3
JOB=$2
export wd=$(pwd)
cd $SRC_PATH

echo "workdir is $(pwd)"
. prod_build/general/pre-build.sh
export_variables "prod_build/general/conf/*"
. prod_build/general/mod-handler.sh
mod_handler $MOD
IFS=' '

if [[ $CI_COMMIT_REF_NAME != "" ]] && [[ $CI_COMMIT_REF_NAME != "master" ]]; then
	export MOD="${MOD} ${CI_COMMIT_REF_NAME}"
fi
MOD=$( echo $MOD | sed 's/ /-/g')
[ -e config.pribak ] && rm config.pribak


VERSION_STRING=$(echo "$VERSION_FORMAT" | sed "s/\"//g" ) #Removing quotes
VERSION_ENTRIES=$(echo "$VERSION_ENTRIES" | sed "s/\"//g" )
export VERSION_STRING=$(extract_version_number)
errcode=0
errstring=""
IFS=' '
PLATFORMS=""
echo "Platform Candidates test"
echo "$PLATFORM_CANDIDATES"
echo $IMPLEMENTED
for platform in $PLATFORM_CANDIDATES; do
	echo "checking out $platform"
	[[ $(echo $IMPLEMENTED | grep $platform) != "" ]] && PLATFORMS="$PLATFORMS$platform " || echo "Platform $platform is not implemented in this project yet. Sorry"
done
[[ $PLATFORMS != "" ]] && PLATFORMS=$(echo $PLATFORMS | sed 's/ $//')
echo "Platforms are $PLATFORMS there"
for platform in $PLATFORMS; do
		echo "Working with $platform now on $brand brand"
		PLATFORM_UPPERCASED=$( echo "$platform" | tr '[:lower:]' '[:upper:]')

		ENV=${PLATFORM_UPPERCASED}_ENV
		varpack=$( export | grep $PLATFORM_UPPERCASED | awk '{print $3}')
		if [ $(echo $platform | grep "linux") ]; then 
			ln -snf prod_build/linux/debian/essentials/$brand ./debian && ls -la . | grep debian
			[[ $platform == "linux" ]] && platform="linux/debian"
			export_variables "./prod_build/$platform/conf/*"
		elif [ $(echo $platform | grep -v "mac") ]; then
			export_variables "./prod_build/$platform/conf/*"
		fi


		if [[ ! -z ${ENV} ]]; then
			HOST_DISTR_VERSIONS=$(echo ${!ENV} | cut -d '-' -f1)
			HOST_ARCH_VERSIONS=$(echo ${!ENV} | cut -d '-' -f2)
		fi

		if [[ $platform == "mac" ]]; then

				[ -e prod_build/$platform/scripts/pre-build.sh ] && prod_build/$platform/scripts/pre-build.sh $CHROOT_PREFIX $platform || { errcode=$? && errstring="$errstring macprebuild $errcode" && echo "[ERR] Mac host prefetch errcode $errcode. Skipping"; exit $errcode; } #Setting up brand in conf file

				for conffile in $(find "./prod_build/$platform/conf" | grep conf/ | grep -v .bak); do
					export_variables $conffile
				done


				IFS=' '
				PKG_TYPE=$(echo $PKG_FORMAT | cut -d ' ' -f1)
				prod_build/$platform/scripts/$JOB.sh $PKG_TYPE || { errcode=$? && errstring="$errstring macbuild $errcode" && echo "[ERR] Mac host build errcode $errcode now. Skipping"; exit $errcode; }
				exit 0
			

		else


		#Check if chroots are present
		echo $HOST_DISTR_VERSIONS
		echo $HOST_ARCH_VERSIONS

		[[ -e prod_build/$platform/scripts/pre-build.sh ]] && prod_build/$platform/scripts/pre-build.sh $CHROOT_PREFIX $platform || echo "[WRN] No pre-build script detected. Moving on" #For actions before build not in chroot and in chroot (version update, install missing dependencies(under schroot))
			IFS=' '
			PKG_TYPE=$(echo $PKG_FORMAT | cut -d ' ' -f1)
		for distr in $HOST_DISTR_VERSIONS; do
			for arch in $HOST_ARCH_VERSIONS; do
				if [ -e $CHROOTS_PATH/$CHROOT_PREFIX-$distr-$arch ]; then
					echo "working with $CHROOT_PREFIX-$distr-$arch on brand $brand"
					schroot -c $CHROOT_PREFIX-$distr-$arch -- launcher.sh prod_build/$platform/scripts/$JOB.sh $PKG_TYPE $platform $brand $varpack || { errcode=$? && errstring="$errstring ${platform}_build $errcode" && echo "[ERR] $platform build on $HOST_DISTR_VERSIONS-$HOST_ARCH_VERSIONS errcode $errcode"; break 2; }
#					echo "schroot stub $PKG_TYPE"
				elif [[ $CHROOTS_PATH == "null" ]]; then
					prod_build/$platform/scripts/$JOB.sh $PKG_TYPE $platform $brand $varpack || { errcode=$? && errstring="$errstring ${platform}_build $errcode" && echo "[ERR] $platform build on $HOST_DISTR_VERSIONS-$HOST_ARCH_VERSIONS errcode $errcode"; break 2; }
				else
					echo "chroot $CHROOT_PREFIX-$distr-$arch not found. You should install it first"
				fi
			done
		done
		fi
		echo "workdir before postinstall is $(pwd)"
		[[ -e prod_build/$platform/scripts/post-build.sh ]] && prod_build/$platform/scripts/post-build.sh $platform || { errcode=$? && errstring="$errstring ${platform}_postbuild errcode $errcode"; continue; } #For post-build actions not in chroot (global publish)
		PKG_FORMAT=$(echo $PKG_FORMAT | cut -d ' ' -f2-)
		unexport_variables "./prod_build/$platform/conf/*"
done
[[ $errstring != "" ]] && echo "$brand done with errors:" && echo "$errstring" >> ~/prod_log && errstring="" && errcode=5 ## General failure error

#[ $(mount | grep "/run/schroot/mount") ] && sudo umount -l /run/schroot/mount && sudo rm -r /run/schroot/mount/* #Removing mountpoint odds.

cd $wd
exit $errcode

