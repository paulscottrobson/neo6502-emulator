; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		ramdata.inc
;		Purpose:	Common setup program, allocate RAM for MOS.
;					This file is copied about so other apps know where their RAM can start.
;		Created:	25th May 2023
;		Reviewed: 	25th June 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

ZeroPageBase = $08 							; zero page usage

; ************************************************************************************************
;
;									Zero Page usage
;
; ************************************************************************************************

		* = ZeroPageBase
IFR0:	 									; work registers
		.fill 	4
IFR1:	
		.fill 	4
IFR2:	
		.fill 	4
IFRTemp:
		.fill 	4
codePtr: 									; it's more readable if these don't move.
		.fill 	4

rTemp0: 									; temporary register for OS, zero page
		.fill 	2
rTemp1:
		.fill 	2		
iTemp0:										; temporary register for maths library, zero page.
		.fill 	2

fsBlock:	 								; pointer to fs block
		.fill 	2		

		.dsection zeropage

debug 	.macro
		.byte 	$DB
		.endm
		
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

