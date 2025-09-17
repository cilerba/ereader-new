all: build/card-EN-01.raw build/card-EN.sav

build/prologue-%.tx: prologue.asm
	python3 ../scripts/regionalize.py $< $@ $* $*
build/prologue-%.o: build/prologue-%.tx
	../bin/rgbds/v0.9.1/rgbasm -M $@.d -o $@ $<
build/prologue-%.gbc: build/prologue-%.o
	../bin/rgbds/v0.9.1/rgblink -o $@ $<
build/prologue-%.bin: build/prologue-%.gbc
	python3 ../scripts/stripgbc.py $< $@

.PRECIOUS: build/prologue-%.tx build/prologue-%.o build/prologue-%.gbc build/prologue-%.bin

build/script-%.tx: script.asm
	python3 ../scripts/regionalize.py $< $@ $* $*
build/script-%.o: build/script-%.tx
	../bin/rgbds/v0.9.1/rgbasm -M $@.d -o $@ $<
build/script-%.gbc: build/script-%.o
	../bin/rgbds/v0.9.1/rgblink -o $@ $<
build/script-%.bin: build/script-%.gbc
	python3 ../scripts/stripgbc.py $< $@
build/script-%.mev: build/script-%.bin
	python3 ../scripts/checksum.py $< $@

.PRECIOUS: build/script-%.tx build/script-%.o build/script-%.gbc build/script-%.bin build/script-%.mev

build/card-%.tx: card.asm build/script-%.mev build/prologue-%.bin
	python3 ../scripts/ereadertext.py $< $@ $*
build/card-%.o: build/card-%.tx
	../bin/rgbds/v0.9.1/rgbasm -M $@.d -I build -o $@ $<
build/card-%.gbc: build/card-%.o
	../bin/rgbds/v0.9.1/rgblink -o $@ $<
build/card-%.z80: build/card-%.gbc
	python3 ../scripts/stripgbc.py $< $@
build/card-%.vpk: build/card-%.z80
	../bin/nedc/v1.4/nevpk -c -i $< -o $@

# Sub maps card-LANG-01.raw -> card-LANG so the tool output matches
build/card-%-01.raw: build/card-%.vpk
	../bin/nedc/v1.4/nedcmake -i $< -o $(subst -01.raw,,$@) -type 1 -region 1

build/card-%.sav: build/card-%.vpk
	../bin/nedc/v1.4/nefmake -i $< -o "$@" -type 1 -name "Card"

.PRECIOUS: build/card-%.tx build/card-%.o build/card-%.gbc build/card-%.z80 build/card-%.vpk build/card-%-01.raw

# Automatically create build dirs if missing
BUILD_DIRS=build
$(info $(shell mkdir -p $(BUILD_DIRS)))

.PHONY: clean
clean:
	rm -rf build && mkdir -p $(BUILD_DIRS)

# Automatically generated dep files
-include build/*.d
