if ! test -e /run/.containerenv
    function transcode-media
        toolbox run -c ffmpeg transcode-media
    end
end
