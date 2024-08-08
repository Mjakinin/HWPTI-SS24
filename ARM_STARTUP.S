.text
.align 2 @ausrichten an Wortgrenzen
.extern main
_start : .global _start
b _prog @Sprung ueber Exceptionvektoren
movs pc, r14
movs pc, r14
subs pc, r14, #4
subs pc, r14, #8
nop
subs pc, r14, #4
subs pc, r14, #4
_prog : b main @Sprung in das gelinkte Programm
	b _start @Sprung nach _start
.end
