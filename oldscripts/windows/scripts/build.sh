#!/bin/bash
WORKDIR="resources/cellframe/cellframe-dashboard"
shift 3
SCRIPTDIR="prod_build/windows/scripts"

for var in $@; do
	export ${var//\"/} #export variables without quotes
done

pwd
#cd $WORKDIR
	$SCRIPTDIR/compile_and_pack.sh || { echo "[ERR] $PLATFORM compile_and_pack failed"; exit 12; } # && \
#	$SCRIPTDIR/test.sh || { echo "[ERR] $PLATFORM test failed"; exit 13; } && \
#	$SCRIPTDIR/install_test.sh || { echo "[ERR] $PLATFORM install_test failed"; exit 14; } && \
#	$SCRIPTDIR/cleanup.sh || { echo "[ERR] $PLATFORM cleanup failed"; exit 15; }
#cd $wd
