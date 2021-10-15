;
;
;

	GLOBAL	FETCH_1BYTE
	GLOBAL	POST_1BYTE
	GLOBAL	FLUSH_BFFR

	EXTERN	READ_FP_SCTR
	EXTERN	FILE_BFFR
	EXTERN	CH_WRITE

	EXTERN	BFFR_POS
	EXTERN	BFFR_BLOCK

FETCH_1BYTE:
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	A, (BFFR_POS)
	LD	DE, FILE_BFFR
	LD	HL, 0
	LD	L, A
	ADD	HL, DE
	LD	B, (HL)
	INC	A
	JM	.L1		; Buffer size is 0x80
	LD	(BFFR_POS), A
	LD	A, B
	POP	HL
	POP	DE
	POP	BC
	RET

.L1:
	XOR	A		; Reset to buffer postion
	LD	(BFFR_POS), A
	LD	A, (BFFR_BLOCK)
	INC	A
	LD	(BFFR_BLOCK), A
	PUSH	BC
	CALL	READ_FP_SCTR	; Read next block to buffer
	POP	BC
	LD	A, B
	POP	HL
	POP	DE
	POP	BC
	RET

POST_1BYTE:
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	B, A
	LD	A, (BFFR_POS)
	LD	DE, FILE_BFFR
	LD	HL, 0
	LD	L, A
	ADD	HL, DE
	LD	(HL), B
	INC	A
	JM	.L2		; Buffer size is 0x80
	LD	(BFFR_POS), A
	POP	HL
	POP	DE
	POP	BC
	RET
.L2:
	CALL	CH_WRITE
	XOR	A
	LD	(BFFR_POS), A
	POP	HL
	POP	DE
	POP	BC
	RET

FLUSH_BFFR:
	LD	A, (BFFR_POS)
	AND	A,A
	JZ	.L3
	CALL	CH_WRITE
.L3:
	RET
