all:	CHIO.wav

CHIO.wav: CHIO.asm IPL.asm CMD.asm DIR.asm FS.asm CMT.asm CHFP.asm SUBS.asm MESSAGES.asm DEBUG.asm TP.asm LABELS.inc N80.inc
	zmac --rel CHIO.asm
	zmac --rel IPL.asm
	zmac --rel CMD.asm
	zmac --rel DIR.asm
	zmac --rel FS.asm
	zmac --rel CMT.asm
	zmac --rel CHFP.asm
	zmac --rel SUBS.asm
	zmac --rel MESSAGES.asm
	zmac --rel TP.asm
	zmac --rel DEBUG.asm
	ld80 -P 6000 -o zout/CHIO.hex zout/CHIO.rel zout/IPL.rel zout/CMD.rel zout/DIR.rel zout/FS.rel zout/CMT.rel zout/CHFP.rel zout/SUBS.rel zout/MESSAGES.rel zout/TP.rel zout/DEBUG.rel
	ihex2monl -i zout/CHIO.hex CHIO.wav

clean:
	rm -rf *.wav zout
