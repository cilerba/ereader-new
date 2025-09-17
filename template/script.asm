INCLUDE "../macros.asm"
INCLUDE "../constants/items.asm"
INCLUDE "../constants/scriptcommands.asm"

	Mystery_Event

	db CHECKSUM_CRC
	dd 0 ; checksum placeholder
	GBAPTR DataStart
	GBAPTR DataEnd

DataStart:
	db IN_GAME_SCRIPT
	db 8,1 ; Petalburg Gym
	db 1   ; Norman
	GBAPTR ScriptStart
	GBAPTR ScriptEnd

	db PRELOAD_SCRIPT
	GBAPTR PreloadScriptStart

	db END_OF_CHUNKS

PreloadText:
	Text_EN "@"

ScriptStart:
	setvirtualaddress ScriptStart
	end

ScriptEnd:

PreloadScriptStart:
	setvirtualaddress PreloadScriptStart
	
	virtualloadpointer PreloadText
	setbyte 2
	end

DataEnd:
	EOF
