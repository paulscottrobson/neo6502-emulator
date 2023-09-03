; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		testing.asmx
;		Purpose:	Testing code (usually disabled)
;		Created:	5th June 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code
		
KeyEcho:
		jsr 	OSReadKeystroke
		jsr 	OSWriteScreen
		jsr 	OSTWriteHex
		lda 	#' '
		jsr 	OSWriteScreen
		bra 	KeyEcho
		
OSTWriteHex:
		pha
		lsr 	a
		lsr 	a
		lsr 	a
		lsr 	a
		jsr 	_OSTWriteNibble		
		pla
_OSTWriteNibble:
		pha
		and 	#15
		cmp 	#10
		bcc 	_OSTNotAlpha
		adc 	#6
_OSTNotAlpha:
		adc 	#48
		jsr 	OSWriteScreen
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

