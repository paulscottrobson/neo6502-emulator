; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		scroll.asm
;		Purpose:	Scroll screen up
;		Created:	13th July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;								Scroll screen up (off the bottom)
;
; ************************************************************************************************

OSDScrollUp:
		ldy 	#0 							; done a line at a time because it is odd :)
		lda 	#$04 						; start of screen
		sta 	rTemp0+1
		stz 	rTemp0
		ldx 	OSYSize 					; X = lines to scroll.
		dex
_OSDNextLine:		
		ldy 	OSXSize						; Y = line count
		dey
_OSDMainLoop:	
		phy
		ldy 	OSXSize
		lda 	(rTemp0),y
		sta 	(rTemp0)
		inc 	rTemp0
		bne 	_OSDNoCarry
		inc 	rTemp0+1
_OSDNoCarry:
		ply
		dey 	
		bpl		_OSDMainLoop
		dex
		bne 	_OSDNextLine

		ldy 	OSXSize
		dey
_OSDSClear:
		lda 	#$20
		sta 	(rTemp0),y
		dey
		bpl 	_OSDSClear		
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

