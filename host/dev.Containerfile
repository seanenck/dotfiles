FROM alpine:edge as buildenv

ARG GOFUMPTVER=v0.5.0
ARG REVIVEVER=v1.3.3
ARG TDIFFVER=v0.1.2
ARG GOFLAGS="-ldflags=-linkmode=external -trimpath -buildmode=pie -mod=readonly -modcacherw -buildvcs=false"

RUN apk add --no-cache go gcc musl-dev make git
RUN mkdir -p /src

RUN git clone "https://github.com/mvdan/gofumpt" /src/gofumpt
WORKDIR /src/gofumpt
RUN git checkout $GOFUMPTVER
RUN go build $GOFLAGS -o gofumpt

RUN git clone "https://github.com/mgechev/revive" /src/revive
WORKDIR /src/revive
RUN git checkout $REVIVEVER
RUN go build $GOFLAGS -o revive

RUN git clone "https://github.com/enckse/tdiff" /src/tdiff
WORKDIR /src/tdiff
RUN git checkout $TDIFFVER
RUN GOFLAGS=$GOFLAGS make bin/tdiff

FROM alpine:edge

RUN apk update
RUN apk add \
        go \
        make \
        git \
        bash \
        bash-completion \
        bat delta \
        docs \
        findutils \
        gcc \
        gopls \
        musl-dev \
        neovim \
        openssh \
        openssl \
        py3-lsp-server \
        py3-mypy \
        py3-pycodestyle \
        py3-pyflakes \
        py3-whatthepatch \
        py3-yapf \
        ripgrep \
        rsync \
        shellcheck \
        staticcheck \
        util-linux \
        tar
COPY --from=buildenv /src/gofumpt/gofumpt /usr/bin/gofumpt
COPY --from=buildenv /src/revive/revive /usr/bin/revive
COPY --from=buildenv /src/tdiff/bin/tdiff /usr/bin/tdiff
COPY --from=buildenv /src/tdiff/contrib/bash.completion /usr/share/bash-completion/completions/tdiff
