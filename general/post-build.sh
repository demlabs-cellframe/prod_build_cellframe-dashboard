echo "workdir before postinstall is $(pwd)"

platform=$1
errstring=""
errcode=0

. prod_build/general/pre-build.sh
export_variables $(find "./prod_build/$platform/conf" -maxdepth 1 -type f)
export_variables "prod_build/general/conf/*"

echo $platform
echo $PACKAGE_PATH
echo "Mod handler"
if [[ $CI_COMMIT_REF_NAME != "" ]] && [[ $CI_COMMIT_REF_NAME != "master" ]]; then
	export MOD="-${CI_COMMIT_REF_NAME}"
fi
echo $MOD

[[ -e prod_build/$platform/scripts/post-build.sh ]] && prod_build/$platform/scripts/post-build.sh $platform || { errcode=$? && errstring="$errstring ${platform}_postbuild errcode $errcode"; } #For post-build actions not in chroot (global publish)
[[ $errstring != "" ]] && echo "$brand done with errors:" && echo "$errstring" >> ~/prod_log && errstring="" && errcode=5 ## General failure error

unexport_variables $(find "./prod_build/$platform/conf" -maxdepth 1 -type f)

exit  $errcode
