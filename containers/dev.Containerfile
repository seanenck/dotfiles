FROM alpine:edge as buildenv

ARG GOFUMPTVER=v0.5.0
ARG REVIVEVER=v1.3.2
ARG GOFLAGS="-ldflags=-linkmode=external -trimpath -buildmode=pie -mod=readonly -modcacherw -buildvcs=false"

RUN apk add --no-cache go gcc musl-dev git
RUN mkdir -p /src

RUN git clone "https://github.com/mvdan/gofumpt" /src/gofumpt
WORKDIR /src/gofumpt
RUN git checkout $GOFUMPTVER
RUN go build $GOFLAGS -o gofumpt

RUN git clone "https://github.com/mgechev/revive" /src/revive
WORKDIR /src/revive
RUN git checkout $REVIVEVER
RUN go build $GOFLAGS -o revive

FROM alpine:edge

RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk update
RUN apk add go make git bash bash-completion bat delta docs efm-langserver@testing findutils gcc gopls jq musl-dev neovim openssh openssl perl-critic@testing perl-tidy@testing ripgrep rsync shellcheck staticcheck util-linux xz
COPY --from=buildenv /src/gofumpt/gofumpt /usr/bin/gofumpt
COPY --from=buildenv /src/revive/revive /usr/bin/revive
