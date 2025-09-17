INCLUDE "../macros.asm"
INCLUDE "../constants/items.asm"
INCLUDE "../constants/scriptcommands.asm"
INCLUDE "../constants/pokemon.asm"
INCLUDE "asm.asm"
INCLUDE "eggs.asm"

	Mystery_Event

	db CHECKSUM_CRC
	dd 0 ; checksum placeholder
	GBAPTR DataStart
	GBAPTR DataEnd

DataStart:
	db IN_GAME_SCRIPT
	db 10, 03 ; MauvilleCity_GameCorner
	db 6	  ; Man 3
	GBAPTR ScriptStart
	GBAPTR ScriptEnd

	db PRELOAD_SCRIPT
	GBAPTR PreloadScriptStart

	db END_OF_CHUNKS

PreloadText:
	Text_EN "@"

ScriptStart:
	setvirtualaddress ScriptStart

	random 42
	addvar VAR_RESULT, CHERI_BERRY

	writebytetoaddr $8B, $030045c0
	writebytetoaddr $85, $030045c2
	writebytetoaddr $86, $030045c4
	writebytetoaddr $87, $030045c6
	writebytetoaddr $88, $030045c8
	writebytetoaddr $89, $030045cA
	copybyte $030045cC, $0202e8dc
	copybyte $030045cD, $0202e8dd
	writebytetoaddr $00, $030045cE
	writebytetoaddr $00, $030045cF

	pokemart $030045cC
	closemessage
	; callnative $080b4ee5
	; waitstate
	; lock
	; faceplayer
	; virtualmsgbox BerryText
	; waitmsg
	; waitbuttonpress
	; closemessage
	end

ScriptEnd:

BerryText:
	Text_EN "\v2!!@"

PreloadScriptStart:
	setvirtualaddress PreloadScriptStart
	virtualloadpointer PreloadText
	setbyte 2
	end

DataEnd:
	EOF
