FROM docker.io/alpine:latest

RUN apk --no-cache add youtube-dl
RUN mkdir /workdir
