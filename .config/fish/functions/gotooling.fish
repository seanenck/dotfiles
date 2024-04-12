if ! test -e /run/.containerenv
    function gotooling
        toolbox run -c go fish -c "gotooling"
    end
end
