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
ARG DOTFILES

RUN apk update
RUN apk add bat git delta jq neovim ripgrep rsync shellcheck bash openssh xz bash-completion
RUN adduser -h $CONTAINER_HOME -u $USERID -s $CONTAINER_SHELL -D enck
RUN printf "$PASS\n$PASS" | passwd
RUN printf "$PASS\n$PASS" | passwd enck
RUN chmod 4755 /bin/su
RUN echo $DOTFILES > /etc/dotfiles
COPY --chown=enck:enck . $CONTAINER_HOME
RUN rm -rf $CONTAINER_HOME/.git $CONTAINER_HOME/containers/ $CONTAINER_HOME/LICENSE $CONTAINER_HOME/README.md $CONTAINER_HOME/.bin/host $CONTAINER_HOME/.bashrc.d/*.host.*
COPY --from=efmbuild /src/efm/efm-langserver /usr/bin/efm-langserver
