; TEXT
segment	.text
; ALIGN
align	4
; GLOBAL _main, :function
global	_main:function
; LABEL _main
_main:
; ENTER 4
	push	ebp
	mov	ebp, esp
	sub	esp, 4
; INT 0
	push	dword 0
; LOCAL -4
	lea	eax, [ebp+-4]
	push	eax
; STINT
	pop	ecx
	pop	eax
	mov	[ecx], eax
        ;; before function PBE 
        ;; before body 
; INT 15
	push	dword 15
; CALL printi
	call	printi
; TRASH 4
	add	esp, 4
; RODATA
segment	.rodata
; ALIGN
align	4
; LABEL _L2
_L2:
; SSTRING (value omitted -- see below)
	db	"A", 0
; TEXT
segment	.text
; ALIGN
align	4
; ADDR _L2
	push	dword $_L2
; CALL prints
	call	prints
; TRASH 4
	add	esp, 4
; CALL println
	call	println
        ;; after body 
; LABEL _L1
_L1:
        ;; after function PBE 
; LOCAL -4
	lea	eax, [ebp+-4]
	push	eax
; LDINT
	pop	eax
	push	dword [eax]
; STFVAL32
	pop	eax
; LEAVE
	leave
; RET
	ret
; EXTERN printi
extern	printi
; EXTERN println
extern	println
; EXTERN prints
extern	prints