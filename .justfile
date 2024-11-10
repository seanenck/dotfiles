[no-cd]
golint:
    @command -v go > /dev/null
    @test -e go.mod || (echo "cowardly refusing to run without go.mod" && exit 1)
    @revive ./... | sed 's#^#revive:      #g'
    @go vet ./... | sed 's#^#go vet:      #g'
    @staticcheck -checks all -debug.run-quickfix-analyzers ./... | sed 's#^#staticcheck: #g'
    @gofumpt -l -extra $(find . -type f -name "*.go") | sed 's#^#gofumpt:     #g'

update-system:
{{- if eq ($.Dotfiles.Env "CONTAINER_ID") "" }}
    @! command -v flatpak > /dev/null || flatpak update
{{- end }}
    @! command -v blap > /dev/null || blap upgrade --commit
