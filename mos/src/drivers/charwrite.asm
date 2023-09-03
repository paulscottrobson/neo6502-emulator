; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		charwrite.asm
;		Purpose:	Physical character write
;		Created:	25th May 2023
;		Reviewed: 	26th June 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;							Read char at current screen position
;
; ************************************************************************************************

OSDReadPhysical:
		jsr 	OSDGetAddress
		lda 	(rTemp0)
		rts

; ************************************************************************************************
;
;							Write char A at current screen position
;
; ************************************************************************************************

OSDWritePhysical:
		phx
		pha		
		jsr 	OSDGetAddress
		pla
		sta 	(rTemp0)
		plx		
		rts

; ************************************************************************************************
;
;							  Current/Specific cursor address in rTemp0
;
; ************************************************************************************************	

OSDGetAddress:
		ldx 	OSXPos
		ldy 	OSYPos
OSDGetAddressXY:
		tya 			 					; RTemp0+1:A x 8
		stz 	rTemp0+1
		;
		asl 	a 							; max 60 x 2
		asl 	a  							; max 120 x 4
		asl 	a 							; max 240 x 8
		;
		asl 	a 							; times 16 now
		rol 	rTemp0+1 					; YA = rTemp0 = Y * 16
		sta 	rTemp0
		ldy 	rTemp0+1
		;
		asl 	rTemp0 						; rTemp0 = Y * 32
		rol 	rTemp0+1
		;
		clc 								; rTemp0 = Y * 48 + $400
		adc 	rTemp0
		sta 	rTemp0
		tya
		adc 	rTemp0+1
		adc 	#$04
		sta 	rTemp0+1

		clc 	 							; add X to rTemp0+1
		txa
		adc 	rTemp0
		sta 	rTemp0
		bcc 	_OSDGAExit
		inc 	rTemp0+1
_OSDGAExit:		
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

