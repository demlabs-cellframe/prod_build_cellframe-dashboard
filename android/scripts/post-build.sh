#!/bin/bash

#echo "Stub for post-build actions"
echo "Entering post-build deployment and cleanup"
SCRIPTDIR="prod_build/android/scripts"

$SCRIPTDIR/deploy.sh || exit 10 && \
$SCRIPTDIR/cleanup.sh || exit 11
