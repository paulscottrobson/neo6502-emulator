// *******************************************************************************************************************************
// *******************************************************************************************************************************
//
//		Name:		flash.cpp
//		Purpose:	Flash Interface - modelled on Pico SDK flash hardware library options.
//		Created:	27th June 2023
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// *******************************************************************************************************************************
// *******************************************************************************************************************************

#ifndef _HARDWAREFLASH_H
#define _HARDWAREFLASH_H

#include "sys_processor.h"
#include "hardware.h"
#include <stdio.h>

static int sectorCount = 0;
static FILE *flashHandler = NULL;

// *******************************************************************************************************************************
//												Initialise Flash
// *******************************************************************************************************************************

void HWFlashInitialise(void) {
	//
	//		Real: Read the header of the first storage flash sector - these are bytes 2 and 3.
	//	
	flashHandler = fopen("storage/flash.image","rb"); 			
	fgetc(flashHandler);
	fgetc(flashHandler);
	sectorCount = fgetc(flashHandler);
	sectorCount += fgetc(flashHandler) * 256;
	//printf("Flash:initialised sectors %d size 4096\n",sectorCount);
}

// *******************************************************************************************************************************
//												Reset Hardware
// *******************************************************************************************************************************

int HWFlashCommand(int command,int sector,int subpage,int address,int dataCount) {

	int retVal = 0;

	switch(command) {
		//
		//		Erase the entirety of the given sector.
		//
		//		Real : erase given sector using flash_page_erase
		//
		case HWF_ERASE:  					 			// Erase sector.
			//printf("Erasing sector %d\n",sector);
			flashHandler = fopen("storage/flash.image","rb+"); 			
			fseek(flashHandler,sector * 4096,SEEK_SET);
			for (int i = 0;i < 4096;i++) fputc(0xFF,flashHandler);
			fclose(flashHandler);
			break;
		//
		//		Write the data into the given page.
		//
		// 	Real : program page using flash_page_program
		//
		case HWF_WRITE:
			//printf("Writing to sector %d:%d Address:$%04x\n",sector,subpage,address);
			flashHandler = fopen("storage/flash.image","rb+"); 			
			fseek(flashHandler,sector * 4096 + subpage * 256,SEEK_SET);
			for (int i = 0;i < 256;i++) {
				fputc(CPUReadMemory(address++),flashHandler);			// In real Flash, you'd AND it with the current value.
			}
			fclose(flashHandler);
			break;
		//
		//		Read the data into the given page, dataCount only.
		//
		// 	Real : read as offset from XIP_BASE 
		//
		case HWF_READ:
			//printf("Reading from sector %d:%d Address:$%04x (%d bytes)\n",sector,subpage,address,dataCount == 0 ? 256:dataCount);
			flashHandler = fopen("storage/flash.image","rb"); 			
			fseek(flashHandler,sector * 4096 + subpage * 256,SEEK_SET);
			if (dataCount == 0) dataCount = 256; 	 					// 0 = read whole page
			for (int i = 0;i < dataCount;i++) {
				CPUWriteMemory(address++,fgetc(flashHandler)); 	
			}
			fclose(flashHandler);
			break;

	}
	return retVal;
}

#endif