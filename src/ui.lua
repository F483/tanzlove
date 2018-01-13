local gfx = require("src.gfx")
local vector = require("lib.hump.vector-light")
local util = require("src.util")
local sys = require("src.sys")
local colors = require("src.colors")
local rects = require("src.rects")
local Button = require("src.button")

-- board
local WIDTH = 236
local HEIGHT = gfx.HEIGHT

-- camera
local CAM_SPEED = 2 -- pixel per second
local CAM_LEFT = {0, 0}
local CAM_RIGHT = {76, 0}

local ui = {
    cam = util.deepCopy(CAM_LEFT),
    buttons = {}
}

function ui._addSelectorButtons(rect, onInc, onDec, onPress, onOver)
    local x, y, w, h = unpack(rect)
    local dec = Button({x, y, 8, 8}, ui.cam, onDec)
    local show = Button({x + 8, y, 24, 8}, ui.cam, onPress, onOver, false, false)
    local inc = Button({x + 8 + 24, y, 8, 8}, ui.cam, onInc)
    table.insert(ui.buttons, inc)
    table.insert(ui.buttons, dec)
    table.insert(ui.buttons, show)
end

function ui._initDeck(deck)

    -- track buttons
    for t = 1, 4 do

        -- select
        table.insert(ui.buttons, Button(
            rects[deck].track[t].select, ui.cam, 
            function () sys.trackSelect(t, deck) end
        ))

        -- mute
        table.insert(ui.buttons, Button(
            rects[deck].track[t].mute, ui.cam, 
            function () sys.toggleMute(t, deck) end
        ))

        -- solo
        table.insert(ui.buttons, Button(
            rects[deck].track[t].solo, ui.cam, 
            function () sys.toggleSolo(t, deck) end
        ))

    end

    -- vol
    ui._addSelectorButtons(
        rects[deck].vol, 
        function () sys.volInc(deck) end, 
        function () sys.volDec(deck) end, 
        function () sys.volTouch(deck) end,
        function () sys.volTouch(deck) end
    )

    -- snd
    ui._addSelectorButtons(
        rects[deck].snd, 
        function () sys.sndInc(deck) end, 
        function () sys.sndDec(deck) end, 
        function () sys.play(deck, track) end,
        function () sys.sndTouch(deck) end
    )

    -- num
    ui._addSelectorButtons(
        rects[deck].num, 
        function () sys.numInc(deck) end, 
        function () sys.numDec(deck) end, 
        function () sys.numTouch(deck) end,
        function () sys.numTouch(deck) end
    )

    -- rot
    ui._addSelectorButtons(
        rects[deck].rot, 
        function () sys.rotInc(deck) end, 
        function () sys.rotDec(deck) end, 
        function () sys.rotTouch(deck) end,
        function () sys.rotTouch(deck) end
    )

    -- len
    ui._addSelectorButtons(
        rects[deck].len, 
        function () sys.lenInc(deck) end, 
        function () sys.lenDec(deck) end, 
        function () sys.lenTouch(deck) end,
        function () sys.lenTouch(deck) end
    )

    -- mem
    ui._addSelectorButtons(
        rects[deck].mem, 
        function () sys.memInc(deck) end, 
        function () sys.memDec(deck) end, 
        function () sys.memTouch(deck) end,
        function () sys.memTouch(deck) end
    )

    -- select deck
    table.insert(ui.buttons, Button(
        rects[deck].select, ui.cam, 
        function () sys.deckSelect(deck) end
    ))

end

function ui.init()

    -- bpm button
    ui._addSelectorButtons(
        rects.bpm, 
        sys.bpmInc, 
        sys.bpmDec, 
        sys.bpmTouch,
        sys.bpmTouch
    )

    -- exit button
    table.insert(ui.buttons, Button(rects.exit, ui.cam, ui._exit))

    ui._initDeck("left")
    ui._initDeck("right")

end

function ui.mousepressed(x, y, mouse_button, istouch)
    for i, button in ipairs(ui.buttons) do
        button:mousepressed(x, y, mouse_button, istouch)
    end
end

function ui._exit()
    -- TODO save program sys
    love.event.quit()
end

function ui.keypressed(key)
    if key == "escape" then
        ui._exit()
    end
end

function ui._drawField(fill_color, text_color, text, rect)
    local x, y, w, h = util.camAdjust(rect, ui.cam)
    love.graphics.setColor(unpack(fill_color))
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(unpack(text_color))
    love.graphics.print(text, x, y)
end

function ui._drawSelector(fill_color, text_color, text, rect)
    local x, y, w, h = util.camAdjust(rect, ui.cam)
    love.graphics.setColor(unpack(fill_color))
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(unpack(text_color))
    love.graphics.print("<", x, y) -- left arrow
    love.graphics.print(text, x + 8, y) -- text
    love.graphics.print(">", x + 32, y) -- left arrow
end

function ui._drawTrackButtons(deck, t)

    -- select track
    local color = colors.track[t].up_inactive
    if sys.getSelectedTrack(deck) == t then
        color = colors.track[t].down_selected
    end
    ui._drawField(color, colors.eigengrau, t, rects[deck].track[t]["select"])

    -- mute track
    if sys.getSelectedTrack(deck) == t then
        color = colors.track[t].up_selected
        if sys.player.setup[deck].mute[t] then
            color = colors.track[t].down_selected
        end
    else
        color = colors.track[t].up_inactive
        if sys.player.setup[deck].mute[t] then
            color = colors.track[t].down_inactive
        end
    end
    ui._drawField(color, colors.eigengrau, "M", rects[deck].track[t]["mute"])

    -- solo track
    if sys.getSelectedTrack(deck) == t then
        color = colors.track[t].up_selected
        if sys.player.setup[deck].solo == t then
            color = colors.track[t].down_selected
        end
    else -- inactive
        color = colors.track[t].up_inactive
        if sys.player.setup[deck].solo == t then
            color = colors.track[t].down_inactive
        end
    end
    ui._drawField(color, colors.eigengrau, "S", rects[deck].track[t]["solo"])
