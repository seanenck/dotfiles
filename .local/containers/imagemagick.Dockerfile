FROM docker.io/alpine:latest

RUN apk --no-cache add imagemagick
RUN mkdir /build
WORKDIR /build
