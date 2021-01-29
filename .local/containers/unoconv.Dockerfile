FROM docker.io/archlinux:latest

RUN pacman -Syyu --noconfirm
RUN pacman -S --noconfirm unoconv
RUN mkdir /workdir
