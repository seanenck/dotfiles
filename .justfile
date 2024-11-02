systemimage := home_dir() / "Workspace" / "workstation-builds"

[no-cd]
golint:
    @command -v go > /dev/null
    @test -e go.mod || (echo "cowardly refusing to run without go.mod" && exit 1)
    @revive ./... | sed 's#^#revive:      #g'
    @go vet ./... | sed 's#^#go vet:      #g'
    @staticcheck -checks all -debug.run-quickfix-analyzers ./... | sed 's#^#staticcheck: #g'
    @gofumpt -l -extra $(find . -type f -name "*.go") | sed 's#^#gofumpt:     #g'

system-updates:
    @! command -v flatpak > /dev/null || flatpak update
    @! command -v blap > /dev/null || blap upgrade --commit
    just --global-justfile update-system-image

update-system-image:
    test -d {{systemimage}} || git clone https://github.com/seanenck/workstation-builds {{systemimage}}
    git -C {{systemimage}} pull
    cd {{systemimage}} && just needs
