; some Z80 opcodes aren’t supported by Game Boy, 
; but are used in e-Reader programs

; ld [\1], hl
MACRO LD_IND_HL
	db $22, (\1 & $FF), (\1 >> 8)
	ENDM
; ld [\1], a
MACRO LD_IND_A
	db $32, (\1 & $FF), (\1 >> 8)
	ENDM

; ld hl, [\1]
MACRO LD_HL_IND
	db $2A, (\1 & $FF), (\1 >> 8)
	ENDM
; ld a, [\1]
MACRO LD_A_IND
	db $3A
	dw \1
	ENDM

MACRO waita
	ld a, \1
	db $76
	ENDM
; ld [hl], a
MACRO LD_IND_HL_A
	db $77
	ENDM

; ld a, [hl]
MACRO LD_IND_A_HL
	db $7E
	ENDM

; ld c, [hl]
MACRO LD_IND_C_HL
	db $4E
	ENDM

; ld b, [hl]
MACRO LD_IND_B_HL
	db $46
	ENDM

; ld l, [hl]
MACRO LD_IND_L_HL
	db $6E
	ENDM

; ld e, [hl]
MACRO LD_IND_E_HL
	db $5E
	ENDM

; ld d, [hl]
MACRO LD_IND_D_HL
	db $56
	ENDM

; ld [hl], c
MACRO LD_IND_HL_C
	db $71
	ENDM

; ld [hl], b
MACRO LD_IND_HL_B
	db $70
	ENDM

; ld a, [de]
MACRO LD_IND_A_DE
	db $1A
	ENDM

; add a, [hl]
MACRO ADD_A_HL_IND
	db $86
	ENDM

MACRO EX_DE_HL
	db $EB
	ENDM

MACRO wait
	db $D3, \1
	ENDM

MACRO API
	db ($C7 + (\1 & $100) >> 5), (\1 & $FF) ; $C7 for API $0xx, $CF for API $1xx
	ENDM



MACRO dd
	dw (\1) & $FFFF
	dw (\1) >> 16
	ENDM

MACRO RGB
	dw (\1) | ((\2) << 5) | ((\3) << 10)
	ENDM

MACRO GBAPTR
	dd $02000000 + \1 - ScriptBaseAddress
	ENDM

MACRO ASMPTR
	dd $02000001 + \1 - ScriptBaseAddress
	ENDM

MACRO Insert_Prologue
	db "GameFreak inc."
	db 0,0,0,0,0,0
	dd \1
	db \2
	REPT 8 - STRLEN(\2)
		db 0
	ENDR
	db 0,0,0,0,$01,$55
	db 0,0,0,0
	db \3
	db 0
	db "GameFreak inc."
	db 0,0
	ENDM

MACRO Mystery_Event
DEF ScriptBaseAddress EQU $100
	SECTION "mysteryevent", ROM0[$100]
	db $01
	dd $02000000
	db REGION,0,REGION,0,0,0,$04,0,$80,$01,0,0
	ENDM

DEF REGION_JP EQU $01
DEF REGION_EN EQU $02
DEF REGION_FR EQU $03 ; ?
DEF REGION_IT EQU $04 ; ?
DEF REGION_DE EQU $05 ; !
DEF REGION_ES EQU $07 ; ¿?

; types of card data
DEF END_OF_CHUNKS    EQU $02
DEF LOADING_MESSAGE  EQU $03
DEF SET_LOAD_STATUS  EQU $04
DEF PRELOAD_SCRIPT   EQU $05
DEF IN_GAME_SCRIPT   EQU $06
DEF CUSTOM_BERRY     EQU $07
DEF AWARD_RIBBON     EQU $08
DEF NATIONAL_POKEDEX EQU $09
DEF ADD_RARE_WORD    EQU $0A
DEF MIX_RECORDS_ITEM EQU $0B
DEF GIVE_POKEMON     EQU $0C
DEF BATTLE_TRAINER   EQU $0D
DEF CLOCK_ADJUSTMENT EQU $0E
DEF CHECKSUM_BYTES   EQU $0F ; don’t use this
DEF CHECKSUM_CRC     EQU $10 ; use this instead
DEF DOME_TRAINER     EQU $11 ; Battle Dome trainer

