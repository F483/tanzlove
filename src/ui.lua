local gfx = require("src.gfx")
local util = require("src.util")
local player = require("src.player")
local Button = require("src.button")

local SHOW_TIME = 1.0 -- seconds

-- board
local WIDTH = 236
local HEIGHT = gfx.HEIGHT

-- camera
local CAM_SPEED = 2 -- pixel per second
local CAM_LEFT = {0, 0}
local CAM_RIGHT = {76, 0}

local COLORS = {
    eigengrau = {22, 22, 29},
    black = {0, 0, 0},
    white = {255, 255, 255},
    gray = {127, 127, 127},
    track = {
        {
            up_selected={gfx.hsv2rgb(255*(1/6), (2/3)*255, (4/4)*255)},
            down_selected={gfx.hsv2rgb(255*(1/6), (2/3)*255, (2/4)*255)},
            up_inactive={gfx.hsv2rgb(255*(1/6), (2/3)*255, (3/4)*255)},
            down_inactive={gfx.hsv2rgb(255*(1/6), (2/3)*255, (1/4)*255)},
        },
        {
            up_selected={gfx.hsv2rgb(255*(4/6), (2/3)*255, (4/4)*255)},
            down_selected={gfx.hsv2rgb(255*(4/6), (2/3)*255, (2/4)*255)},
            up_inactive={gfx.hsv2rgb(255*(4/6), (2/3)*255, (3/4)*255)},
            down_inactive={gfx.hsv2rgb(255*(4/6), (2/3)*255, (1/4)*255)},
        },
        {
            up_selected={gfx.hsv2rgb(255*(3/6), (2/3)*255, (4/4)*255)},
            down_selected={gfx.hsv2rgb(255*(3/6), (2/3)*255, (2/4)*255)},
            up_inactive={gfx.hsv2rgb(255*(3/6), (2/3)*255, (3/4)*255)},
            down_inactive={gfx.hsv2rgb(255*(3/6), (2/3)*255, (1/4)*255)},
        },
        {
            up_selected={gfx.hsv2rgb(255*(6/6), (2/3)*255, (4/4)*255)},
            down_selected={gfx.hsv2rgb(255*(6/6), (2/3)*255, (2/4)*255)},
            up_inactive={gfx.hsv2rgb(255*(6/6), (2/3)*255, (3/4)*255)},
            down_inactive={gfx.hsv2rgb(255*(6/6), (2/3)*255, (1/4)*255)},
        },
    },
    deck = {
        left = {
            up_selected={gfx.hsv2rgb(255*(2/6), (2/3)*255, (4/4)*255)},
            down_selected={gfx.hsv2rgb(255*(2/6), (2/3)*255, (2/4)*255)},
            up_inactive={gfx.hsv2rgb(255*(2/6), (2/3)*255, (3/4)*255)},
            down_inactive={gfx.hsv2rgb(255*(2/6), (2/3)*255, (1/4)*255)},
        },
        right = {
            up_selected={gfx.hsv2rgb(255*(5/6), (2/3)*255, (4/4)*255)},
            down_selected={gfx.hsv2rgb(255*(5/6), (2/3)*255, (2/4)*255)},
            up_inactive={gfx.hsv2rgb(255*(5/6), (2/3)*255, (3/4)*255)},
            down_inactive={gfx.hsv2rgb(255*(5/6), (2/3)*255, (1/4)*255)},

        }
    }
}

