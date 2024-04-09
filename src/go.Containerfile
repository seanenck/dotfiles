FROM localhost/voidedtech-toolbox

RUN dnf install -y golang-go
COPY --chmod=755 bin/gotooling /usr/bin/gotooling
COPY --chmod=755 bin/golint /usr/bin/golint
