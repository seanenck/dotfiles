{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    nativeBuildInputs = [ 
        pkgs.buildPackages.python38Packages.pydocstyle
        pkgs.buildPackages.python38Packages.pycodestyle
    ];
}
