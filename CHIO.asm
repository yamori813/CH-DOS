;
;
;

	INCLUDE "N80.inc"
	INCLUDE "LABELS.inc"

	INCLUDE "CH376.inc"

	GLOBAL	FIREWALL
	GLOBAL	IS_CALLBACK
	GLOBAL	INFO_BUF
	GLOBAL	INFO_SW
	GLOBAL	FILE_BFFR
	GLOBAL	BFFR_POS
	GLOBAL	BFFR_BLOCK
	GLOBAL	ARG0
	GLOBAL	ARG1
	GLOBAL	ARG2
	GLOBAL	ARG3
	GLOBAL	ARGNUM
	GLOBAL	DNAME
	GLOBAL	DIR_ENTRY
	GLOBAL	NG_CHR
	GLOBAL	NG_END

	GLOBAL	INIT_CH376
	GLOBAL	CH_OPENDIR
	GLOBAL	CH_CLOSE
	GLOBAL	CH_FILES
	GLOBAL	CH_LOAD
	GLOBAL	CH_SAVE
	GLOBAL	READ_FP_SCTR
	GLOBAL	CH_WRITE

	EXTERN	INIT_FAT16
	EXTERN	PRT_DENT
	EXTERN	FETCH_1BYTE
	EXTERN	READ_CMT
	EXTERN	WRITE_CMT
	EXTERN	ERR_NOT_FOUND

	EXTERN	MOUNT
	EXTERN	FILES
	EXTERN	LOAD
	EXTERN	SAVE

	EXTERN	DISP

;=================================================

START:
	CALL	INIT_FAT16
	CALL	INIT_CMDHOOK

	JP	05C66H		; Back to mon

;=================================================

INIT_CH376:
	
; RESET_ALL make corrupt GET_IC_VER ?
;	LD	A,RESET_ALL
;	WRITECMD
;	LD	C,200
;	CALL	MDELAY

	LD	A, GET_IC_VER
	WRITECMD
	READDATA
;	CALL	DISP
;	PUT	' '

	LD	A, CHECK_EXIST
	WRITECMD
	LD	A, 01H
	WRITEDATA
	READDATA
;	CALL	DISP
;	PUT	' '

	LD	A,SET_USB_MODE
	WRITECMD
;	LD	A, 6
	LD	A, 5
	WRITEDATA
	READDATA
;	CALL	DISP
;	PUT	' '

	LD	A, DISK_CONNECT
	CALL	INTRCMD

	LD	A, DISK_MOUNT
	CALL	INTRCMD

	PUSH	HL
	LD	HL, FILENAME
	CALL	SETFNAME

	LD	A, FILE_OPEN
	CALL	INTRCMD

	LD	HL, ROOTNAME
	CALL	SETFNAME

	LD	A, FILE_OPEN
	CALL	INTRCMD
	POP	HL

	RET

;=================================================

INIT_CMDHOOK:
	LD	HL, MOUNT
	LD	(ENT_MOUNT),HL

	LD	HL, FILES
	LD	(ENT_FILES),HL

	LD	HL, LOAD
	LD	(ENT_LOAD),HL

	LD	HL, SAVE
	LD	(ENT_SAVE),HL

	RET

;=================================================

CH_OPENDIR:
	LD	HL, DIR_ENTRY

	LD	A, SET_FILE_NAME
	WRITECMD

	LD	A, (HL)
	INC	HL
	WRITEDATA
DIRLOOP:
	LD	A, (HL)
	INC	HL
	AND	A, A
	JP	Z, DIREND
	CP	'/'
	JP	Z, SDIR
	WRITEDATA
	JP	DIRLOOP
SDIR:
	XOR	A
	WRITEDATA
	LD	A, FILE_OPEN
	CALL	INTRCMD

	LD	A, SET_FILE_NAME
	WRITECMD

	JP	DIRLOOP

DIREND:
	XOR	A
	WRITEDATA
	LD	A, FILE_OPEN
	CALL	INTRCMD
	RET

;=================================================

CH_CLOSE:
	LD	C, A
	LD	A, FILE_CLOSE
	WRITECMD
	LD	A, C
	WRITEDATA
	CALL	WAITINT
	RET

;=================================================

CH_FILES:

	CALL	DIR_WALK

	LD	A, GET_STATUS
	WRITECMD
	READDATA
;	CALL	DISP
;	PUT	' '
	CALL	READUSB

;	LD	A, FILE_CLOSE
;	WRITECMD
;	LD	A, 0
;	WRITEDATA
;	CALL	WAITINT

	RET

;=================================================

CH_LOAD:
	XOR	A
	LD	(BFFR_POS), A
	LD	(BFFR_BLOCK), A

	LD	HL, (ARG0)
	CALL	SETFNAME

	LD	A, FILE_OPEN
	CALL	INTRCMD

	LD	A, GET_STATUS
	WRITECMD
	READDATA
	CP	USB_INT_SUCCESS
	JP	Z, GSIZE

	CALL	CH_OPENDIR
	JP	ERR_NOT_FOUND

GSIZE:
	LD	A, GET_FILE_SIZE
	WRITECMD
	LD	A, 68H
	WRITEDATA
	READDATA
	LD	(FILE_SIZE), A
	READDATA
	LD	(FILE_SIZE + 1), A
	READDATA
	READDATA

	CALL	READ_CMT

	LD	A, 0
	CALL	CH_CLOSE

	LD	A, GET_STATUS
	WRITECMD
	READDATA
;	CALL	DISP
;	PUT	' '
	CALL	READUSB

	CALL	CH_OPENDIR

	RET

