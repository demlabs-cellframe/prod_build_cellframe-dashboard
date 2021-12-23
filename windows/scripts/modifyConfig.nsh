!macro AdvReplace
Function AdvReplaceInFile
	Exch $0
	Exch
	Exch $1
	Exch
	Exch 2
	Exch $2
	Exch 2
	Exch 3
	Exch $3
	Exch 3
	Exch 4
	Exch $4
	Exch 4
	Push $5
	Push $6
	Push $7
	Push $8
	Push $9
	Push $R0
	Push $R1
	Push $R2
	Push $R3
	Push $R4
	Push $R5
	Push $R6
	
	GetFullPathName $R1 $0\..

	GetTempFileName $R6 $R1
	FileOpen $R1 $0 r
	FileOpen $R0 $R6 w
	StrLen $R3 $4
	StrCpy $R4 -1
	StrCpy $R5 -1
loop_read:
	ClearErrors
	FileRead $R1 $R2
	IfErrors exit
	StrCpy $5 0
	StrCpy $7 $R2
loop_filter:
	IntOp $5 $5 - 1
	StrCpy $6 $7 $R3 $5
	StrCmp $6 "" file_write2
	StrCmp $6 $4 0 loop_filter
	StrCpy $8 $7 $5
	IntOp $6 $5 + $R3
	StrCpy $9 $7 "" $6
	StrLen $6 $7
	StrCpy $7 $8$3$9
	StrCmp -$6 $5 0 loop_filter
	IntOp $R4 $R4 + 1
	StrCmp $2 all file_write1
	StrCmp $R4 $2 0 file_write2
	IntOp $R4 $R4 - 1
	IntOp $R5 $R5 + 1
	StrCmp $1 all file_write1
	StrCmp $R5 $1 0 file_write1
	IntOp $R5 $R5 - 1
	Goto file_write2
file_write1:
	FileWrite $R0 $7
	Goto loop_read
file_write2:
	FileWrite $R0 $7
	Goto loop_read
exit:
	FileClose $R0
	FileClose $R1
	SetDetailsPrint none
	Delete $0
	Rename $R6 $0
	Delete $R6
	SetDetailsPrint both

	Pop $R6
	Pop $R5
	Pop $R4
	Pop $R3
	Pop $R2
	Pop $R1
	Pop $R0
	Pop $9
	Pop $8
	Pop $7
	Pop $6
	Pop $5
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Pop $0
FunctionEnd


!macroend



!macro modifyConfigEntry Parameter Value Filename
	push `${Parameter}`
	push `${Value}`
	push all
	push all
	push `${Filename}`
		Call AdvReplaceInFile
!macroend

!macro modifyConfigFiles

!insertmacro modifyConfigEntry "{DEBUG_MODE}" 			"false" "$ConfigPath\etc\${NODE_NAME}.cfg"
!insertmacro modifyConfigEntry "{DEBUG_STREAM_HEADERS}"	"false" "$ConfigPath\etc\${NODE_NAME}.cfg"
!insertmacro modifyConfigEntry "{AUTO_ONLINE}"			"false"		"$ConfigPath\etc\${NODE_NAME}.cfg"
!insertmacro modifyConfigEntry "{SERVER_ENABLED}"		"true"		"$ConfigPath\etc\${NODE_NAME}.cfg"
!insertmacro modifyConfigEntry "{SERVER_ADDR}" 			"0.0.0.0" 	"$ConfigPath\etc\${NODE_NAME}.cfg"
!insertmacro modifyConfigEntry "{SERVER_PORT}" 			"8079"		"$ConfigPath\etc\${NODE_NAME}.cfg"
!insertmacro modifyConfigEntry "{NODE_TYPE}" 			"master"	"$ConfigPath\etc\network\private.cfg.tpl"
!insertmacro modifyConfigEntry "{NODE_TYPE}" 			"master"	"$ConfigPath\etc\network\core-t.cfg.tpl"
!insertmacro modifyConfigEntry "{NODE_TYPE}" 			"master"	"$ConfigPath\etc\network\subzero.cfg"

!insertmacro modifyConfigEntry "listen_unix_socket_path" 	"#listen_unix_socket_path" 	"$ConfigPath\etc\${NODE_NAME}.cfg"
!insertmacro modifyConfigEntry "#listen_port_tcp=12345"		"listen_port_tcp=12345"		"$ConfigPath\etc\${NODE_NAME}.cfg"

!insertmacro modifyConfigEntry "{PREFIX}" 	"$ConfigPath"	"$ConfigPath\etc\${NODE_NAME}.cfg"
!insertmacro modifyConfigEntry "{PREFIX}"	"$ConfigPath"	"$ConfigPath\etc\network\core-t\chain-0.cfg"
!insertmacro modifyConfigEntry "{PREFIX}"	"$ConfigPath"	"$ConfigPath\etc\network\core-t\chain-plasma.cfg"
!insertmacro modifyConfigEntry "/opt/cellframe-node"	"$ConfigPath"	"$ConfigPath\etc\network\core-t\chain-0.cfg"
!insertmacro modifyConfigEntry "/opt/cellframe-node"	"$ConfigPath"	"$ConfigPath\etc\network\core-t\chain-plasma.cfg"
!insertmacro modifyConfigEntry "/opt/cellframe-node"	"$ConfigPath"	"$ConfigPath\etc\network\subzero\chain-0.cfg"
!insertmacro modifyConfigEntry "/opt/cellframe-node"	"$ConfigPath"	"$ConfigPath\etc\network\subzero\support-chain.cfg"

!insertmacro modifyConfigEntry "/" "\" "$ConfigPath\etc\${NODE_NAME}.cfg"
!insertmacro modifyConfigEntry "/" "\" "$ConfigPath\etc\network\core-t\chain-0.cfg"
!insertmacro modifyConfigEntry "/" "\" "$ConfigPath\etc\network\core-t\chain-plasma.cfg"
!insertmacro modifyConfigEntry "/" "\" "$ConfigPath\etc\network\subzero\chain-0.cfg"
!insertmacro modifyConfigEntry "/" "\" "$ConfigPath\etc\network\subzero\support-chain.cfg"

!macroend

