; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		ramdata.inc
;		Purpose:	Common setup program, allocate non zero page RAM for MOS/FsLib
;		Created:	25th May 2023
;		Reviewed: 	25th June 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

StorageBase = $200 							; ROM usage

		* = StorageBase

; ************************************************************************************************
;
;									Non Zero Page usage
;
; ************************************************************************************************

OSNewLineFlag: 								; set if new line started on this line
		.fill 	32		
OSCurrentMode:								; current screen mode.
		.fill 	1
OSXPos:	 									; cursor position
		.fill 	1
OSYPos:	
		.fill 	1		
OSXSize:									; screen size
		.fill 	1
OSYSize:
		.fill 	1		

OSXPosSave:									; saved position for screen editor
		.fill 	1
OSYPosSave:
		.fill 	1
OSYFrameTop:								; top and line after frame.
		.fill 	1
OSYFrameBottom:						
		.fill 	1

OSKeyboardQueueMaxSize = 16					; keyboard queue max size.

OSKeyboardStart:
OSKeyboardQueue:							; keyboard queue
		.fill 	OSKeyboardQueueMaxSize		
OSKeyboardQueueSize:						; entries in keyboard queue
		.fill 	1		
OSEscapePressed: 							; non zero if escape pressed.
		.fill 	1
OSKeyboardEnd:

OSRKOriginal: 								; character under cursor (for keystroke)
		.fill 	1

OSXEdit: 									; position of start of edit area
		.fill 	1			
OSYEdit:
		.fill 	1		
OSEditPos: 									; current cursor position in string.
		.fill 	1			
OSEditScroll: 								; offset in characters of the left most character.
		.fill 	1	

OSTextBufferSize = 192

OSEditWidth: 								; max width in characters of edit area.
		.fill 	1	
OSEditLength: 								; number of characters on line
		.fill 	1
OSEditBuffer: 								; text buffer.
		.fill 	OSTextBufferSize+1

		.fill 	32

		.dsection storage

; ************************************************************************************************
;
;											WWFS Usage
;
; ************************************************************************************************

sectorCount:								; sector count bytes, read at initialise.
		.fill 	2
currentSector: 								; current sector.
		.fill 	2		
successFlag: 								; general success flag.
		.fill 	1

sectorHeader: 								; header
shFirstNext: 								; (F)irst (N)ext (I)nformation or free
		.fill 	1
shContinue:									; (Y)es (N)o (more of this file)		
		.fill 	1
shDataSize:									; bytes of data in this sector		
		.fill 	2
shFileSize:									; size of file.		
		.fill 	2
		.fill 	10
shNameLength:								; # characters in name.		
		.fill 	1
shNameText:									; file name (lower case)	
		.fill 	15
shFileSizeCopy: 							; file size (duplicate for directory)
		.fill 	2
		
notFirstSector: 							; first sector flag
		.fill 	1		
fileRemainingSize: 							; remaining size of file.
		.fill 	2		
checkLoopRound: 							; gone round too many times.
		.fill 	1
FSRandomSeed: 								; seed for start position.
		.fill 	1		
		
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