end

function ui.update(delta_time)

    -- move camera if needed
    local cx, cy = unpack(ui.cam)
    if sys.getSelectedDeck() == "right" then
        local tx, ty = unpack(CAM_RIGHT)
        cx = math.min(tx, cx + CAM_SPEED)
    else -- "left"
        local tx, ty = unpack(CAM_LEFT)
        cx = math.max(tx, cx - CAM_SPEED)
    end
    ui.cam[1] = cx
    ui.cam[2] = cy

    -- update buttons
    for i, button in ipairs(ui.buttons) do
        button:update(delta_time)
    end
end

function ui._drawDeck(d)

    local selected_track = sys.getSelectedTrack()
    local track_color = colors.track[selected_track].up_selected
    local deck_color = colors[d].up_selected -- TODO handle not selected

    local label = sys.volDisplay(d)
    ui._drawSelector(track_color, colors.eigengrau, label, rects[d].vol) 
    
    label = sys.sndDisplay(d)
    ui._drawSelector(track_color, colors.eigengrau, label, rects[d].snd) 
    
    label = sys.numDisplay(d)
    ui._drawSelector(track_color, colors.eigengrau, label, rects[d].num) 

    label = sys.rotDisplay(d)
    ui._drawSelector(track_color, colors.eigengrau, label, rects[d].rot) 
    
    label = sys.lenDisplay(d)
    ui._drawSelector(deck_color, colors.eigengrau, label, rects[d].len) 
    
    label = sys.memDisplay(d)
    ui._drawSelector(deck_color, colors.eigengrau, label, rects[d].mem) 

    -- draw select
    local label = "L"
    if d == "right" then
        label = "R"
    end
    local color = colors[d].up_inactive
    if d == sys.getSelectedDeck() then
        local color = colors[d].down_selected
    end
    ui._drawField(color, colors.eigengrau, label, rects[d].select)
end

function ui.draw()

    -- background
    love.graphics.setColor(unpack(colors.eigengrau))
    love.graphics.rectangle("fill", 0, 0, gfx.WIDTH, gfx.HEIGHT)

    ui._drawField(colors.eigengrau, colors.white, "TANZBOY.IO", rects.logo)
    ui._drawField(colors.eigengrau, colors.white, "EXIT#", rects.exit)

    -- bmp
    ui._drawSelector(colors.eigengrau, colors.white,
                     sys.bpmDisplay(), rects.bpm)

    -- track buttons
    for t = 1, 4 do
        ui._drawTrackButtons("left", t)
        ui._drawTrackButtons("right", t)
    end

    ui._drawDeck("left")
    ui._drawDeck("right")

    -- TODO deck fader

    -- track orbits
    local d = sys.getSelectedDeck()
    local x, y, outer_r, orbit_delta = util.camAdjust(rects.atom, ui.cam)
    for t = 1, 4 do
        local orbit_r = outer_r - ((t-1) * orbit_delta)
        local rot_rs = outer_r - ((t-1) * orbit_delta) - orbit_delta / 2
        local rot_rf = outer_r - ((t-1) * orbit_delta) + orbit_delta / 2

        -- draw background circle
        local color = colors.gray
        if sys.getSelectedTrack() == t then
            color = colors.track[t].up_selected
        end
        love.graphics.setColor(unpack(color))
        love.graphics.circle("line", x, y, orbit_r, 64)

        -- draw orbit beat backgrounds
        local len = sys.getLen(d)
        local rot = sys.getRot(d, t)
        local rhythm = sys.getRhythm(d, t)
        for b = 1, len do

            -- TODO draw beats recently played
            
            local fraction = math.pi * 2 * ((b - 1) / (len))

            -- draw track rotation hand
            if rot == b-1 then
                local sdx, sdy = vector.rotate(fraction, 0.0, - rot_rs)
                local stx, sty = vector.add(x, y, sdx, sdy)
                local fdx, fdy = vector.rotate(fraction, 0.0, - rot_rf)
                local ftx, fty = vector.add(x, y, fdx, fdy)
                love.graphics.line(stx, sty, ftx, fty)
            end

            -- draw beat
            local dx, dy = vector.rotate(fraction, 0.0, - orbit_r)
            local tx, ty = vector.add(x, y, dx, dy)
            local r = 1.25
            if rhythm[b] ~= 0 then
                r = 2.25
            end
            love.graphics.circle("fill", tx, ty, r, 16)
        end
    end

    -- draw clock hand
    local progress = sys.getLoopProgress()
    local dx, dy = vector.rotate(math.pi *2.0 * progress, 0.0, - (outer_r+4))
    local tx, ty = vector.add(x, y, dx, dy)
    love.graphics.setColor(unpack(colors.gray))
    love.graphics.line(x, y, tx, ty)

    -- draw buttons
    for i, button in ipairs(ui.buttons) do
        button:draw()
    end

    -- TODO draw bars
end

return ui
