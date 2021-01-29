FROM docker.io/alpine:latest

RUN apk --no-cache add curl python3
RUN curl https://raw.githubusercontent.com/enckse/eltorito/master/eltorito.py > eltorito
RUN install -Dm755 eltorito /usr/bin/eltorito
RUN mkdir /workdir
