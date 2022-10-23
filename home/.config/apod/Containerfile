FROM alpine:latest

ARG PACKAGES
ARG APKSRC
ARG BUILDUSER

RUN apk add --no-cache bash alpine-sdk abuild doas
RUN adduser -s /bin/bash -D $BUILDUSER
RUN adduser $BUILDUSER abuild
RUN echo "$BUILDUSER:$BUILDUSER" | chpasswd
RUN echo "permit nopass $BUILDUSER as root" > /etc/doas.d/doas.conf
RUN echo "$PACKAGES" >> /etc/apk/repositories
RUN mkdir $APKSRC
RUN chown $BUILDUSER:$BUILDUSER $APKSRC
USER $BUILDUSER