local RECTS = {
    logo = {80, 4, 76, 8},
    atom = {118, 50, 34, 6}, -- x, y, radius, delta
    exit = {4, 4, 40, 8},
    bpm = {192, 4, 40, 8},
    left = {
        select = {80, 88, 8, 8},
        vol = {4, 4 + 12 * 2, 40, 8},
        snd = {4, 4 + 12 * 3, 40, 8},
        num = {4, 4 + 12 * 4, 40, 8},
        rot = {4, 4 + 12 * 5, 40, 8},
        len = {4 + 32, 4 + 12 * 6, 40, 8},
        mem = {4 + 32, 4 + 12 * 7, 40, 8},
        track = {
            {
                select = {68, 4 + 12 * 2, 8, 8},
                mute = {56, 4 + 12 * 2, 8, 8},
                solo = {48, 4 + 12 * 2, 8, 8},
            },
            {
                select = {68, 4 + 12 * 3, 8, 8},
                mute = {56, 4 + 12 * 3, 8, 8},
                solo = {48, 4 + 12 * 3, 8, 8},
            },
            {
                select = {68, 4 + 12 * 4, 8, 8},
                mute = {56, 4 + 12 * 4, 8, 8},
                solo = {48, 4 + 12 * 4, 8, 8},
            },
            {
                select = {68, 4 + 12 * 5, 8, 8},
                mute = {56, 4 + 12 * 5, 8, 8},
                solo = {48, 4 + 12 * 5, 8, 8},
            },
        }
    },
    right = {
        select = {148, 88, 8, 8},
        vol = {192, 4 + 12 * 2, 40, 8},
        snd = {192, 4 + 12 * 3, 40, 8},
        num = {192, 4 + 12 * 4, 40, 8},
        rot = {192, 4 + 12 * 5, 40, 8},
        len = {192 - 32, 4 + 12 * 6, 40, 8},
        mem = {192 - 32, 4 + 12 * 7, 40, 8},
        track = {
            {
                select = {160, 4 + 12 * 2, 8, 8},
                mute = {172, 4 + 12 * 2, 8, 8},
                solo = {180, 4 + 12 * 2, 8, 8},
            },
            {
                select = {160, 4 + 12 * 3, 8, 8},
                mute = {172, 4 + 12 * 3, 8, 8},
                solo = {180, 4 + 12 * 3, 8, 8},
            },
            {
                select = {160, 4 + 12 * 4, 8, 8},
                mute = {172, 4 + 12 * 4, 8, 8},
                solo = {180, 4 + 12 * 4, 8, 8},
            },
            {
                select = {160, 4 + 12 * 5, 8, 8},
                mute = {172, 4 + 12 * 5, 8, 8},
                solo = {180, 4 + 12 * 5, 8, 8},
            },
        }
    }
}


