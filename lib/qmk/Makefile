QMK := $(HOME)/store/qmk_firmware/
HEX := $(QMK)/keebio_iris_rev6_enckse.hex
KM  := $(QMK)/keyboards/keebio/iris/keymaps/enckse
DFU := sudo dfu-programmer ATmega32U4 

all: compile flash clean

compile:
	mkdir -p $(KM)
	qmk json2c enckse.json > $(KM)/keymap.c
	cd $(QMK) && qmk compile -kb keebio/iris/rev6 -km enckse

flash:
	make program
	make program

program:
	bash flash.sh
	$(DFU) erase --force
	$(DFU) flash --force $(HEX)
	$(DFU) reset

clean:
	rm -rf $(KM)
	rm -f $(HEX)
