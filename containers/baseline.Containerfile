FROM alpine:latest as efmbuild

ARG EFMVER
ARG GOFLAGS

RUN apk add --no-cache go git
RUN mkdir -p /src
RUN git clone "https://github.com/mattn/efm-langserver" /src/efm
WORKDIR /src/efm
RUN git checkout v$EFMVER
RUN go build $GOFLAGS -o efm-langserver

FROM alpine:latest

ARG PASS
ARG USERID
ARG CONTAINER_HOME
ARG CONTAINER_SHELL

RUN apk update
RUN apk add bat git delta jq neovim ripgrep rsync shellcheck bash openssh xz bash-completion
RUN adduser -h $CONTAINER_HOME -u $USERID -s $CONTAINER_SHELL -D enck
RUN printf "$PASS\n$PASS" | passwd
RUN printf "$PASS\n$PASS" | passwd enck
RUN chmod 4755 /bin/su
RUN mkdir -p $CONTAINER_HOME/.config $CONTAINER_HOME/.cache/nvim $CONTAINER_HOME/.local/state
RUN chown enck:enck -R $CONTAINER_HOME
COPY --from=efmbuild /src/efm/efm-langserver /usr/bin/efm-langserver
