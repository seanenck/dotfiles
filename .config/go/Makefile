SRC := $(shell find . -type f -name "*.go" | grep -v "vendor")
format:
	@echo $(SRC)
	exit $(shell goimports -l $(SRC) | wc -l)
