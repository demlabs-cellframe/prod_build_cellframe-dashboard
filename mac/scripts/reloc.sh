    #!/bin/bash
    #set up config

  
    mkdir -p $wd/$BUILD_PATH
    cp -r $APP_PATH $wd/$BUILD_PATH

    if [ -e $wd/CellFrameDashboardService/"$APP_SERVICE_NAME" ]; then
        mv -f $wd/CellFrameDashboardService/"$APP_SERVICE_NAME"  $wd/$BUILD_PATH/$APP_NAME.app/Contents/MacOS
    fi

 	if [ -e $wd/cellframe-node/build/"$NODE_NAME" ]; then
        mv -f $wd/cellframe-node/build/"$NODE_NAME"  $wd/$BUILD_PATH/$APP_NAME.app/Contents/MacOS
    fi

	if [ -e $wd/cellframe-node/build/"$NODE_CLI_NAME" ]; then
        mv -f $wd/cellframe-node/build/"$NODE_CLI_NAME"  $wd/$BUILD_PATH/$APP_NAME.app/Contents/MacOS
    fi

	if [ -e $wd/cellframe-node/build/"$NODE_TOOL_NAME" ]; then
        mv -f $wd/cellframe-node/build/"$NODE_TOOL_NAME"  $wd/$BUILD_PATH/$APP_NAME.app/Contents/MacOS
    fi

    if [ -e $wd/prod_build/mac/essentials/com*Cellframe-DashboardService.plist ]; then
         cp -f $wd/prod_build/mac/essentials/com*Cellframe-DashboardService.plist $wd/$BUILD_PATH/$APP_NAME.app/Contents/Resources/
    fi

 	if [ -e $wd/prod_build/mac/essentials/com*cellframe-node.plist ]; then
         cp -f $wd/prod_build/mac/essentials/com*cellframe-node.plist $wd/$BUILD_PATH/$APP_NAME.app/Contents/Resources/
    fi
	
    if [ -e $wd/prod_build/mac/essentials/cleanup ]; then
         cp -rf $wd/prod_build/mac/essentials/cleanup $wd/$BUILD_PATH/$APP_NAME.app/Contents/Resources/
    fi

     
    if [ -e $wd/prod_build/mac/essentials/$APP_NAME-pkginstall ]; then
        cp -rf $wd/prod_build/mac/essentials/$APP_NAME-pkginstall/* $wd/$BUILD_PATH
    else
        echo "[ERR] Not found pkginstall files" && exit 1;
    fi
    

	cp -r $wd/cellframe-node/dist/share $wd/$BUILD_PATH/$APP_NAME.app/Contents/Resources
	cp -r $wd/cellframe-node/dist.darwin/etc $wd/$BUILD_PATH/$APP_NAME.app/Contents/Resources
	cp -f $wd/cellframe-node/scripts/* $wd/$BUILD_PATH/$APP_NAME.app/Contents/MacOS
	cp -f $wd/prod_build/mac/essentials/create_configs.sh $wd/$BUILD_PATH/$APP_NAME.app/Contents/MacOS

    exit 0
