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
!include "LogicLib.nsh"

Unicode true

Name 	"${APP_NAME} ${DAP_VER}"
OutFile	"${APP_NAME} ${DAP_VER}.exe"
BrandingText "${APP_NAME} Inc."

!define MUI_FINISHPAGE_NOAUTOCLOSE

Var CommonDocuments

VIProductVersion "${APP_VERSION}"
VIAddVersionKey "ProductName"		"${APP_NAME}"
VIAddVersionKey "CompanyName"		"${PUBLISHER}"
VIAddVersionKey "LegalCopyright"	"${PUBLISHER} � 2021"
VIAddVersionKey "FileDescription"	"Dashboard"
VIAddVersionKey "FileVersion"		"${APP_VERSION}"

Function .onInit
	${If} ${RunningX64}
		${EnableX64FSRedirection}
		SetRegView 64
	${else}
        MessageBox MB_OK "${APP_NAME} supports x64 architectures only"
        Abort
    ${EndIf}
	ReadRegStr $CommonDocuments HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" "Common Documents"
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

Function UninstLegacy
	ReadRegStr $R0 HKCU "Software\demlabs\${APP_OLD_NAME}" "key"
	${If} $R0 == ""
	Goto SerialDone
	${EndIf}
	WriteRegStr HKCU "Software\CellFrameDashboard\CellFrameDashboard" "key" "$R0"
	ReadRegStr $R1 HKCU "Software\demlabs\${APP_OLD_NAME}" "serialkey"
	WriteRegStr HKCU "Software\CellFrameDashboard\CellFrameDashboard" "serialkey" "$R1"
	DeleteRegKey HKCU "Software\demlabs\${APP_OLD_NAME}"
	SerialDone:
	ReadRegStr $R0 HKLM "${UNINSTALL_OLD_PATH}" "UninstallString"
	${If} $R0 == ""
	Goto FinLegacy
	${EndIf}
	RMDir /r "$CommonDocuments\${APP_OLD_NAME}"
	DetailPrint "Uninstall legacy version" 
	ExecWait '"$R0" /S'
	FinLegacy:
FunctionEnd

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES  

!insertmacro MUI_LANGUAGE 	"English"
!insertmacro MUI_LANGUAGE 	"Russian"

!macro logDirCreate
	IfFileExists "$CommonDocuments\${APP_NAME}\log" yesLog 0
	CreateDirectory "$CommonDocuments\${APP_NAME}\log"
yesLog:
!macroend

!macro runDirCreate
	IfFileExists "$CommonDocuments\${APP_NAME}\run" yesRun 0
	CreateDirectory "$CommonDocuments\${APP_NAME}\run"
yesRun:
!macroend

!macro startService
	nsExec::Exec 'sc start ${APP_NAME}Service'
!macroend

!macro stopService
	nsExec::Exec 'sc stop ${APP_NAME}Service'
!macroend

!macro deleteService
	nsExec::Exec 'sc delete ${APP_NAME}Service'
!macroend

!macro killGUI
	nsExec::Exec 'taskkill /f /im ${EXE_NAME}'
!macroend

LangString DESC_TAP ${LANG_ENGLISH} "Cellframe-node, required to run on Windows"
LangString DESC_CORE ${LANG_ENGLISH} "${APP_NAME} components"

LangString DESC_TAP ${LANG_RUSSIAN} ""
LangString DESC_CORE ${LANG_RUSSIAN} "�������� ���������� ${APP_NAME}"

InstallDir "$PROGRAMFILES64\${APP_NAME}"

!define PRODUCT_NAME "${APP_NAME}"
!define PRODUCT_VERSION "${DAP_VER}"
!define PRODUCT_FULLNAME "${APP_NAME} ${DAP_VER}"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_FULLNAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define PRODUCT_UNINSTALL_EXE "uninstall.exe"

Section -UninstallPrevious
	Call UninstLegacy
    Call UninstPrev
SectionEnd

Section "${APP_NAME}" CORE
	SectionIn RO
	SetOutPath "$INSTDIR"
	nsExec::Exec 'taskkill /f /im "$INSTDIR\${APP_NAME}Service.exe"'	
!insertmacro killGUI
!insertmacro stopService
!insertmacro deleteService
	File "${APP_NAME}.exe"
	File "${APP_NAME}Service.exe"
	File "libeay32.dll"
	File "ssleay32.dll"
!insertmacro logDirCreate
!insertmacro runDirCreate
	WriteRegStr HKLM "${UNINSTALL_PATH}" "DisplayName" "${APP_NAME} ${APP_VERSION}"
	WriteRegStr HKLM "${UNINSTALL_PATH}" "UninstallString" "$INSTDIR\Uninstall.exe"
	WriteRegStr HKLM "${UNINSTALL_PATH}" "DisplayVersion" "${APP_VERSION}"
	WriteRegStr HKLM "${UNINSTALL_PATH}" "Publisher" "${PUBLISHER}"
	WriteRegStr HKLM "${UNINSTALL_PATH}" "DisplayIcon" "$INSTDIR\${EXE_NAME}"
	WriteUninstaller "$INSTDIR\Uninstall.exe"
	CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${EXE_NAME}"
SectionEnd


Section -installService
	nsExec::Exec 'dism /online /enable-feature /featurename:MSMQ-Container /featurename:MSMQ-Server /featurename:MSMQ-Multicast /NoRestart'
	nsExec::Exec '"$INSTDIR\${APP_NAME}Service.exe" install'
!insertmacro startService
SectionEnd

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
;!insertmacro MUI_DESCRIPTION_TEXT ${UninstallPrevious} ""
!insertmacro MUI_DESCRIPTION_TEXT ${TAP} $(DESC_TAP)
!insertmacro MUI_DESCRIPTION_TEXT ${CORE} $(DESC_CORE)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Section "Uninstall"
	SetRegView 64
!insertmacro killGUI
!insertmacro stopService
!insertmacro deleteService
	Delete "$INSTDIR\${APP_NAME}.exe"
	Delete "$INSTDIR\${APP_NAME}Service.exe"
	Delete "$DESKTOP\${APP_NAME}.lnk"
	Delete "$INSTDIR\libeay32.dll"
	Delete "$INSTDIR\ssleay32.dll"
	DeleteRegKey HKLM "${UNINSTALL_PATH}"
	Delete "$INSTDIR\Uninstall.exe"
	RMDir /r "$INSTDIR\drivers"
	RMDir "$INSTDIR"
SectionEnd
