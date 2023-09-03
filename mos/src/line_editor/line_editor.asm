; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		line_editor.asm
;		Purpose:	Line editor
;		Created:	5th June 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;					  Basic line entry, effectively ignores up and down
;
; ************************************************************************************************

OSEnterLine:
		jsr 	OSEditNewLine
		bra 	_OSELProcess
_OSELRestart:
		jsr 	OSReEnterLine		
_OSELProcess:		
		cmp	 	#10
		beq 	_OSELRestart
		cmp 	#11
		beq 	_OSELRestart
		rts

; ************************************************************************************************
;
;						Edit line from current position / preset width.
;
; ************************************************************************************************

OSEditNewLine:
		stz 	OSEditLength 				; clear buffer
OSEditLine:
		;
		;		Set everything up
		;
		lda 	OSXPos 						; save edit point.
		sta 	OSXEdit
		lda 	OSYPos
		sta 	OSYEdit

		lda 	OSEditLength 				; edit point at end of line.
		sta 	OSEditPos
		stz 	OSEditScroll 				; no initial scrolling

		sec 								; calculate edit box width.
		lda 	OSXSize
		sbc 	OSXPos
		dec 	a 							; one forr RHS
		sta 	OSEditWidth
		;
		;		Come here to continue
		;
OSReEnterLine:
		;
		;		Come here to force redraw, and re-enter.
		;	
_OSForceUpdate:
		sec 								; force repaint.
		jsr 	OSEUpdatePosition 			; update the position.
_OSEditLoop:		
		;
		;		Get keystroke, handle up/down/esc/CR.
		;
		jsr 	OSEPositionCursor
		jsr 	OSReadKeystroke 			; get one key.
		;
		cmp 	#10 						; down, up, esc, CR all exit
		beq 	_OSEditExit
		cmp 	#11
		beq 	_OSEditExit
		cmp 	#13
		beq 	_OSEditExit
		cmp 	#27
		bne 	_OSEditContinue
_OSEditExit:
		ldx 	OSEditLength 				; make it ASCIIZ as well (!)
		stz 	OSEditBuffer,x
		ldx 	#OSEditLength & $FF 		; XY = Buffer
		ldy 	#OSEditLength >> 8
		rts
		;
		;		Action keys.
		;
_OSEditContinue:
		cmp 	#8 							; left (Ctrl-H)
		beq 	_OSELeft
		cmp 	#14 						; home (Ctrl-N)
		beq 	_OSEHome
		cmp 	#21 						; right (Ctrl-U)
		beq 	_OSERight
		cmp 	#$7F 						; backspace (<-)
		beq 	_OSEBackspace
		cmp 	#9 							; tab (9)
		beq 	_OSETab
		cmp 	#32 						; character code, insert it
		bcc 	_OSEditLoop
		;
		;		Insert a character, move right
		;
_OSAddCharacter:		
		ldx 	OSEditLength 				; already full ?
		cpx 	#OSTextBufferSize
		beq 	_OSCheckUpdate
		jsr 	_OSEInsertCharacter 		; insert character at pos
		inc 	OSEditPos 					; advance forward
		bra 	_OSForceUpdate 				; force a repaint.
		;
		;		Home cursor
		;
_OSEHome:
		stz 	OSEditPos
		stz 	OSEditScroll
		bra 	_OSForceUpdate		
		;
		;		Delete character
		;		
_OSEBackspace:
		lda 	OSEditPos 					; can't backspace from the start.
		beq 	_OSCheckUpdate
		dec 	OSEditPos
		lda 	OSEditLength 				; not if at far right, e.g. appending to end.
		cmp 	OSEditPos
		beq 	_OSCheckUpdate		
		jsr 	_OSEDeleteCharacter 		; delete character and repaint.
		bra 	_OSForceUpdate
		;
		;		Move right, if possible
		;
_OSERight:
		lda 	OSEditPos 					; if x before end then go right
		cmp 	OSEditLength
		beq 	_OSCheckUpdate		
		inc 	OSEditPos
		bra 	_OSCheckUpdate
		;
		;		Move left if possible
		;	
_OSELeft:
		lda 	OSEditPos 					; if x past start go left
		beq 	_OSCheckUpdate
		dec 	OSEditPos		
		;
		;		Come here to check if update needed and loop back.
		;
_OSCheckUpdate:		
		clc
		jsr 	OSEUpdatePosition
		jmp 	_OSEditLoop
		;
		;		TAB position
		;	
