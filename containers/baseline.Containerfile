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
