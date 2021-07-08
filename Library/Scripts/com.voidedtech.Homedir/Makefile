BIN := bin/homedir
FLG := -ldflags '-linkmode external -extldflags $(LDFLAGS) -w' -trimpath -buildmode=pie -mod=readonly -modcacherw

$(BIN): homedir.go
	go build -o $(BIN) $(FLG) homedir.go

install:
	install -Dm755 $(BIN) $(HOME)/.bin/homedir

clean:
	rm -f $(BIN)
	mkdir -p target/