_OSETab:
		clc
		lda 	OSEditPos
		adc 	#8
		cmp 	OSEditLength
		bcc 	_OSTabOk
		lda 	OSEditLength
_OSTabOk:
		sta 	OSEditPos
		bra 	_OSCheckUpdate

; ************************************************************************************************
;
;								Insert character at cursor position
;
; ************************************************************************************************

_OSEInsertCharacter:
		pha 								; save character
		ldx 	OSEditLength
		inx
_OSMakeSpace:
		dex
		lda 	OSEditBuffer,x
		sta 	OSEditBuffer+1,x
		cpx 	OSEditPos
		bne 	_OSMakeSpace		
		pla
		sta 	OSEditBuffer,x
		inc 	OSEditLength
		rts

; ************************************************************************************************
;
;								Delete character at cursor position
;
; ************************************************************************************************

_OSEDeleteCharacter:
		ldx 	OSEditPos
_OSERemove:
		lda 	OSEditBuffer+1,x
		sta 	OSEditBuffer,x
		inx
		cpx 	OSEditLength
		bcc 	_OSERemove
		dec 	OSEditLength
		rts		

; ************************************************************************************************
;
;			Update the scrolling position. Repaint on this changing or CS on entry
;
; ************************************************************************************************

OSEUpdatePosition:
		php 								; save repaint flag.
		lda 	OSEditScroll 				; save old edit scroll position.
		pha
		jsr 	OSECheckPosition 			; check position in range of text
		jsr 	OSECheckVisible 			; is it on screen ?

		pla 								; has the edit scroll position changed ?
		cmp 	OSEditScroll 				
		beq 	_OSECVNoChange
		plp 								; if so, set repaint flag
		sec
		php
_OSECVNoChange:
		plp	 								; do we need a repaint.
		bcc 	_OSECVNoRepaint
		jsr 	OSERepaint
_OSECVNoRepaint:				
		rts		

; ************************************************************************************************
;
;					Check position actually in the range of the string
;
; ************************************************************************************************

OSECheckPosition:
		lda 	OSEditPos 					; if position = 255 (e.g. -1) then off left.
		cmp 	#255
		bne 	_OSECPNotLeft
		stz 	OSEditPos 
		rts
_OSECPNotLeft:
		cmp 	OSEditLength 				; if >= edit length reset to edit length
		bne 	_OSEPCNotRight
		lda 	OSEditLength
		sta 	OSEditPos
_OSEPCNotRight:		
		rts

; ************************************************************************************************
;
;							Check actually visible on the screen
;
; ************************************************************************************************

OSECheckVisible:
		lda 	OSEditPos 					; if editpos < editscroll
		cmp 	OSEditScroll
		bcs 	_OSENotOffLeft
		sta 	OSEditScroll 				; then scroll at that position.
		rts

_OSENotOffLeft:								; if editpos - editscroll >= editwidth off screen right
		sec
		lda 	OSEditPos
		sbc 	OSEditScroll
		cmp 	OSEditWidth
		bcs 	_OSEOffRight
		rts
		;
		;		Scroll pos is off screen to right - scroll position = textpos-textwidth, limited to zero.
		;
_OSEOffRight:
		sec
		lda 	OSEditPos
		sbc 	OSEditWidth
		bcs 	_OSENoTrim
		lda 	#0
_OSENoTrim:
		sta 	OSEditScroll		
		rts

; ************************************************************************************************
;
;							Repaint according to current settings.
;
; ************************************************************************************************

OSERepaint:	
		lda 	OSXEdit 					; reset drawing pos
		sta 	OSXPos
		lda 	OSYEdit
		sta 	OSYPos
		;
		ldx 	OSEditScroll 				; start data from here.
		ldy 	OSEditWidth 				; counter
_OSERepaintLoop:
		lda 	OSEditBuffer,x 				; read character from buffer
		cpx 	OSEditLength 				; past end of buffer
		bcc 	_OSEOut
		lda 	#" "		
_OSEOut:phx 								; output character.
		phy
		jsr 	OSDWritePhysical
		ply
		plx
		inc 	OSXPos 						; next screen pos
		inx									; next char
		dey 								; one fewer to do.
		bne 	_OSERepaintLoop
		rts

; ************************************************************************************************
;
;								Position cursor ready for entry
;
; ************************************************************************************************

OSEPositionCursor:
		sec
		lda 	OSEditPos
		sbc 	OSEditScroll
		clc
		adc 	OSXEdit
		sta 	OSXPos
		lda 	OSYEdit
		sta 	OSYPos
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

