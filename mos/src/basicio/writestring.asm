; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		writestring.asm
;		Purpose:	Write string 
;		Created:	6th June 2023
;		Reviewed: 	26th June 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;								Write len prefixed YX string to screen
;
; ************************************************************************************************

OSWriteString:
		pha 								; save AXY
		phx
		phy
		stx		rTemp1 						; address of string in rTemp1
		sty 	rTemp1+1
		lda 	(rTemp1)
		tax 								; count in X
		ldy 	#0
OSWSLoop:
		cpx 	#0 							; done them all, exit
		beq 	_OSWSExit

		dex 								; dec count
		iny 								; get next character
		lda 	(rTemp1),y
		beq 	_OSWSExit 					; end if $00
		jsr 	OSWriteScreen				; otherwise write to screen.
		bra 	OSWSLoop
_OSWSExit:
		ply 								; restore AXY and exit
		plx
		pla
		rts		

		.send code
		
; ************************************************************************************************
;
;									Changes and Updates
;
; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;
; ************************************************************************************************

