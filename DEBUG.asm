;
;
;

	GLOBAL	DISP

DISP:
	PUSH	BC
	LD	C, A
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	CALL	DESP16
	LD	A, C
	AND	A, 0FH
	CALL	DESP16
	POP	BC
	RET

DESP16:
	CP	0AH
	JP	M, L1
	ADD	A, 'A' - 10
	RST	18H
	RET
L1:
	ADD	A, '0'
	RST	18H
	RET