; an FF byte followed by 00s will flag the end of the program so that it can
; be extracted automatically from the Game Boy ROM that rgbds tries to build
MACRO EOF
	db $FF
	ENDM


; names for some API functions based on Martin Korth’s GBATEK
; http://problemkaputt.de/gbatek.htm
MACRO FadeIn
	ld a, \1
	API $000
	ENDM
MACRO SetBackgroundAutoScroll
	ld bc, \1
	ld de, \2
	xor a
	API $012
	ENDM
MACRO SetBackgroundMode
	ld e, \1
	push de
	xor a
	API $019
	ENDM
MACRO API_02C
	ld hl, $0000
	push hl
	ld bc, \1
	ld de, \2
	IF \3 == 0
		xor a ; save a byte
	ELSE
		ld a, \3
	ENDC
	API $02C
	ENDM
MACRO LoadCustomBackground
	ld de, \1
	IF \2 == 0
		xor a ; save a byte
	ELSE
		ld a, \2
	ENDC
	API $02D
	ENDM
MACRO SetSpritePos
	ld bc, \3
	ld de, \2
	LD_HL_IND \1
	API $032
	ENDM
MACRO SpriteShow
	LD_HL_IND \1
	API $046
	ENDM
MACRO SpriteHide
	LD_HL_IND \1
	API $047
	ENDM
MACRO SpriteMirrorToggle
	ld e, \1
	LD_HL_IND \2
	API $048
	ENDM
MACRO CreateCustomSprite
	ld e, \2
	ld hl, \3
	API $04D
	LD_IND_HL \1
	ENDM
MACRO SpriteAutoScaleUntilSize
	ld c, \2
	ld de, \3
	LD_HL_IND \1
	API $05B
	ENDM
MACRO SetBackgroundPalette
	ld c, \1
	ld de, \2
	ld hl, \3
	API $07E
	ENDM
MACRO API_084
	ld l, \4
	push hl
	ld bc, \3
	ld de, \2
	LD_HL_IND \1
	API $084
	ENDM
MACRO CreateRegion
	ld bc, (\2 << 8 + \3)
	ld de, (\4 << 8 + \5)
	ld hl, (\6 << 8 + \7)
	API $090
	LD_IND_A \1
	ENDM
MACRO SetRegionColor
	ld e, \2
	LD_A_IND \1
	API $091
	ENDM
MACRO CLEAR_REGION
	LD_A_IND \1
	API $092
	ENDM
MACRO SetTextColor
	ld de, (\2 << 8 + \3)
	LD_A_IND \1
	API $098
	ENDM
MACRO DrawText
	CLEAR_REGION \1
	ld bc, \2
	ld de, (\3 << 8 + \4)
	LD_A_IND \1
	API $099
	ENDM
MACRO SetTextSize
	API $09A
	ENDM
MACRO API_09B
	ld de, \2
	LD_A_IND \1
	API $09B
	ENDM
MACRO GetTextWidth
	ld de, \2
	LD_A_IND \1
	API $0C0
	ENDM
MACRO API_0C7
	ld hl, \1
	API $0C7
	ENDM
MACRO EXIT
	API $100
	ENDM
MACRO API_106
	ld de, \1
	ld hl, \2
	API $106
	ENDM
MACRO SOUND_PAUSE
	API $116
	ENDM
MACRO IS_SOUND_PLAYING
	API $08D
	ld b, $00
	ld e, $01
	ld hl, $0006
	API $119
	ld a, \1
	EXIT
	ENDM
MACRO API_121
	ld de, $0000
	ld hl, $0000
	API $121
	ENDM
