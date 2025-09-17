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
	Text_EN "Visit the MAUVILLE GAME CORNER\n"
	Text_EN "for an egg-stra fun time!@"

ScriptStart:
	setvirtualaddress ScriptStart
	vgoto .begin

	dw $00
	; 0x02028DD8


IF DEF(_RUBY)
	IF DEF(_BASE)
		INCBIN "asm/readASM_ruby.bin"
	ELIF DEF(_REV1)
		INCBIN "asm/readASM_ruby_r1.bin"
	ELIF DEF(_REV2)
		INCBIN "asm/readASM_ruby_r2.bin"
	ENDC
ELIF DEF(_SAPP)
	IF DEF(_BASE)
		INCBIN "asm/readASM_sapp.bin"
	ELIF DEF(_REV1)
		INCBIN "asm/readASM_sapp_r1.bin"
	ELIF DEF(_REV2)
		INCBIN "asm/readASM_sapp_r2.bin"
	ENDC
ENDC

.begin
	lock
	faceplayer
	showcoinsbox 0, 0
	virtualmsgbox IntroText
	waitmsg
	yesnobox 20, 8
	compare VAR_RESULT, 0
	vgoto_if TRUE, .exit

	getpartysize
	compare VAR_RESULT, 6
	vgoto_if 0, .coinCheck ; LESS THAN
	virtualmsgbox NoRoom
	waitmsg
	waitbuttonpress
	vgoto .exit

.coinCheck
	checkcoins VAR_RESULT
	compare VAR_RESULT, 1200
	vgoto_if 4, .raffle ; GREATER THAN OR EQUAL
	virtualmsgbox NoCoins
	waitmsg
	waitbuttonpress
	vgoto .exit
.raffle
	virtualmsgbox BuyEgg
	waitmsg
	waitbuttonpress
	removecoins 1200
	updatecoinsbox 0, 0
	playse 95 ; SE_SHOP
	waitse
	closemessage

	hidecoinsbox 0, 0
	fadeoutbgm 0
	fadescreen FADE_TO_BLACK
	delay 30
	playse 24 ; SE_CONTEST_PLACE
	waitse
	delay 30
	fadescreen FADE_FROM_BLACK
	fadeinbgm 0

	virtualmsgbox TextInput
	waitmsg
	yesnobox 20, 8
	compare VAR_RESULT, 1
	vgoto_if TRUE, .easyChat
	virtualmsgbox KeepThem
	waitmsg
	waitbuttonpress
	vgoto .genEgg

.easyChat
	; Easy Chat
	; Reset Easy Chat profile phrase

	setvar VAR_SPECIAL_8004, 0 ; Set Easy Chat mode to 'Profile'
	
IF DEF(_RUBY)
	IF DEF(_BASE)
		ccall $081a00f3 ; Common_EventScript_ShowEasyChatScreen
	ELIF DEF(_REV1)
		ccall $081a0113 ; Common_EventScript_ShowEasyChatScreen
	ELIF DEF(_REV2)
		ccall $081a0113 ; Common_EventScript_ShowEasyChatScreen
	ENDC
ELIF DEF(_SAPP)
	IF DEF(_BASE)
		ccall $081a0083 ; Common_EventScript_ShowEasyChatScreen
	ELIF DEF(_REV1)
		ccall $081a00a3 ; Common_EventScript_ShowEasyChatScreen
	ELIF DEF(_REV2)
		ccall $081a00a3 ; Common_EventScript_ShowEasyChatScreen
	ENDC
ENDC


	virtualmsgbox Wow
	waitmsg
	waitbuttonpress

.genEgg
	callnative $02028DD9 ; readASM
	callnative $02014951 ; genEgg

	virtualmsgbox GiveEgg
	waitmsg
	waitbuttonpress
	virtualmsgbox ReceivedEgg
	waitmsg
	waitbuttonpress
.exit
	hidecoinsbox 0, 0
	virtualmsgbox OutroText
	waitmsg
	waitbuttonpress
	closemessage
	release
	end

IntroText:
	Text_EN "Heyo!\p"

	Text_EN "Welcome to my egg-cellent\n"
	Text_EN "new business venture!\p"

	Text_EN "Yes yes!\p"

	Text_EN "For just a few COINS you can earn\n"
	Text_EN "yourself a brand new EGG TOKEN!\p"

	Text_EN "Each special token has a\n"
	Text_EN "fortune on the back side.\p"
	
	Text_EN "These EGG TOKENS can be\n"
	Text_EN "redeemed for prizes!\p"

	Text_EN "Care to participate in my EGG\n"
	Text_EN "TOKEN raffle?@"

BuyEgg:
	Text_EN "Oh yes, thank you!\n"

	Text_EN "One EGG TOKEN for you, my friend!@"

TextInput:
	Text_EN "Well? Will you share what the\n"
	Text_EN "fortune said?@"

Wow:
	Text_EN "Wow…\p"

	Text_EN "Profound.@"

KeepThem:
	Text_EN "Fine. Keep your secrets.@"

GiveEgg:
	Text_EN "Congrats on your new EGG TOKEN!\p"

	Text_EN "You win an EGG!\p"

	Text_EN "It’s a very special EGG. Care for\n"
	Text_EN "it deeply, ok?@"

ReceivedEgg:
	Text_EN "\v1 received a special EGG!@@"

NoCoins:
	Text_EN "You’ll need at least 1,200 COINS,\n"
	Text_EN "buddy.@"

NoRoom:
	Text_EN "Sorry, kid! Your party is full.\n"
	Text_EN "Make some room and come back.@"

OutroText:
	Text_EN "Come back soon! Yes yes!@"

ScriptEnd:


PreloadScriptStart:
	setvirtualaddress PreloadScriptStart
	virtualloadpointer PreloadText
	callnative $020003F9 ; storeASM
	setbyte 2
	end
	
	; 0x020003F8
	dd $00
	dw $00
IF DEF(_RUBY)
	IF DEF(_BASE)
		INCBIN "asm/storeASM_ruby.bin"
	ELIF DEF(_REV1)
		INCBIN "asm/storeASM_ruby_r1.bin"
	ELIF DEF(_REV2)
		INCBIN "asm/storeASM_ruby_r2.bin"
	ENDC
ELIF DEF(_SAPP)
	IF DEF(_BASE)
		INCBIN "asm/storeASM_sapp.bin"
	ELIF DEF(_REV1)
		INCBIN "asm/storeASM_sapp_r1.bin"
	ELIF DEF(_REV2)
		INCBIN "asm/storeASM_sapp_r2.bin"
	ENDC
ENDC
	; 0x02000408
	eggmons
	dd $00 ; Alignment
	dw $00
IF DEF(_RUBY)
	IF DEF(_BASE)
		INCBIN "asm/genEgg_ruby.bin"
	ELIF DEF(_REV1)
		INCBIN "asm/genEgg_ruby_r1.bin"
	ELIF DEF(_REV2)
		INCBIN "asm/genEgg_ruby_r2.bin"
	ENDC
ELIF DEF(_SAPP)
	IF DEF(_BASE)
		INCBIN "asm/genEgg_sapp.bin"
	ELIF DEF(_REV1)
		INCBIN "asm/genEgg_sapp_r1.bin"
	ELIF DEF(_REV2)
		INCBIN "asm/genEgg_sapp_r2.bin"
	ENDC
ENDC


DataEnd:
	EOF
