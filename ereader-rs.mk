CARD_ID			?=
VERSION 		?=
REGION			?=
REV				?=
GAME			?=
DISPLAY_NAME	?= Event
STRIPS			?= 1

BUILD_DIRS		= build

CARD_NAME		= $(CARD_ID)_$(VERSION)$(REV)$(GAME)
FILE_NAME		= $(CARD_NAME)-$(REGION)

PROLOGUE_ASM	= prologue

ASM				:= $(wildcard asm/*.asm)
ASM_BIN			:= $(ASM:asm/%.asm=%)

all: build/$(FILE_NAME).raw build/$(FILE_NAME).sa2 build/$(FILE_NAME).gba 
asm: $(ASM_BIN)

build/prologue-%.tx: prologue.asm
	python3 ../scripts/regionalize.py $< $@ $* $*
build/prologue-%.o: build/prologue-%.tx
	../bin/rgbds/v0.9.1/rgbasm -M $@.d -o $@ $< -D $(REV)=1 -D $(GAME)=1
build/prologue-%.gbc: build/prologue-%.o
	../bin/rgbds/v0.9.1/rgblink -o $@ $<
build/prologue-%.bin: build/prologue-%.gbc
	python3 ../scripts/stripgbc.py $< $@

.PRECIOUS: build/prologue-%.tx build/prologue-%.o build/prologue-%.gbc build/prologue-%.bin

build/script-%.tx: script.asm
	python3 ../scripts/regionalize.py $< $@ $* $*
build/script-%.o: build/script-%.tx
	../bin/rgbds/v0.9.1/rgbasm -M $@.d -o $@ $< -D $(REV)=1 -D $(GAME)=1
build/script-%.gbc: build/script-%.o
	../bin/rgbds/v0.9.1/rgblink -o $@ $<
build/script-%.bin: build/script-%.gbc
	python3 ../scripts/stripgbc.py $< $@
build/script-%.mev: build/script-%.bin
	python3 ../scripts/checksum.py $< $@

.PRECIOUS: build/script-%.tx build/script-%.o build/script-%.gbc build/$(CARD_NAME)-%.vpk build/script-%.bin build/script-%.mev

build/$(CARD_NAME)-%.tx: card.asm build/script-%.mev build/prologue-%.bin
	python3 ../scripts/ereadertext.py $< $@ $*
build/$(CARD_NAME)-%.o: build/$(CARD_NAME)-%.tx
	../bin/rgbds/v0.9.1/rgbasm -M $@.d -I build -o $@ $< -D $(REV)=1 -D $(GAME)=1
build/$(CARD_NAME)-%.gbc: build/$(CARD_NAME)-%.o
	../bin/rgbds/v0.9.1/rgblink -o $@ $<
build/$(CARD_NAME)-%.z80: build/$(CARD_NAME)-%.gbc
	python3 ../scripts/stripgbc.py $< $@
build/$(CARD_NAME)-%.vpk: build/$(CARD_NAME)-%.z80
	../bin/nedc/v1.4.1/nevpk -c -i $< -o $@

build/$(CARD_NAME)-%.raw: build/$(CARD_NAME)-%.vpk
ifeq ($(STRIPS), 1)
	../bin/nedc/v1.4/nedcmake -i $< -o build/$(FILE_NAME) -type 1 -region 1
else
	../bin/nedc/v1.4.1/nedcmake -i $< -o build/$(FILE_NAME) -type 1 -region 1
endif

build/$(CARD_NAME)-%.sa2: build/$(CARD_NAME)-%.vpk
	../bin/neflmake -i $< -o "$@" -type 1 -name "$(DISPLAY_NAME)"

%: asm/%.asm
	../bin/arm-none-eabi-as $< -o asm/$@_ruby.bin	 -mcpu=arm7tdmi -mthumb --defsym BASE=1 --defsym RUBY=1
	../bin/arm-none-eabi-as $< -o asm/$@_ruby_r1.bin -mcpu=arm7tdmi -mthumb --defsym REV1=1 --defsym RUBY=1
	../bin/arm-none-eabi-as $< -o asm/$@_ruby_r2.bin -mcpu=arm7tdmi -mthumb --defsym REV2=1 --defsym RUBY=1

	../bin/arm-none-eabi-as $< -o asm/$@_sapp.bin	 -mcpu=arm7tdmi -mthumb --defsym BASE=1 --defsym SAPP=1
	../bin/arm-none-eabi-as $< -o asm/$@_sapp_r1.bin -mcpu=arm7tdmi -mthumb --defsym REV1=1 --defsym SAPP=1
	../bin/arm-none-eabi-as $< -o asm/$@_sapp_r2.bin -mcpu=arm7tdmi -mthumb --defsym REV2=1 --defsym SAPP=1

	../bin/arm-none-eabi-objcopy asm/$@_ruby.bin	-O binary asm/$@_ruby.bin
	../bin/arm-none-eabi-objcopy asm/$@_ruby_r1.bin -O binary asm/$@_ruby_r1.bin
	../bin/arm-none-eabi-objcopy asm/$@_ruby_r2.bin -O binary asm/$@_ruby_r2.bin

	../bin/arm-none-eabi-objcopy asm/$@_sapp.bin	-O binary asm/$@_sapp.bin
	../bin/arm-none-eabi-objcopy asm/$@_sapp_r1.bin -O binary asm/$@_sapp_r1.bin
	../bin/arm-none-eabi-objcopy asm/$@_sapp_r2.bin -O binary asm/$@_sapp_r2.bin


.PRECIOUS: asm/%.bin build/script-%.tx build/script-%.o build/script-%.gbc build/$(CARD_NAME)-%.vpk build/script-%.bin build/$(CARD_NAME)-%.raw build/script-%.mev

build/$(CARD_NAME)-%.gba:
	cp -rf ../test/EREADER.gba $@

# Automatically create build dirs if missing
$(info $(shell mkdir -p $(BUILD_DIRS)))

.PHONY: clean
clean:
	rm -rf build && mkdir -p $(BUILD_DIRS)
	rm -rf asm/*.bin
	
# Automatically generated dep files
-include build/*.d
