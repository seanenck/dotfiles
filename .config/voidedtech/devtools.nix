{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    # nativeBuildInputs is usually what you want -- tools you need to run
    nativeBuildInputs = [ 
        pkgs.buildPackages.golangci-lint
        pkgs.buildPackages.go_1_16
        pkgs.buildPackages.cargo
        pkgs.buildPackages.clippy
        pkgs.buildPackages.rustc
        pkgs.buildPackages.libiconv
        pkgs.buildPackages.goimports
        pkgs.buildPackages.golint
        pkgs.buildPackages.rustup
    ];
}
