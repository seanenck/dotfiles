if set -q GOPATH
    function golint
        if ! test -e go.mod
            echo "cowardly refusing to run linting outside of project root"
            return
        end
        revive ./...                                                | sed 's/^/revive:      /g'
        go vet ./...                                                | sed 's/^/govet:       /g'
        staticcheck -checks all -debug.run-quickfix-analyzers ./... | sed 's/^/staticcheck: /g'
        gofumpt -l -extra $(find . -type f -name "*.go")            | sed 's/^/gofumpt:     /g'
    end
end
