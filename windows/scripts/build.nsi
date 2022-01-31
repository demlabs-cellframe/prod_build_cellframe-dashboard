; ***************************************************************
; * Authors:
; * Konstantin Papizh <papizh.konstantin@demlabs.net>
; * DeM Labs Inc.   https://demlabs.net
; * Cellframe Project https://gitlab.demlabs.net/cellframe
; * Copyright  (c) 2020
; * All rights reserved.
; ***************************************************************

!define MULTIUSER_EXECUTIONLEVEL Admin
;!include "MultiUser.nsh"
!include "MUI2.nsh"
!include "x64.nsh"
!include "Nsis.defines.nsh"
!include "modifyConfig.nsh"						   

!define MUI_ICON		"icon_win32.ico"
!define MUI_UNICON		"icon_win32.ico"

!define NODE_NAME		"cellframe-node"
!define EXE_NAME		"${APP_NAME}.exe"
!define PUBLISHER		"Cellframe Network"

!define UNINSTALL_PATH "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"

!define MUI_COMPONENTSPAGE_TEXT_TOP ""

Unicode true
Name 	"${APP_NAME}"
OutFile	"${APP_NAME} ${APP_VER}.exe"
BrandingText "${APP_NAME} by ${PUBLISHER}"

!define MUI_FINISHPAGE_NOAUTOCLOSE

Var CommonDocuments
Var ConfigPath

VIProductVersion "${APP_VERSION}"
VIAddVersionKey "ProductName"		"${APP_NAME}"
VIAddVersionKey "CompanyName"		"${PUBLISHER}"
VIAddVersionKey "LegalCopyright"	"${PUBLISHER} 2021"
VIAddVersionKey "FileDescription"	"Cellframe Dashboard Application"
VIAddVersionKey "FileVersion"		"${APP_VER}"
VIAddVersionKey "ProductVersion"	"${APP_VER}"

Function .onInit
	${If} ${RunningX64}
		${EnableX64FSRedirection}
		SetRegView 64
	${else}
        MessageBox MB_OK "${APP_NAME} supports x64 architectures only"
        Abort
    ${EndIf}
	ReadRegStr $CommonDocuments HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" "Common Documents"
	StrCpy $ConfigPath "$CommonDocuments\${NODE_NAME}"
FunctionEnd

Function UninstPrev
	ReadRegStr $R0 HKLM "${UNINSTALL_PATH}" "UninstallString"
	${If} $R0 == ""
	Goto Fin
	${EndIf}
	DetailPrint "Uninstall older version" 
	ExecWait '"$R0" /S'
	Fin:
FunctionEnd				   
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES  

!insertmacro MUI_LANGUAGE 	"English"
!insertmacro MUI_LANGUAGE 	"Russian"

!macro varPaths
	IfFileExists "$ConfigPath\var\log" yesLog 0
	CreateDirectory "$ConfigPath\var\log"
yesLog:
	IfFileExists "$ConfigPath\var\lib\global_db" yesDb 0
	CreateDirectory "$ConfigPath\var\lib\global_db"
yesDb:
	IfFileExists "$ConfigPath\var\lib\wallet" yesWallet 0
	CreateDirectory "$ConfigPath\var\lib\wallet"	
yesWallet:
	IfFileExists "$ConfigPath\var\lib\ca" yesCa 0
	CreateDirectory "$ConfigPath\var\lib\ca"
yesCa:
	IfFileExists "$ConfigPath\log" yesDashLog 0
	CreateDirectory "$CommonDocuments\${APP_NAME}\log"
yesDashLog:
	IfFileExists "$ConfigPath\data" yesDashData 0
	CreateDirectory "$CommonDocuments\${APP_NAME}\data"
yesDashData:
!macroend

!insertmacro AdvReplace

!macro killAll
	nsExec::ExecToLog /OEM  'taskkill /f /im ${EXE_NAME}'
	nsExec::ExecToLog /OEM  'taskkill /f /im ${APP_NAME}Service.exe' ;Legacy
	nsExec::ExecToLog /OEM  'taskkill /f /im ${NODE_NAME}.exe'
	${DisableX64FSRedirection}
	nsExec::ExecToLog /OEM  'schtasks /Delete /TN "${APP_NAME}Service" /F' ;Legacy
	nsExec::ExecToLog /OEM  'schtasks /Delete /TN "${NODE_NAME}" /F'	
    ${EnableX64FSRedirection}
	nsExec::ExecToLog /OEM 'sc stop ${APP_NAME}Service'
