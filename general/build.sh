#!/bin/bash

platform=$1

echo "workdir is $(pwd)"
. prod_build/general/pre-build.sh
export_variables "prod_build/general/conf/*"
. prod_build/general/mod-handler.sh
mod_handler $MOD
IFS=' '

[ -e config.pribak ] && rm config.pribak


VERSION_STRING=$(echo "$VERSION_FORMAT" | sed "s/\"//g" ) #Removing quotes
VERSION_ENTRIES=$(echo "$VERSION_ENTRIES" | sed "s/\"//g" )
export VERSION_STRING=$(extract_version_number)
errcode=0
errstring=""
echo "Platform Candidates test"
echo $IMPLEMENTED
echo "checking out $platform"
[[ $(echo $IMPLEMENTED | grep $platform) != "" ]] && PLATFORMS="$PLATFORMS$platform " || echo "Platform $platform is not implemented in this project yet. Sorry"
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

if [[ $platform == "mac" ]]; then

	[ -e prod_build/$platform/scripts/pre-build.sh ] && prod_build/$platform/scripts/pre-build.sh $CHROOT_PREFIX $platform || { errcode=$? && errstring="$errstring macprebuild $errcode" && echo "[ERR] Mac host prefetch errcode $errcode. Skipping"; exit $errcode; } #Setting up brand in conf file

	for conffile in $(find "./prod_build/$platform/conf" | grep conf/ | grep -v .bak); do
		export_variables $conffile
	done

	IFS=' '
	for arch in $ARCH_VERSIONS; do
		prod_build/$platform/scripts/$JOB.sh $arch || { errcode=$? && errstring="$errstring macbuild $errcode" && echo "[ERR] Mac host build errcode $errcode now. Skipping"; exit $errcode; }
	done
	exit 0
	

else
	[[ -e prod_build/$platform/scripts/pre-build.sh ]] && prod_build/$platform/scripts/pre-build.sh $CHROOT_PREFIX $platform || echo "[WRN] No pre-build script detected. Moving on" #For actions before build not in chroot and in chroot (version update, install missing dependencies(under schroot))
		IFS=' '
		PKG_TYPE=$(echo $PKG_FORMAT | cut -d ' ' -f1)
		prod_build/$platform/scripts/$JOB.sh $PKG_TYPE $platform $brand $varpack || { errcode=$? && errstring="$errstring ${platform}_build $errcode" && echo "[ERR] $platform build on $HOST_DISTR_VERSIONS-$HOST_ARCH_VERSIONS errcode $errcode"; break 2; }
	fi
	unexport_variables "./prod_build/$platform/conf/*"
done
[[ $errstring != "" ]] && echo "$brand done with errors:" && echo "$errstring" >> ~/prod_log && errstring="" && errcode=5 ## General failure error

cd $wd
exit $errcode

