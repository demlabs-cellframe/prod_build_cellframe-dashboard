#!/bin/bash

INSTALLER_USER=$(stat -f '%Su' $HOME)
[ -n "${USER}" ] && USER=${INSTALLER_USER}

LOG_FILE=/tmp/uninstall.log

APP_NAME=Cellframe-Dashboard
SERVICE=com.demlabs."$APP_NAME"Service
NODE=com.demlabs.cellframe-node

# Close standard output file descriptor
exec 1<&-
# Close standard error file descriptor
exec 2<&-

# Open standard output as $LOG_FILE file for read and write.
exec 1<>$LOG_FILE

# Redirect standard error to standard output
exec 2>&1

echo "Installing time!" 

sudo -u $USER launchctl stop $SERVICE 
sudo -u $USER launchctl unload -w $HOME/Library/LaunchAgents/$SERVICE.plist

sudo -u $USER launchctl stop $NODE
sudo -u $USER launchctl unload -w $HOME/Library/LaunchAgents/$NODE.plist


RET=0
echo "Installation logs" > /tmp/"$APP_NAME"_Install_Logs.txt

echo "Gui_check" >> /tmp/debug_dashboard.txt
if pgrep -x ""$APP_NAME"" > /dev/null
then
    	echo "Gui is Running" >> /tmp/"$APP_NAME"_Install_Logs.txt
    	./cmdAlert.app/Contents/MacOS/cmdAlert
	RET=$?
else
    	echo "Gui Stopped" >> /tmp/"$APP_NAME"_Install_Logs.txt
fi

echo "RET from asking user = $RET" >> /tmp/"$APP_NAME"_Install_Logs.txt
if [ "$RET" -eq "0" ]; then
	echo "Continue install" >> /tmp/"$APP_NAME"_Install_Logs.txt
elif [ "$RET" -eq "1" ]; then
	echo "Stop install" >> /tmp/"$APP_NAME"_Install_Logs.txt
	exit 1
fi


#### Kill all opened "$APP_NAME" gui clients
GuiPIDs=$(pgrep -x ""$APP_NAME"")
while read -r GuiPID; do
    	echo "... $GuiPID ..." >> /tmp/"$APP_NAME"_Install_Logs.txt
	if [ "$GuiPID" != "" ]; then
		echo ""$APP_NAME" is set! Kill It!!!" >> /tmp/"$APP_NAME"_Install_Logs.txt
		sudo kill $GuiPID
	fi
done <<< "$GuiPIDs"

echo "unloading the weirdo deps" >> /tmp/debug_dashboard.txt


[ -e /Library/LaunchDaemons/com.demlabs."$APP_NAME"Service.plist ] && launchctl unload -w $HOME/Library/LaunchAgents/com.demlabs."$APP_NAME"Service.plist
[ -e /Library/LaunchDaemons/com.demlabs.cellframe-node.plist ] && launchctl unload -w $HOME/Library/LaunchAgents/com.demlabs.cellframe-node.plist

rm -r /Applications/Cellframe.app

sudo rm -r /Applications/$APP_NAME.app

sudo rm -r $HOME/Applications/Cellframe.app


#delete "$APP_NAME"s from com.apple.dock.plist
echo "path to dock $HOME/Library/Preferences/com.apple.dock.plist" >> /tmp/"$APP_NAME"_Install_Logs.txt
dockApps=$(defaults read $HOME/Library/Preferences/com.apple.dock.plist persistent-apps | nl | grep file-label | awk '/"$APP_NAME"/  {print NR}')
cnt=1
while read -r app; do
	app=$[$app-$cnt]
	cnt=$[$cnt+1]
	if [ "$app" -ne "-1" ]; then
		echo "app in dock exists" >> /tmp/"$APP_NAME"_Install_Logs.txt
		sudo -u $USER /usr/libexec/PlistBuddy -c "Delete persistent-apps:$app" $HOME/Library/Preferences/com.apple.dock.plist
	else
		echo "app in dock don't exists" >> /tmp/"$APP_NAME"_Install_Logs.txt
	fi
done <<< "$dockApps"
osascript -e 'delay 2' -e 'tell Application "Dock"' -e 'quit' -e 'end tell'
osascript -e 'delay 2' -e 'tell Application "Dock"' -e 'quit' -e 'end tell'
exit 0

echo "cleanup done" >> /tmp/debug_dashboard.txt

#	<domains enable_localSystem="false" enable_anywhere="true" enable_currentUserHome="true"/>

