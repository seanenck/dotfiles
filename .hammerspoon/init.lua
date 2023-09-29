hs.hotkey.bind({'cmd','ctrl'}, 'space', function()
    local windows = hs.window.orderedWindows()
    local screen = windows[1]:screen():frame()
    local nOfSpaces = #windows > 1 and #windows - 1 or 1

    local xMargin = screen.w / 20 -- unused horizontal margin
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

hs.hotkey.bind({'cmd','ctrl'}, 'return', function()
    local windows = hs.window.orderedWindows()
    local screen = windows[1]:screen():frame()

    local xMargin = screen.w / 50
    local yMargin = 20
    local bigX = 0.6
    local mainX = screen.w * bigX

    local count = 0
    local focus = {}
    for i, win in ipairs(windows) do
        local app = win:application()
        if app ~= nil then
            local name = app:name()
            if name ~= nil and name == "kitty" then
              local rect = {
                  x = xMargin,
                  y = screen.y + yMargin,
                  w = screen.w,
                  h = screen.h
              }
              if count == 0 then
                  rect.w = mainX
                  win:focus()
              elseif count == 1 then
                  rect.w = (screen.w * (1 - bigX)) - 200
                  rect.x = rect.x + mainX + 50
              end
              win:setFrame(rect)
              focus[count] = win
              count = count + 1
              if count >= 2 then
                  break
              end
            end
        end
    end
    if count > 0 then
        if count > 1 then
            focus[1]:focus()
        end
        focus[0]:focus()
    end
end)

