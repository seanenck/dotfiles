if ! test -e /run/.containerenv
    function update-system
        neovim-plugins
        gotooling
        update-toolbox
    end
end
