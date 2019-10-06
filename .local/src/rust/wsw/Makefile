.PHONY: lint build

build: target/release/wsw lint

target/release/wsw: $(shell find src/ -type f)
	cargo build --release

lint:
	cargo clippy

clean:
	rm -rf $(TARGET)
