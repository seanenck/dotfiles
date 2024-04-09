FROM localhost/voidedtech-toolbox

RUN dnf install -y ffmpeg-free
COPY --chmod=755 bin/transcode-media /usr/bin/transcode-media
