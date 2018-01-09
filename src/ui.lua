local gfx = require("src.gfx")

-- board
local WIDTH = 236
local HEIGHT = gfx.HEIGHT

-- camera
local CAM_SPEED = 2 -- pixel per second
local CAM_LEFT = {0, 0}
local CAM_RIGHT = {76, 0}

-- base colors
local BLACK = {0, 0, 0}
local GRAY = {127, 127, 127}
local WHITE = {255, 255, 255}
local DESELECTED = {127, 127, 127}
local EIGENGRAU = {22, 22, 29}

local COLORS = {
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
        len = {4, 4 + 12 * 6, 40, 8},
        mem = {4, 4 + 12 * 7, 40, 8},
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
        len = {192, 4 + 12 * 6, 40, 8},
        mem = {192, 4 + 12 * 7, 40, 8},
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
    cam = CAM_LEFT,

    fade = 1.0, -- 0.0 => left, 1.0 => right
    deck = "right", -- or left
    left = {
        selected = 1,
        solo = nil,
        mute = {false, false, false, false, false, false, false, false},
    },
    right = {
        selected = 1,
        solo = nil,
        mute = {false, false, false, false, false, false, false, false},
    }
}

function ui.init()

    -- setup buttons
end

function ui.mousepressed(x, y, button, istouch)
end

function ui.keyreleased(key)
end

function ui.keypressed(key)
    -- TODO save program state
    if key == "escape" then
        love.event.quit()
    end
end

function ui.camAdjust(rx, ry, rw, rh)
    local cx, cy = unpack(ui.cam)
    return rx - cx, ry - cy, rw, rh
end

function ui._drawField(fill_color, text_color, text, rect)
    local x, y, w, h = ui.camAdjust(unpack(rect))
    love.graphics.setColor(unpack(fill_color))
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(unpack(text_color))
    love.graphics.print(text, x, y)

end

function ui._drawSelector(fill_color, text_color, text, rect)
    local x, y, w, h = ui.camAdjust(unpack(rect))
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
    if ui[deck].selected == t then
        color = COLORS.track[t].down_selected
    end
    ui._drawField(color, BLACK, t, RECTS[deck].track[t]["select"])

    -- mute track
    if ui[deck].selected == t then
        color = COLORS.track[t].up_selected
        if ui[deck].mute[t] then
            color = COLORS.track[t].down_selected
        end
    else
        color = COLORS.track[t].up_inactive
        if ui[deck].mute[t] then
            color = COLORS.track[t].down_inactive
        end
    end
    ui._drawField(color, BLACK, "M", RECTS[deck].track[t]["mute"])

    -- solo track
    if ui[deck].selected == t then
        color = COLORS.track[t].up_selected
        if ui[deck].solo == t then
            color = COLORS.track[t].down_selected
        end
    else
        color = COLORS.track[t].up_inactive
        if ui[deck].mute == t then
            color = COLORS.track[t].down_inactive
        end
    end
    ui._drawField(color, BLACK, "S", RECTS[deck].track[t]["solo"])
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
    ui.cam = {cx, cy}

end

function ui._drawDeckSelectors(deck)

    local track_color = COLORS.track[ui[deck].selected].up_selected
    local deck_color = COLORS.deck[deck].up_selected -- TODO handle not selected

    -- TODO desplay current value if recent mouseover or press
    ui._drawSelector(track_color, BLACK, "VOL", RECTS[deck].vol) 
    
    -- TODO desplay current value if recent mouseover or press
    ui._drawSelector(track_color, BLACK, "SND", RECTS[deck].snd) 
    
    -- TODO desplay current value if recent mouseover or press
    ui._drawSelector(track_color, BLACK, "NUM", RECTS[deck].num) 

    -- TODO desplay current value if recent mouseover or press
    ui._drawSelector(track_color, BLACK, "ROT", RECTS[deck].rot) 
    
    -- TODO desplay current value if recent mouseover or press
    ui._drawSelector(deck_color, BLACK, "LEN", RECTS[deck].len) 
    
    -- TODO desplay current value if recent mouseover or press
    ui._drawSelector(deck_color, BLACK, "MEM", RECTS[deck].mem) 
end

function ui.draw()

    -- background
    love.graphics.setColor(unpack(EIGENGRAU))
    love.graphics.rectangle("fill", 0, 0, gfx.WIDTH, gfx.HEIGHT)

    ui._drawField(BLACK, WHITE, "TANZBOY.IO", RECTS.logo) -- logo
    ui._drawField(BLACK, WHITE, "EXIT#", RECTS.exit) -- exit button

    -- TODO desplay current value if recent mouseover or press
    ui._drawSelector(BLACK, WHITE, "BPM", RECTS.bpm) 

    -- track buttons
    for t = 1, 4 do
        ui._drawTrackButtons("left", t)
        ui._drawTrackButtons("right", t)
    end

    ui._drawDeckSelectors("left")
    ui._drawDeckSelectors("right")

    -- left deck select
    local color = COLORS.deck.left.up_selected -- TODO landle not selected
    ui._drawField(color, BLACK, "L", RECTS.left.select)
    
    -- TODO deck fader
    
    -- right deck select
    local color = COLORS.deck.right.up_selected -- TODO landle not selected
    ui._drawField(color, BLACK, "L", RECTS.right.select)

    -- track orbits
    local x, y, r, d = ui.camAdjust(unpack(RECTS.atom))
    for t = 1, 4 do
        local color = GRAY
        if ui[ui.deck].selected == t then
            color = COLORS.track[t].up_selected
        end
        love.graphics.setColor(unpack(color))
        love.graphics.circle("line", x, y, r - ((t-1) * d))
    end

    -- TODO draw bars
end

return ui
