TARGET=resume
OUTPUT=bin
RESUME=$(OUTPUT)/$(TARGET).tex
ADDRESS=
PHONE=


all:
	mkdir -p $(OUTPUT)
ifeq ($(ADDRESS),)
	$(error "address required")
endif
ifeq ($(PHONE),)
	$(error "phone required")
endif
	cat $(TARGET).tex | sed "s/{PHONE}/$(PHONE)/g;s/{ADDRESS}/$(ADDRESS)/g" > $(RESUME)
	xelatex -interaction nonstopmode -output-directory=$(OUTPUT) $(RESUME)

install:
	pacman -S texlive-most

clean:
	rm -rf $(OUTPUT)/*

.PHONY: all clean
