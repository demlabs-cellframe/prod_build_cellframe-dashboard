#!/bin/bash

echo "Working with $brand now"
sed -i "s/android:versionName=\"[0-9]\+\.[0-9]\+-[0-9]\+\"/android:versionName=\"$VERSION_STRING\"/g" brand/$brand/os/android/AndroidManifest.xml