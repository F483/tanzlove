local gfx = require("src.gfx")
local util = require("src.util")
local player = require("src.player")
local state = require("src.state")
local colors = require("src.colors")
local rects = require("src.rects")
local Button = require("src.button")

local SHOW_TIME = 1.0 -- seconds

-- board
local WIDTH = 236
local HEIGHT = gfx.HEIGHT

-- camera
local CAM_SPEED = 2 -- pixel per second
local CAM_LEFT = {0, 0}
local CAM_RIGHT = {76, 0}

-- interface state
local ui = {
    cam = util.deepCopy(CAM_LEFT),
    buttons = {}
}

function ui._addSelectorButtons(rect, onInc, onDec, onShow)
    local x, y, w, h = unpack(rect)
    local dec = Button({x, y, 8, 8}, ui.cam, function () 
        onDec() -- decrement value
        onShow() -- show new value
    end)
    local show = Button({x + 8, y, 24, 8}, ui.cam, onShow, onShow, false, false)
    local inc = Button({x + 8 + 24, y, 8, 8}, ui.cam, function () 
        onInc() -- increment value
        onShow() -- show new value
    end)
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
            function () state.trackSelect(ui, deck, t) end
        ))

        -- mute
        table.insert(ui.buttons, Button(
            rects[deck].track[t].mute, ui.cam, 
            function () state.toggleMute(deck, t) end
        ))

        -- solo
        table.insert(ui.buttons, Button(
            rects[deck].track[t].solo, ui.cam, 
            function () state.toggleSolo(deck, t) end
        ))

    end

    -- vol
    ui._addSelectorButtons(
        rects[deck].vol, 
        function () state.volInc(deck) end, 
        function () state.volDec(deck) end, 
        function () state.volShow(deck) end
    )

    -- snd
    ui._addSelectorButtons(
        rects[deck].snd, 
        function () state.sndInc(deck) end, 
        function () state.sndDec(deck) end, 
        function () state.sndShow(deck) end
    )

    -- num
    ui._addSelectorButtons(
        rects[deck].num, 
        function () state.numInc(deck) end, 
        function () state.numDec(deck) end, 
        function () state.numShow(deck) end
    )

    -- rot
    ui._addSelectorButtons(
        rects[deck].rot, 
        function () state.rotInc(deck) end, 
        function () state.rotDec(deck) end, 
        function () state.rotShow(deck) end
    )

    -- len
    ui._addSelectorButtons(
        rects[deck].len, 
        function () state.lenInc(deck) end, 
        function () state.lenDec(deck) end, 
        function () state.lenShow(deck) end
    )

    -- mem
    ui._addSelectorButtons(
        rects[deck].mem, 
        function () state.memInc(deck) end, 
        function () state.memDec(deck) end, 
        function () state.memShow(deck) end
    )

    -- select deck
    table.insert(ui.buttons, Button(
        rects[deck].select, ui.cam, function () state.deck = deck end
    ))

end

function ui.init()

    -- bpm button
    ui._addSelectorButtons(
        rects.bpm, 
        state.bpmInc, 
        state.bpmDec, 
        state.bpmShow
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
    -- TODO save program state
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
    if state.selected[deck] == t then
        color = colors.track[t].down_selected
    end
    ui._drawField(color, colors.eigengrau, t, rects[deck].track[t]["select"])

    -- mute track
    if state.selected[deck] == t then
        color = colors.track[t].up_selected
        if player.setup[deck].mute[t] then
            color = colors.track[t].down_selected
        end
    else
        color = colors.track[t].up_inactive
        if player.setup[deck].mute[t] then
            color = colors.track[t].down_inactive
        end
    end
    ui._drawField(color, colors.eigengrau, "M", rects[deck].track[t]["mute"])

    -- solo track
    if state.selected[deck] == t then
        color = colors.track[t].up_selected
        if player.setup[deck].solo == t then
            color = colors.track[t].down_selected
        end
    else -- inactive
        color = colors.track[t].up_inactive
        if player.setup[deck].solo == t then
            color = colors.track[t].down_inactive
        end
    end
    ui._drawField(color, colors.eigengrau, "S", rects[deck].track[t]["solo"])
end

function ui.update(delta_time)

    -- move camera if needed
    local cx, cy = unpack(ui.cam)
    if state.deck == "right" then
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

function ui._drawDeck(deck)

    local track_color = colors.track[state.selected[deck]].up_selected
    local deck_color = colors[deck].up_selected -- TODO handle not selected

    -- TODO desplay current value if recent mouseover or press
    ui._drawSelector(track_color, colors.eigengrau, "VOL", rects[deck].vol) 
    
    -- TODO desplay current value if recent mouseover or press
    ui._drawSelector(track_color, colors.eigengrau, "SND", rects[deck].snd) 
    
    -- TODO desplay current value if recent mouseover or press
    ui._drawSelector(track_color, colors.eigengrau, "NUM", rects[deck].num) 

    -- TODO desplay current value if recent mouseover or press
    ui._drawSelector(track_color, colors.eigengrau, "ROT", rects[deck].rot) 
    
    -- TODO desplay current value if recent mouseover or press
    ui._drawSelector(deck_color, colors.eigengrau, "LEN", rects[deck].len) 
    
    -- TODO desplay current value if recent mouseover or press
    ui._drawSelector(deck_color, colors.eigengrau, "MEM", rects[deck].mem) 

    -- draw select
    local label = "L"
    if deck == "right" then
        label = "R"
    end
    local color = colors[deck].up_inactive
    if deck == state.deck then
        local color = colors[deck].down_selected
    end
    ui._drawField(color, colors.eigengrau, label, rects[deck].select)
end

function ui.draw()

    -- background
    love.graphics.setColor(unpack(colors.eigengrau))
    love.graphics.rectangle("fill", 0, 0, gfx.WIDTH, gfx.HEIGHT)

    ui._drawField(colors.eigengrau, colors.white, "TANZBOY.IO", rects.logo)
    ui._drawField(colors.eigengrau, colors.white, "EXIT#", rects.exit)

    -- bmp
    if state.show_ttls.bpm > 0.0 then
        local label = string.format("%03d", player.setup.bpm)
        ui._drawSelector(colors.eigengrau, colors.white, label, rects.bpm) 
    else
        ui._drawSelector(colors.eigengrau, colors.white, "BPM", rects.bpm) 
    end

    -- track buttons
    for t = 1, 4 do
        ui._drawTrackButtons("left", t)
        ui._drawTrackButtons("right", t)
    end

    ui._drawDeck("left")
    ui._drawDeck("right")

    -- TODO deck fader
    

    -- track orbits
    local x, y, r, d = util.camAdjust(rects.atom, ui.cam)
    for t = 1, 4 do
        local color = colors.gray
        if state.selected[state.deck] == t then
            color = colors.track[t].up_selected
        end
        love.graphics.setColor(unpack(color))
        love.graphics.circle("line", x, y, r - ((t-1) * d))
    end

    -- draw buttons
    for i, button in ipairs(ui.buttons) do
        button:draw()
    end

    -- TODO draw bars
end

return ui
