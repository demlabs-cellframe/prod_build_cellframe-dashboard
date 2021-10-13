#!/bin/bash

SERVICE=com.demlabs."$APP_NAME"Service
NODE=com.demlabs.cellframe-node

echo $SERVICE
launchctl stop $SERVICE
launchctl unload -w ~/Library/LaunchAgents/$SERVICE.plist

echo $NODE || exit $?
launchctl stop $NODE
launchctl unload -w ~/Library/LaunchAgents/$NODE.plist

ln -sf /Applications/"$APP_NAME".app/Contents/Resources/$SERVICE.plist ~/Library/LaunchAgents/$SERVICE.plist
ln -sf /Applications/"$APP_NAME".app/Contents/Resources/$NODE.plist ~/Library/LaunchAgents/$NODE.plist
launchctl load -w ~/Library/LaunchAgents/$NODE.plist

echo $USER_ID > /tmp/my_uid
launchctl load -w ~/Library/LaunchAgents/$SERVICE.plist

launchctl start $NODE
launchctl start $SERVICE


