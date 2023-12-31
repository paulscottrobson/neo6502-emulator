; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		clear.asm
;		Purpose:	Clear screen
;		Created:	13th July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;										  Clear Screen
;
; ************************************************************************************************

OSDClearScreen:	
		lda 	#$04 						; clear memory $0400-$09FF
		sta 	rTemp0+1
		stz 	rTemp0
_OSCSLoop1:		
		lda 	#$20
		sta 	(rTemp0)
		inc 	rTemp0
		bne 	_OSCSNoCarry
		inc 	rTemp0+1
_OSCSNoCarry:		
		lda 	rTemp0+1
		cmp	 	#$0A
		bne 	_OSCSLoop1 	
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
;		05/07/23 		Home cursor out of the physical clear code.
;
; ************************************************************************************************

