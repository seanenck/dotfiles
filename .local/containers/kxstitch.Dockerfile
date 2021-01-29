FROM docker.io/debian:unstable

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y kxstitch
RUN mkdir /workdir
