// *******************************************************************************************************************************
// *******************************************************************************************************************************
//
//		Name:		hardware.h
//		Purpose:	Hardware Emulation Header
//		Created:	10th May 2023
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// *******************************************************************************************************************************
// *******************************************************************************************************************************

#ifndef _HARDWARE_H
#define _HARDWARE_H

void HWReset(void);
void HWSync(void);
void HWQueueKeyboardEvent(int scanCode);
int HWKeymap(int k,int r);
void HWClearStrobe(void);
void HWSetMode(int mode);
void HWFlashInitialise(void);
int HWFlashCommand(int command,int sector,int subpage,int address,int dataCount);

#define HWF_ERASE  			(0x00)		 			// Erase sector.
#define HWF_READ			(0x01) 					// Read sector (partially)
#define HWF_WRITE 			(0x02) 					// Write complete sector.
#endif