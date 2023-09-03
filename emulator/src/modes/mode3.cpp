// *******************************************************************************************************************************
// *******************************************************************************************************************************
//
//		Name:		mode3.c
//		Purpose:	Display mode (Neo6502 48x32 format)
//		Created:	22nd July 2023
//		Author:		Paul Robson (paul@robsons->org.uk)
//
// *******************************************************************************************************************************
// *******************************************************************************************************************************

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "gfx.h"
#include "sys_processor.h"
#include "sys_debug_system.h"
#include "debugger.h"
#include "hardware.h"
#include "modes.h"

// *******************************************************************************************************************************
//											Write character
// *******************************************************************************************************************************

static void mode3Write(int address,int ch) {
	mode0WriteChar((address % 48)*6+16,(address / 48)*8,ch & 0x7F,(ch & 0x80) != 0);
}

// *******************************************************************************************************************************
//											This renders the debug screen
// *******************************************************************************************************************************

int mode3Handler(int cmd,int address,int data) {
	int retVal = 0;
	switch (cmd) {
		case 0: 							// Write to screen.
			mode3Write(address-0x400,data & 0xFF);
			break;
		case 1: 							// Initialise mode.
			break;
		case 2: 							// Get address low
			retVal = 0x400;
			break;
		case 3: 							// Get address high.
			retVal = 0x99F; 
			break;
	}
	return retVal;
}
