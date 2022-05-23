FROM alpine:3.16

RUN apk add --no-cache bash alpine-sdk abuild doas
RUN adduser -s /bin/bash -D enck
RUN adduser enck abuild
RUN echo "enck:enck" | chpasswd
RUN echo "permit persist enck as root" > /etc/doas.d/doas.conf
RUN echo "/home/enck/packages" >> /etc/apk/repositories
RUN mkdir /apk
RUN chown enck:enck /apk
USER enck
