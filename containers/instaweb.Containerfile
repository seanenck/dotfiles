FROM docker.io/alpine:latest

RUN apk --no-cache add git-gitweb perl-cgi lighttpd
COPY gitweb.lighttpd.conf /etc/gitweb.lighttpd.conf
COPY gitweb.conf /etc/gitweb.conf
RUN cat /etc/gitweb.lighttpd.conf >> /etc/lighttpd/lighttpd.conf

ENTRYPOINT /usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf -D
