hs.hotkey.bind({'cmd','ctrl'}, 'space', function()
    local windows = hs.window.orderedWindows()
    local screen = windows[1]:screen():frame()
    local nOfSpaces = #windows > 1 and #windows - 1 or 1

    local xMargin = screen.w / 10 -- unused horizontal margin
    local yMargin = 20            -- unused vertical margin
    local spacing = 100           -- the visible margin for each window

    for i, win in ipairs(windows) do
        local offset = (i - 1) * spacing
        local rect = {
            x = xMargin + offset,
            y = screen.y + yMargin + offset,
            w = screen.w - (2 * xMargin) - (nOfSpaces * spacing),
            h = screen.h - (2 * yMargin) - (nOfSpaces * spacing),
        }
        win:setFrame(rect)
    end
end)