-- interface state
local ui = {
    cam = util.deepCopy(CAM_LEFT),
    deck = "right", -- or left
    selected = {
        left = 1,
        right = 2
    },
    show_ttls = {
        bpm = 0.0,
        left = {len=0.0, mem=0.0, vol=0.0, snd=0.0, num=0.0, rot=0.0},
        right = {len=0.0, mem=0.0, vol=0.0, snd=0.0, num=0.0, rot=0.0}
    },
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

function ui._toggleSolo(deck, track)
    if player.setup.deck[deck].solo == track then
        player.setup.deck[deck].solo = nil
    else
        player.setup.deck[deck].solo = track
    end
end

function ui._toggleMute(deck, track)
    local current_value = player.setup.deck[deck].mute[track]
    player.setup.deck[deck].mute[track] = not current_value
end

function ui._initDeck(deck)

    -- track buttons
    for t = 1, 4 do

        -- select
        table.insert(ui.buttons, Button(
            RECTS[deck].track[t].select, ui.cam, 
            function () ui.selected[deck] = t end
        ))

        -- mute
        table.insert(ui.buttons, Button(
            RECTS[deck].track[t].mute, ui.cam, 
            function () ui._toggleMute(deck, t) end
        ))

        -- solo
        table.insert(ui.buttons, Button(
            RECTS[deck].track[t].solo, ui.cam, 
            function () ui._toggleSolo(deck, t) end
        ))

    end

    -- select deck
    table.insert(ui.buttons, Button(
        RECTS[deck].select, ui.cam, function () ui.deck = deck end
    ))

end

function ui.bpmInc()
    player.setup.bpm = math.min(player.setup.bpm + 1, player.limits.bpm.max)
end

function ui.bpmDec()
    player.setup.bpm = math.max(player.setup.bpm - 1, player.limits.bpm.min)
end

function ui.bpmShow()
    ui.show_ttls.bpm = SHOW_TIME
end

function ui.init()

    -- bpm button
    ui._addSelectorButtons(RECTS.bpm, ui.bpmInc, ui.bpmDec, ui.bpmShow)


    ui._initDeck("left")
    ui._initDeck("right")

end

function ui.mousepressed(x, y, mouse_button, istouch)
    for i, button in ipairs(ui.buttons) do
        button:mousepressed(x, y, mouse_button, istouch)
    end
end

function ui.keypressed(key)
    -- TODO save program state
    if key == "escape" then
        love.event.quit()
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
    local color = COLORS.track[t].up_inactive
    if ui.selected[deck] == t then
        color = COLORS.track[t].down_selected
    end
    ui._drawField(color, COLORS.eigengrau, t, RECTS[deck].track[t]["select"])

    -- mute track
    if ui.selected[deck] == t then
        color = COLORS.track[t].up_selected
        if player.setup.deck[deck].mute[t] then
            color = COLORS.track[t].down_selected
        end
    else
        color = COLORS.track[t].up_inactive
        if player.setup.deck[deck].mute[t] then
            color = COLORS.track[t].down_inactive
        end
    end
    ui._drawField(color, COLORS.eigengrau, "M", RECTS[deck].track[t]["mute"])

    -- solo track
    if ui.selected[deck] == t then
        color = COLORS.track[t].up_selected
        if player.setup.deck[deck].solo == t then
            color = COLORS.track[t].down_selected
        end
    else -- inactive
        color = COLORS.track[t].up_inactive
        if player.setup.deck[deck].solo == t then
            color = COLORS.track[t].down_inactive
        end
    end
    ui._drawField(color, COLORS.eigengrau, "S", RECTS[deck].track[t]["solo"])
end

function ui.update(delta_time)

    -- move camera if needed
    local cx, cy = unpack(ui.cam)
    if ui.deck == "right" then
        local tx, ty = unpack(CAM_RIGHT)
        cx = math.min(tx, cx + CAM_SPEED)
    else -- "left"
        local tx, ty = unpack(CAM_LEFT)
        cx = math.max(tx, cx - CAM_SPEED)
    end
    ui.cam[1] = cx
    ui.cam[2] = cy

    -- update show ttls
    ui.show_ttls.bpm = math.max(0.0, ui.show_ttls.bpm - delta_time)
    ui.show_ttls.left.len = math.max(0.0, ui.show_ttls.left.len - delta_time)
    ui.show_ttls.left.mem = math.max(0.0, ui.show_ttls.left.mem - delta_time)
    ui.show_ttls.left.vol = math.max(0.0, ui.show_ttls.left.vol - delta_time)
    ui.show_ttls.left.snd = math.max(0.0, ui.show_ttls.left.snd - delta_time)
    ui.show_ttls.left.num = math.max(0.0, ui.show_ttls.left.num - delta_time)
    ui.show_ttls.left.rot = math.max(0.0, ui.show_ttls.left.rot - delta_time)
    ui.show_ttls.right.len = math.max(0.0, ui.show_ttls.right.len - delta_time)
    ui.show_ttls.right.mem = math.max(0.0, ui.show_ttls.right.mem - delta_time)
    ui.show_ttls.right.vol = math.max(0.0, ui.show_ttls.right.vol - delta_time)
    ui.show_ttls.right.snd = math.max(0.0, ui.show_ttls.right.snd - delta_time)
    ui.show_ttls.right.num = math.max(0.0, ui.show_ttls.right.num - delta_time)
    ui.show_ttls.right.rot = math.max(0.0, ui.show_ttls.right.rot - delta_time)

    -- update buttons
    for i, button in ipairs(ui.buttons) do
        button:update(delta_time)
    end
end

function ui._drawDeck(deck)

    local track_color = COLORS.track[ui.selected[deck]].up_selected
    local deck_color = COLORS.deck[deck].up_selected -- TODO handle not selected

    -- TODO desplay current value if recent mouseover or press
    ui._drawSelector(track_color, COLORS.eigengrau, "VOL", RECTS[deck].vol) 
    
    -- TODO desplay current value if recent mouseover or press
    ui._drawSelector(track_color, COLORS.eigengrau, "SND", RECTS[deck].snd) 
    
    -- TODO desplay current value if recent mouseover or press
    ui._drawSelector(track_color, COLORS.eigengrau, "NUM", RECTS[deck].num) 

    -- TODO desplay current value if recent mouseover or press
    ui._drawSelector(track_color, COLORS.eigengrau, "ROT", RECTS[deck].rot) 
    
    -- TODO desplay current value if recent mouseover or press
    ui._drawSelector(deck_color, COLORS.eigengrau, "LEN", RECTS[deck].len) 
    
    -- TODO desplay current value if recent mouseover or press
    ui._drawSelector(deck_color, COLORS.eigengrau, "MEM", RECTS[deck].mem) 

    -- draw select
    local label = "L"
    if deck == "right" then
        label = "R"
    end
    local color = COLORS.deck[deck].up_inactive
    if deck == ui.deck then
        local color = COLORS.deck[deck].down_selected
    end
    ui._drawField(color, COLORS.eigengrau, label, RECTS[deck].select)
end

function ui.draw()

    -- background
    love.graphics.setColor(unpack(COLORS.eigengrau))
    love.graphics.rectangle("fill", 0, 0, gfx.WIDTH, gfx.HEIGHT)

    ui._drawField(COLORS.eigengrau, COLORS.white, "TANZBOY.IO", RECTS.logo)
    ui._drawField(COLORS.eigengrau, COLORS.white, "EXIT#", RECTS.exit)

    -- bmp
    if ui.show_ttls.bpm > 0.0 then
        local label = string.format("%03d", player.setup.bpm)
        ui._drawSelector(COLORS.eigengrau, COLORS.white, label, RECTS.bpm) 
    else
        ui._drawSelector(COLORS.eigengrau, COLORS.white, "BPM", RECTS.bpm) 
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
    local x, y, r, d = util.camAdjust(RECTS.atom, ui.cam)
    for t = 1, 4 do
        local color = COLORS.gray
        if ui.selected[ui.deck] == t then
            color = COLORS.track[t].up_selected
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
