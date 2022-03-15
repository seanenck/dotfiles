{ config, pkgs, ... }:
{
    home.username = "enck";
    home.homeDirectory = "/home/enck";
    home.stateVersion = "21.05";
    programs.home-manager.enable = true;
    home.packages = [
        pkgs.sway
        pkgs.firefox
        pkgs.git
        pkgs.mumble
        pkgs.gnumake
        pkgs.curl
        pkgs.wget
        pkgs.python3
        pkgs.diff-so-fancy
        pkgs.stow
        pkgs.ripgrep
        pkgs.pavucontrol
        pkgs.gnupg
        pkgs.keepassxc
        pkgs.go
        pkgs.gotools
        pkgs.mblaze
        pkgs.pamixer
        pkgs.kitty
        pkgs.wofi
        pkgs.swayidle
        pkgs.swaylock
        pkgs.wl-clipboard
    ];
}
