ifeq ($(OS),Windows_NT)
include ..\..\documents\common.make
else
include ../../documents/common.make
endif

all: 
	$(PYTHON) scancodes.py >..$(S)src$(S)generated$(S)ps2convert.asm

