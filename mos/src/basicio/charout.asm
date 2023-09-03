; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		charout.asm
;		Purpose:	Write character / control to device
;		Created:	25th May 2023
;		Reviewed: 	5th July 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;								Write character A to screen
;
; ************************************************************************************************

OSWriteScreen:
		pha 								; save AXY
		phx
		phy
		cmp		#$7F 						; handle delete
		beq 	_OSBackspace
		cmp 	#32 						; standard character $20,$FF (we allow for cyrillic possibility here)
		bcs 	_OSWriteDirect 
		;
		asl 	a 							; make to an offset in vector table
		tax
		lsr 	a
		jsr 	_OSCallVectorCode 			; call that code
		bra 	_OSWriteDeviceExit 			; and leave
		;
_OSWriteDirect:
		jsr 	OSDWritePhysical 			; $20-$FF write to screen
		jsr 	_OSCursorAdvance 			; and forwards.
_OSWriteDeviceExit:		
		ply
		plx
		pla
		clc 								; written fine.
		rts

_OSCallVectorCode: 							; no jsr ($xxxx,X)
		jmp 	(_OSWDVector,x) 			

_OSWNoFunction: 							; dummy.
		rts

_OSWDVector:
		.word 	_OSWNoFunction 				; $00 	No operation
		.word 	_OSWNoFunction 				; $01
		.word 	_OSWNoFunction 				; $02
		.word 	_OSWNoFunction 				; $03
		.word 	_OSWNoFunction 				; $04
		.word 	_OSWNoFunction 				; $05
		.word 	_OSWNoFunction 				; $06
		.word 	_OSWNoFunction 				; $07
		.word 	_OSCursorLeft 				; $08 	Left 		(Ctrl-H)
		.word 	_OSWHTab 					; $09	Tab 		(Tab stop)
		.word 	_OSCursorDown 				; $0A 	Down 		(Ctrl-J)
		.word 	_OSCursorUp 				; $0B	Up 			(Ctrl-K)
		.word 	_OSClearScreen 				; $0C	ClearScreen	(Ctrl-L)
		.word 	_OSNewLine 					; $0D 	CarriageRet (Enter)
		.word 	OSHomeCursor 				; $0E   Home Cursor (Ctrl-N)
		.word 	_OSWNoFunction 				; $0F
		.word 	_OSWNoFunction 				; $10
		.word 	_OSWNoFunction 				; $11
		.word 	_OSWNoFunction 				; $12
		.word 	_OSWNoFunction 				; $13
		.word 	_OSWNoFunction 				; $14
		.word 	_OSCursorRight 				; $15 	Right 		(Ctrl-U)
		.word 	_OSWNoFunction 				; $16
		.word 	_OSWNoFunction 				; $17
		.word 	_OSWNoFunction 				; $18
		.word 	_OSWNoFunction 				; $19
		.word 	_OSWNoFunction 				; $1A	Insert 		(Ctrl-Z)
		.word 	_OSWNoFunction 				; $1B 	Break/Esc 	(Esc)
		.word 	_OSWNoFunction 				; $1C
		.word 	_OSWNoFunction 				; $1D
		.word 	_OSWNoFunction 				; $1E
		.word 	_OSWNoFunction 				; $1F


; ************************************************************************************************
;
;								Cursor movement functionality
;
; ************************************************************************************************
;
;		Right to next TAB
;
_OSWHTab:									; move right.
		lda 	OSXPos
		clc
		adc 	#8
		and 	#$F8
		sta 	OSXPos
		cmp 	OSXSize 					; off rhs
		bcc 	_OSWHTExit
		stz 	OSXPos
		bra 	_OSCursorDown
_OSWHTExit:		
		rts
;
;		Backspace (e.g. back one and erase)
;
_OSBackspace:
		lda 	OSXPos 						; left side already ?
		beq 	_OSCLExit
		dec 	OSXPos 						; go left one.
		lda 	#' ' 						; ovewrite the character there.
		jsr 	OSDWritePhysical
		rts
;
;		Cursor left
;
_OSCursorLeft:
		lda 	OSXPos 						; left side
		dec 	OSXPos 						; cursor left		
		cmp 	#0 							; if at left side
		bne 	_OSCLExit 					; no, exit
		lda 	OSXSize 					; yes, shift to right.
		dec 	a
		sta 	OSXPos
_OSCLExit:
		rts
;
;		Cursor right 
;
_OSCursorRight:
		inc 	OSXPos 						; go right ?
		lda 	OSXPos 						; reached right side ?
		cmp 	OSXSize
		bne 	_OSCLExit 					; no, then exit
		stz 	OSXPos 						; back to left
		rts
;
;		Cursor down
;	
_OSCursorDown:
		inc 	OSYPos 						; down one line.
		lda 	OSYPos 						; reached bottom
		cmp 	OSYSize
		bcc 	_OSCDExit 					; no, we're done.
		stz 	OSYPos 						; position back to top line
_OSCDExit:
		rts
;
;		Cursor up
;
_OSCursorUp:
		dec 	OSYPos 						; up one line ?
		bpl 	_OSCUExit 					; exit if still on screen
		lda 	OSYSize 					; back to top
		dec 	a
		sta 	OSYPos 		
_OSCUExit:		
		rts
;
;		Cursor forward on screen, goes down at EOL and possibly scrolls.
;		
_OSCursorAdvance:
		inc 	OSXPos 						; try moving right
		lda 	OSXPos						; reached the write.
		cmp 	OSXSize
		bne 	_OSLCExit 	 				; exit if not at the RHS.
		ldx 	#0 							; character flag, reached here not via CR.
;
;		Carriage return, start of next line.
;		
_OSNewLine:		
		phx 								; save CR/char flag.

		stz 	OSXPos 						; left side
		inc 	OSYPos 						; down one.
		lda 	OSYPos 						; reached the bottom
		cmp 	OSYSize
		bcc 	_OSLCUpdateCR				; no, update CR flag and exit
		lda 	OSYSize 					; bottom of screen
		dec 	a
		sta 	OSYPos 						; back up one line
		jsr 	OSDScrollUp 				; scroll the whole screen up.
		ldx 	#0 							; scroll the CR flag table up 
_OSNLScrollFlag:
		lda 	OSNewLineFlag+1,x		
		sta 	OSNewLineFlag,x	
		inx
		cpx 	OSYSize
		bne	 	_OSNLScrollFlag
_OSLCUpdateCR:		
		ldx 	OSYPos 						; set appropriate flag in CR/multi line table.
		pla
		sta 	OSNewLineFlag,x
_OSLCExit:		
		rts		
;
;		Clear Screen.
;		
_OSClearScreen:
		jsr 	OSDClearScreen 				; physical clear.
		ldx 	OSYSize 					; set all the CR flags on each row
_OSCSSetLoop:
		lda 	#$FF
		sta 	OSNewLineFlag-1,x
		dex
		bne		_OSCSSetLoop
		jsr 	OSHomeCursor 				; cursor to (0,0)
		rts		
;
;		Home position.
;
OSHomeCursor: 								; home cursor.
		stz 	OSXPos
		stz	 	OSYPos
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
;		05/07/23 		Home cursor out of the physical clear code, into CLS code.
;		09/07/23 		TAB bug (not going down a line when TAB off right)
;
; ************************************************************************************************
