FROM docker.io/archlinux:latest

RUN pacman -Syyu --noconfirm
RUN pacman -S --noconfirm python python-pillow python-setuptools python-pygments git
RUN git clone git://cgit.voidedtech.com/pyxstitch
RUN cd pyxstitch && git checkout v1.9.0
RUN cd pyxstitch && python setup.py install
RUN mkdir /workdir
