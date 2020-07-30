FROM debian:sid

RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y wget golang debhelper git go-bindata build-essential make

ARG OBJECT_VERSION
ARG OBJECT_NAME

ENV OBJECT=${OBJECT_NAME}-${OBJECT_VERSION}
ENV VERSION=${OBJECT_VERSION}

RUN wget https://cgit.voidedtech.com/${OBJECT_NAME}/snapshot/${OBJECT}.tar.gz
RUN tar xf ${OBJECT}.tar.gz
RUN mv ${OBJECT} build/

COPY debian build/debian
WORKDIR build

RUN dpkg-buildpackage -us -uc --build=binary
RUN cp ../*.deb /deb/
