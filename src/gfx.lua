local Class = require('lib.hump.class')


local gfx = {

    -- internal screen width and height
    WIDTH = 160,
    HEIGHT = 100,
}

-- Converts HSV to RGB. (input and output range: 0 - 255)
-- From: https://love2d.org/wiki/HSV_color
function gfx.hsv2rgb(h, s, v)
    if s <= 0 then
        return v,v,v
    end
    h, s, v = h/256*6, s/255, v/255
    local c = v*s
    local x = (1-math.abs((h%2)-1))*c
    local m,r,g,b = (v-c), 0,0,0
    if h < 1 then
        r,g,b = c,x,0
    elseif h < 2 then
        r,g,b = x,c,0
    elseif h < 3 then
        r,g,b = 0,c,x
    elseif h < 4 then
        r,g,b = 0,x,c
    elseif h < 5 then
        r,g,b = x,0,c
    else
        r,g,b = c,0,x
    end
    return (r+m)*255,(g+m)*255,(b+m)*255
end

function gfx.init()

    -- load fonts
    gfx.font = love.graphics.newImageFont("gfx/font.png",
        " !\"#$%&'()*+,-./0123456789:;<=>?@" ..
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ[\"]^_`" ..
        "abcdefghijklmnopqrstuvwxyz{|}~"
    )
	gfx.font:setFilter("nearest")
	love.graphics.setFont(gfx.font)
end

function gfx._getResizeArgs()
    local win_w = love.graphics.getWidth()
    local win_h = love.graphics.getHeight()
    local gfx_w = gfx.WIDTH
    local gfx_h = gfx.HEIGHT
    local landscape_rd = (win_w / win_h) - (gfx_w / gfx_h)
    local portait_rd = (win_h / win_w) - (gfx_h / gfx_w)
    if math.abs(landscape_rd) < 0.18 and math.abs(portait_rd) < 0.18 then
        local sx = win_w / gfx_w
        local sy = win_h / gfx_h
        return 0, 0, sx, sy
    elseif landscape_rd > 0 then -- vertical bars
        local sy = win_h / gfx_h
        local sx = sy
        local ox = ((win_w / sx) - gfx_w) / 2
        local oy = 0
        return ox, oy, sx, sy
    else -- horizontal bars
        local sx = win_w / gfx_w
        local sy = sx
        local ox = 0
        local oy = ((win_h / sy) - gfx_h) / 2
        return ox, oy, sx, sy
    end
end

function gfx.fromWinX(win_x)
    local ox, oy, sx, sy = gfx._getResizeArgs()
    return (win_x / sx) - ox
end

function gfx.fromWinY(win_y)
    local ox, oy, sx, sy = gfx._getResizeArgs()
    return (win_y / sy) - oy
end

function gfx.fromWinW(win_w)
    return gfx.fromWinX(win_w)
end

function gfx.fromWinH(win_h)
    return gfx.fromWinY(win_h)
end

function gfx.fromWinPos(win_pos)
    local win_x, win_y = unpack(win_pos)
    local ox, oy, sx, sy = gfx._getResizeArgs()
    return {(win_x / sx) - ox, (win_y / sy) - oy}
end

function gfx.fromWinRect(rect)
    local x, y, w, h = unpack(rect)
    return {
        gfx.fromWinX(x), gfx.fromWinY(y),
        gfx.fromWinW(w), gfx.fromWinH(h)
    }
end

function gfx.scale()
    local ox, oy, sx, sy = gfx._getResizeArgs()
    love.graphics.scale(sx, sy)
    love.graphics.translate(ox, oy)
end

return gfx
