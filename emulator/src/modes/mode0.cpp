// *******************************************************************************************************************************
// *******************************************************************************************************************************
//
//		Name:		mode0.c
//		Purpose:	Display mode (Apple 40x24 format)
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

#include "font5x7.h"

static int lineAddresses[24] = {
	0x400,0x480,0x500,0x580,0x600,0x680,0x700,0x780,
	0x428,0x4A8,0x528,0x5A8,0x628,0x6A8,0x728,0x7A8,
	0x450,0x4D0,0x550,0x5D0,0x650,0x6D0,0x750,0x7D0
};

// *******************************************************************************************************************************
//										Write 5x7 on the screen
// *******************************************************************************************************************************

void mode0WriteChar(int x,int y,char c,int reverse) {
	if (c < 32 || c >= 128) return;
	reverse = (reverse == 0) ? 0 : 0xFF;
	for (int yc = 0;yc < 7;yc++) {		
		BYTE8 pixel = font5x7[(c-32)*8+yc];
		BYTE8 *pos = DBGXGetVideoRAM() + x + (y+yc) * 320;
		for (int xc = 0;xc < 6;xc++) {
			*pos++ = (pixel & 0x80) ? 0xFF^reverse:reverse;
			pixel <<= 1;
		}
	}
}

// *******************************************************************************************************************************
//											Write character
// *******************************************************************************************************************************

static void mode0Write(int address,int ch) {
	for (int y = 0;y < 24;y++) {
		if (address >= lineAddresses[y] and address < lineAddresses[y]+40) {
			mode0WriteChar((address-lineAddresses[y])*7+20,y*8+24,((ch & 0x3F)^0x20)+32,(ch & 0x80) == 0);
		}
	}
}

// *******************************************************************************************************************************
//											This renders the debug screen
// *******************************************************************************************************************************

int mode0Handler(int cmd,int address,int data) {
	int retVal = 0;
	switch (cmd) {
		case 0: 							// Write to screen.
			mode0Write((address & 0x3FF)+0x400,data & 0xFF);
			break;
		case 1: 							// Initialise mode.
			break;
		case 2: 							// Get address low
			retVal = 0x400;
			break;
		case 3: 							// Get address high.
			retVal = 0x7FF; 
			break;
	}
	return retVal;
}
