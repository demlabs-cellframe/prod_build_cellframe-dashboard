#!/bin/bash
#set up config

echo "[!] Build source as application $APP_NAME ( $BUILD_PATH )"

echo "Qt path is on $QT_MAC_PATH with BRAND=$brand"
echo "j$(nproc)"

brand=CellFrameDashboard
#change standart library's paths on mac to paths on osxcross
sed -i "s/usr\/local/opt\/osxcross\/macports\/pkgs\/opt\/local/g" cellframe-node/cellframe-sdk/cmake/OS_Detection.cmake 
sed -i "s/usr\/local/opt\/osxcross\/macports\/pkgs\/opt\/local/g" cellframe-node/cellframe-sdk/dap-sdk/net/server/http_server/CMakeLists.txt 
sed -i "s/usr\/local/opt\/osxcross\/macports\/pkgs\/opt\/local/g" cellframe-node/cellframe-sdk/dap-sdk/core/libdap.pri 
sed -i "s/usr\/local/opt\/osxcross\/macports\/pkgs\/opt\/local/g" cellframe-node/cellframe-sdk/dap-sdk/core/src/darwin/macos/macos.pri

$QT_MAC_PATH/qmake *.pro -r -spec macx-clang CONFIG+=x86_64 BRAND=$brand BRAND_TARGET=$brand
sed -i "/\/opt\/clang\/lib\/clang\/11.0.0\/include/d" .qmake.stash

make -j$(nproc)

