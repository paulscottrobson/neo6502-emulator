; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		screeneditor.asm
;		Purpose:	Screen editor
;		Created:	29th June 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									Screen line into buffer
;
; ************************************************************************************************

OSScreenLine:
		stz 	OSEditLength 				; clear buffer
_OSScreenLoop:		
		jsr 	OSReadKeystroke	 			; get key.
		cmp 	#$1A						; insert
		beq 	_OSSInsert
		cmp 	#$7F
		beq 	_OSSBackspace
		cmp 	#$0D 						; Return key ?
		beq 	_OSSReturn
		jsr 	OSWriteScreen
		bra 	_OSScreenLoop
		;
		;		Handle backspace
		;
_OSSBackspace:
		lda 	OSXPos 						; backspace blocked if first character on line
		bne 	_OSSBackspaceOk
		ldx 	OSYPos 						; and its the start of a group.
		lda 	OSNewLineFlag,x
		bne 	_OSScreenLoop
_OSSBackspaceOk:
		jsr 	OSSLeft 					; move left.
		;
		;		Handle Delete
		;
_OSSDelete:
		jsr 	OSSSaveGetFrame 			; save current position and get frame.
_OSSDeleteLoop:
		lda 	OSYFrameBottom 				; reached the end
		cmp 	OSYPos
		bcc 	_OSSDelComplete
		;
		jsr 	OSSRight 					; shuffle everything
		jsr 	OSDReadPhysical
		jsr 	OSSLeft
		jsr 	OSDWritePhysical
		jsr 	OSSRight
		bra 	_OSSDeleteLoop
_OSSDelComplete:
		jsr 	OSSLeft 					; blank last character
_OSSWriteSpace:		
		lda 	#' ' 						; write space at posiition
		jsr 	OSDWritePhysical
		jsr 	OSSLoadPosition 			; restore original pos and loop back.
		bra		_OSScreenLoop
		;
		;		Handle Insert
		;
_OSSInsert:
		jsr 	OSSSaveGetFrame 			; save current position and get frame.
		lda 	OSXSize 					; start insert copy is end
		dec 	a
		sta 	OSXPos
		lda 	OSYFrameBottom
		sta 	OSYPos
_OSSInsertLoop:
		lda 	OSXPos 						; reached insert point ?
		cmp 	OSXPosSave
		bne 	_OSSShiftUp
		lda 	OSYPos
		cmp 	OSYPosSave
		beq 	_OSSWriteSpace 				; space there and continue
_OSSShiftUp:		
		jsr 	OSSLeft
		jsr 	OSDReadPhysical
		jsr 	OSSRight
		jsr 	OSDWritePhysical
		jsr 	OSSLeft
		bra 	_OSSInsertLoop
		;
		;		Handle Return
		;
_OSSReturn:
		jsr 	OSSSaveGetFrame 			; save current position and get frame.
		stz 	OSXPos
		lda 	OSYFrameTop					; start position.
		sta 	OSYPos
_OSSRCopy:		
		lda 	OSYFrameBottom 				; reached the end
		cmp 	OSYPos
		bcc 	_OSSRCopied
		jsr 	OSDReadPhysical
		ldx 	OSEditLength
		sta 	OSEditBuffer,x
		inc 	OSEditLength
		jsr 	OSSRight
		bra 	_OSSRCopy
_OSSRCopied:
		jsr 	OSSLeft 					; do a CR from previous line, scroll if required.
		lda		#13
		jsr 	OSWriteScreen
		ldx 	OSEditLength 				; strip trailing spaces
_OSSSStripSpaces:		
		dex
		lda 	OSEditBuffer,x
		cmp 	#$20
		bne 	_OSSSSSEnd
		stz 	OSEditBuffer,x
		stx 	OSEditLength
		bra 	_OSSSStripSpaces
_OSSSSSEnd:		
		ldx 	#OSEditLength & $FF
		ldy 	#OSEditLength >> 8
		rts

; ************************************************************************************************
;
;										Reset position
;
; ************************************************************************************************

OSSLoadPosition:
		ldx 	OSXPosSave	
		stx 	OSXPos 		
		ldx 	OSYPosSave
		stx 	OSYPos
		rts

; ************************************************************************************************
;
;					Save position ; establish top and bottom of frame area
;
; ************************************************************************************************

OSSSaveGetFrame:
		ldx 	OSXPos 						; save current position
		stx 	OSXPosSave	
		ldx 	OSYPos
		stx 	OSYPosSave
		;
		;		Work out top line.
		;
_OSSSFindTop:
		cpx 	#0 							; top of screen
		beq 	_OSSSTFound
		lda 	OSNewLineFlag,x  			; start of frame.
		bne 	_OSSSTFound
		dex
		bra 	_OSSSFindTop
		;
_OSSSTFound:
		stx 	OSYFrameTop		
		;
		;		Get line after bottom.
		;
		ldx 	OSYPos
_OSSSFindBottom:
		txa
		inc 	a
		cmp 	OSYSize 					; bottom of screen
		beq 	_OSSSBFound
		lda 	OSNewLineFlag+1,x
		bne 	_OSSSBFound
		inx
		bra 	_OSSSFindBottom
		;
_OSSSBFound:
		stx 	OSYFrameBottom
		rts

; ************************************************************************************************
;
;											Move left
;
; ************************************************************************************************

OSSLeft:
		pha
		dec 	OSXPos
		bpl 	_OSSLExit
		dec 	OSYPos
		lda 	OSXSize
		dec 	a
		sta 	OSXPos
_OSSLExit:
		pla
		rts

; ************************************************************************************************
;
;											Move right
;
; ************************************************************************************************

OSSRight:
		pha
		inc 	OSXPos
		lda 	OSXPos
		cmp 	OSXSize
		bne 	_OSSRExit
		stz 	OSXPos
		inc 	OSYPos
_OSSRExit:
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

