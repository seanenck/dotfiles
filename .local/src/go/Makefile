FLAGS   := -ldflags '-linkmode external -extldflags $(LDFLAGS) -s -w' -gcflags=all=-trimpath=$(GOPATH) -asmflags=all=-trimpath=$(GOPATH) -buildmode=pie
SRC     := $(shell find . -type f -name "*.go")
OBJECTS := qrencode md2slides

.PHONY: build lint clean

build: $(OBJECTS) lint

$(OBJECTS): $(SRC)
	go build $(FLAGS) -o $@ cmd/$@/main.go

clean:
	rm -f $(OBJECTS)

lint:
	@golinter
