#!/bin/bash
echo "Deploying the mac app"
pwd
$QT_MAC_PATH/macdeployqt CellFrameDashboardGUI/bin/release/CellFrameDashboard.app -verbose=3
