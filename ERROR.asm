;
;
;

	INCLUDE "N80.inc"
	INCLUDE "LABELS.inc"

	GLOBAL	ERR_NOT_FOUND
	GLOBAL	ERR_EMPTY_FILE

	EXTERN	MSG_NOT_FOUND
	EXTERN	MSG_EMPTY_FILE
	EXTERN	ERR

;
;=================================================
;[ERROR]指定されたエントリ名が見つからない
;=================================================
ERR_NOT_FOUND:	
	LD	HL,MSG_NOT_FOUND		;
	JP	ERR				;

;=================================================
;[ERROR]ファイルがカラ
;=================================================
ERR_EMPTY_FILE:
	LD	HL,MSG_EMPTY_FILE		;
	JP	ERR				;

;;=================================================
;;[ERROR]エントリがすでに存在する
;;=================================================
;ERR_EXISTS:
;	LD	HL,MSG_EXISTS			;
;	JP	ERR				;