!macroend

InstallDir "$PROGRAMFILES64\${APP_NAME}"

Section -UninstallPrevious
    Call UninstPrev
SectionEnd

Section "${APP_NAME}" CORE
	SectionIn RO
	SetOutPath "$INSTDIR"
!insertmacro killAll
	File "${APP_NAME}.exe"
	File "${APP_NAME}Service.exe"
	File "${NODE_NAME}.exe"
	File "${NODE_NAME}-cli.exe"
	File "${NODE_NAME}-tool.exe"
!insertmacro varPaths
	SetOutPath "$ConfigPath"
	File /r "dist\"
	Rename "$ConfigPath\etc\${NODE_NAME}.cfg.tpl" "$ConfigPath\etc\${NODE_NAME}.cfg"
	Var /GLOBAL net1
	StrCpy $net1 "subzero"
	Rename "$ConfigPath\etc\network\$net1.cfg.tpl" "$ConfigPath\etc\network\$net1.cfg"
!insertmacro modifyConfigFiles
	WriteRegStr HKLM "${UNINSTALL_PATH}" "DisplayName" "${APP_NAME} ${APP_VER}"
	WriteRegStr HKLM "${UNINSTALL_PATH}" "UninstallString" "$INSTDIR\Uninstall.exe"
	WriteRegStr HKLM "${UNINSTALL_PATH}" "DisplayVersion" "${APP_VERSION}"
	WriteRegStr HKLM "${UNINSTALL_PATH}" "Publisher" "${PUBLISHER}"
	WriteRegStr HKLM "${UNINSTALL_PATH}" "DisplayIcon" "$INSTDIR\${EXE_NAME}"
	
	WriteRegStr HKCU "Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" "$INSTDIR\${NODE_NAME}.exe" 		"RUNASADMIN"
	;WriteRegStr HKCU "Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" "$INSTDIR\${APP_NAME}Service.exe" "RUNASADMIN"
	WriteUninstaller "$INSTDIR\Uninstall.exe"
	CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${EXE_NAME}"
    ${DisableX64FSRedirection}
	nsExec::ExecToLog /OEM  'schtasks /Create /F /RL highest /SC onlogon /TR "$INSTDIR\${NODE_NAME}.exe" /TN "${NODE_NAME}"'
	;nsExec::ExecToLog /OEM  'schtasks /Create /F /RL highest /SC onlogon /TR "$INSTDIR\${APP_NAME}Service.exe" /TN "${APP_NAME}Service"'
	;CreateShortCut "$DESKTOP\${APP_NAME}Service.lnk" "$INSTDIR\${APP_NAME}Service.exe"
SectionEnd

Section -startNode
	nsExec::ExecToLog /OEM  'dism /online /enable-feature /featurename:MSMQ-Container /featurename:MSMQ-Server /featurename:MSMQ-Multicast /NoRestart'
	${EnableX64FSRedirection}
	Exec '"$INSTDIR\${NODE_NAME}.exe"'
	;Exec '"$INSTDIR\${APP_NAME}Service.exe"'
	nsExec::ExecToLog /OEM '"$INSTDIR\${APP_NAME}Service.exe" install'
	nsExec::ExecToLog /OEM 'sc start ${APP_NAME}Service'
SectionEnd

Section "Uninstall"
	SetRegView 64
	!insertmacro killAll
	nsExec::ExecToLog /OEM 'sc delete ${APP_NAME}Service'
	Delete "$INSTDIR\${APP_NAME}.exe"
	Delete "$INSTDIR\${APP_NAME}Service.exe"
	Delete "$INSTDIR\${NODE_NAME}.exe"
	Delete "$INSTDIR\${NODE_NAME}-tool.exe"
	Delete "$INSTDIR\${NODE_NAME}-cli.exe"
	DeleteRegKey HKLM "${UNINSTALL_PATH}"
	DeleteRegKey HKCU "Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers\$INSTDIR\${NODE_NAME}.exe"
	DeleteRegKey HKCU "Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers\$INSTDIR\${APP_NAME}Service.exe"
	Delete "$INSTDIR\Uninstall.exe"
	Delete "$DESKTOP\${APP_NAME}.lnk"
	;Delete "$DESKTOP\${APP_NAME}Service.lnk"
	RMDir "$INSTDIR"
SectionEnd