;=================================================

READ_FP_SCTR:
	LD	A, BYTE_READ
	WRITECMD
	LD	A, 128
	WRITEDATA
	LD	A, 0
	WRITEDATA
	CALL	WAITINT

	LD	A, GET_STATUS
	WRITECMD
	READDATA
;	CALL	DISP
;	PUT	'S'

	LD	HL, FILE_BFFR
	CALL	READUSBF
	LD	A,(FILE_BFFR)
;	CALL	DISP
;	PUT	','

	LD	A, BYTE_RD_GO
	WRITECMD
	CALL	WAITINT
	LD	A, GET_STATUS
	WRITECMD
	READDATA
;	CALL	DISP
;	PUT	'S'

	RET

;=================================================

DIR_WALK:
	LD	A, BYTE_READ
	WRITECMD
	LD	A, 32
	WRITEDATA
	LD	A, 0
	WRITEDATA
	CALL	WAITINT
	LD	HL, FATENT
	CALL	READUSBF
	LD	A, BYTE_RD_GO
	WRITECMD
	CALL	WAITINT
	LD	A, GET_STATUS
	WRITECMD
	READDATA

	LD	A,(FATENT)
	OR	A, A
	JZ	FATEND
	CP	A, 0E5H
	JZ	DIR_WALK
	LD	HL, FATENT
	CALL	PRT_DENT
	JR	DIR_WALK
FATEND:
	LD	A, BYTE_LOCATION	; back to start postion
	WRITECMD
	XOR	A
	WRITEDATA
	WRITEDATA
	WRITEDATA
	WRITEDATA
	CALL	WAITINT
	
	RET

;=================================================

SETFNAME:
	LD	A, SET_FILE_NAME
	WRITECMD
FSLOOP:
	LD	A, (HL)
	AND	A, A
	JP	Z, FINFS
	WRITEDATA
	INC	HL
	JP	FSLOOP
FINFS:
	WRITEDATA
	RET

;=================================================
; 8.4.5. Create file and write data

CH_SAVE:
	XOR	A
	LD	(BFFR_POS), A

	LD	HL, (ARG0)
	CALL	SETFNAME

	LD	A, FILE_CREATE
	CALL	INTRCMD

	LD	A, GET_STATUS
	WRITECMD
	READDATA
;	CALL	DISP
;	PUT	'-'

	CALL	WRITE_CMT

	LD	A, 1
	CALL	CH_CLOSE

;	CALL	CH_OPENDIR

	RET

;=================================================

CH_WRITE:
	LD	C, A
	LD	A, BYTE_WRITE
	WRITECMD
	LD	A, C
	WRITEDATA
	XOR	A
	WRITEDATA
	CALL	WAITINT

	LD	A, GET_STATUS
	WRITECMD
	READDATA
;	CALL	DISP
;	PUT	'-'

	LD	A, WR_REQ_DATA
	WRITECMD

	READDATA
;	CALL	DISP
;	PUT	'*'

	LD	HL, FILE_BFFR
WLOOP:
	LD	A, (HL)
	INC	HL
	WRITEDATA
	DEC	C
	JR	NZ, WLOOP

	LD	A, BYTE_WR_GO
	WRITECMD
	CALL	WAITINT

	LD	A, GET_STATUS
	WRITECMD
	READDATA
;	CALL	DISP
;	PUT	'-'

	RET

;=================================================

READUSB:
	LD	A, RD_USB_DATA0
	WRITECMD
	READDATA
	LD	C, A
;	CALL	DISP
;	PUT	'['
	LD	A, C
	OR	A, A
	JP	Z, L02
LO1:
	READDATA
;	CALL	DISP
;	PUT	' '
	DEC	C
	JP	NZ, LO1
L02:
;	PUT	']'
	RET

;=================================================

READUSBF:
	LD	A, RD_USB_DATA0
	WRITECMD
	READDATA
	LD	C, A
;	CALL	DISP
;	PUT	'+'
	LD	A, C
	OR	A, A
	JP	Z, L12
L11:
	READDATA
	LD	(HL), A
	INC	HL
	DEC	C
	JP	NZ, L11
L12:
	RET

;=================================================

INTRCMD:
	WRITECMD
	CALL	WAITINT
	LD	A, GET_STATUS
	WRITECMD
	READDATA
;	CALL	DISP
;	PUT	' '
	CALL	READUSB
	RET

;=================================================

WAITINT:
	READCMD
	AND	A,80H
	JP	NZ, WAITINT
	RET

;=================================================

MDELAY:
	PUSH	BC
DLOOP:
	LD	B,99H
DL1:	NOP
	DJNZ	DL1
	DEC	C
	JR	NZ,DLOOP
	POP	BC
	RET

;=================================================

FILENAME:	DB	0
ROOTNAME:	DB	"/",0

FIREWALL:	DS	2

IS_CALLBACK:	DS	01H

INFO_BUF:	DS	10H

INFO_SW:	DS      01H

FATENT:		DS	20H

FILE_BFFR:	DS	80H
FILE_SIZE:	DS	02H
BFFR_POS:	DB	0
BFFR_BLOCK:	DB	0

ARG0:		DS	02H
ARG1:		DS	02H
ARG2:		DS	02H
ARG3:		DS	02H
ARGNUM:		DS	01H

DNAME:		DS	01H
DIR_ENTRY:	DS	20H

NG_CHR:		DB	";" , "[" , "]" , ":" , DQUOTE	;エントリ名に使用できない文字
		DB	";" , "|" , "=" , "," , "\"	;
		DB	" " , "/"			;
NG_END		EQU	$				;

