BIN := bin/
FLG := -ldflags '-linkmode external -extldflags $(LDFLAGS) -w' -trimpath -buildmode=pie -mod=readonly -modcacherw
T2L := $(BIN)lb-rw
GIT := $(shell git log -n1 --format=%h .)
X86 := $(T2L).amd64
STR := $(LOCKBOX_STORE)/.bin/
VER := $(STR)version
CMD := $(BIN)lb-diff $(BIN)lb-stats $(BIN)lb-rekey $(T2L) $(BIN)lb $(BIN)lb-totp $(BIN)lb-pwgen

all: $(CMD)

install:
	GOOS=linux GOARCH=amd64 go build -o $(X86) -trimpath -buildmode=pie -mod=readonly -modcacherw cmd/rw/main.go
	if [[ $(shell cat $(VER)) != $(GIT) ]]; then for f in $(T2L) $(X86); do cp $$f $(LOCKBOX_STORE)/.bin/; done; echo $(GIT) > $(VER); fi
	for f in $(CMD); do install -m755 $$f $(HOME)/.bin/; done
	
$(CMD): $(shell find . -type f -name "*.go")
	go build -o $@ $(FLG) cmd/$(shell basename $@ | sed 's/lb-//g')/main.go

clean:
	rm -rf $(BIN)
	mkdir -p $(BIN)
