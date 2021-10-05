all:	CHIO.wav

CHIO.wav: CHIO.asm CMD.asm DIR.asm CD.asm FS.asm CMT.asm CHFP.asm SUBS.asm MESSAGES.asm DEBUG.asm TP.asm STR.asm LABELS.inc N80.inc
	zmac --rel CHIO.asm
	zmac --rel CMD.asm
	zmac --rel DIR.asm
	zmac --rel CD.asm
	zmac --rel FS.asm
	zmac --rel CMT.asm
	zmac --rel CHFP.asm
	zmac --rel SUBS.asm
	zmac --rel MESSAGES.asm
	zmac --rel TP.asm
	zmac --rel STR.asm
	zmac --rel DEBUG.asm
	ld80 -P 6000 -o zout/CHIO.hex zout/CHIO.rel zout/CMD.rel zout/DIR.rel zout/CD.rel zout/FS.rel zout/CMT.rel zout/CHFP.rel zout/SUBS.rel zout/MESSAGES.rel zout/TP.rel zout/STR.rel zout/DEBUG.rel
	ihex2monl -i zout/CHIO.hex CHIO.wav

clean:
	rm -rf *.wav zout
