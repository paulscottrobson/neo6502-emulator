; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		a2keyboard.asm
;		Purpose:	Apple ][ Keyboard driver
;		Created:	13th July 2023
;		Reviewed: 	No.
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;								Process keyboard input queue
;
; ************************************************************************************************

OSKeyboardDataProcess:
		lda 	$C000 						; keystroke available ?
		bpl 	_OSKExit
		and 	#$7F 						; make 7 bit ASCII.
		jsr 	OSDInsertKeyboardQueue 		; insert into keyboard queue.
		lda 	$C010 						; clear strobe.
_OSKExit:		
;		lda 	OSKeyStatus+$0E 			; and on the way out check if ESC was pressed.
;		and 	#$40
;		sta 	OSEscapePressed
		rts

; ************************************************************************************************
;
;								  Insert in Keyboard Queue
;
; ************************************************************************************************

OSDInsertKeyboardQueue:		
		ldx 	OSKeyboardQueueSize 		; check to see if full
		cpx	 	#OSKeyboardQueueMaxSize
		bcs 	_OSIKQExit 					; if so, you will never know.

		sta 	OSKeyboardQueue,x 			; add keyboard entry to queue.
		inc 	OSKeyboardQueueSize
_OSIKQExit:		
		rts

; ************************************************************************************************
;
;									Reset keyboard system
;
; ************************************************************************************************
		
OSDKeyboardInitialise:
		ldx 	#OSKeyboardEnd-OSKeyboardStart
_OSKILoop:
		stz 	OSKeyboardStart,x
		dex
		bpl 	_OSKILoop
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
;		26/06/23 		Cleared iskeyup/shift flags on OSKeyboardInitialise
;
; ************************************************************************************************

