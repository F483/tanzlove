local Class = require('lib.hump.class')


local gfx = {

    -- internal screen width and height
    width = 160,
    height = 100,

    sprites = {}
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
    local gfx_w = gfx.width
    local gfx_h = gfx.height
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

function gfx.colorScreen(color)
    local ox, oy, sx, sy = gfx._getResizeArgs()
    local w = gfx.width + ox * 2
    local h = gfx.height + oy * 2
    local prev = {love.graphics.getColor()}
    love.graphics.setColor(unpack(color))
    love.graphics.rectangle("fill", -ox, -oy, w, h)
    love.graphics.setColor(unpack(prev))
end

function gfx.loadUniformSpriteSheet(name, path, width, height)

    local width = width or 1
    local height = height or 1
    local img = love.graphics.newImage(path)
    local iw, ih = img:getDimensions()
    img:setFilter("nearest")

    -- sprite quads lookup table
    local quads = {}
    for x=1, width do
        quads[x] = {}
        for y=1, height do
            local qw = iw / width
            local qh = ih / height
            local qx = qw * (x - 1)
            local qy = qh * (y - 1)
            quads[x][y] = love.graphics.newQuad(qx, qy, qw, qh, iw, ih)
        end
    end

    gfx.sprites[name] = {img=img, quads=quads}
end

function gfx.drawSprite(name, x, y, sx, sy, r)

    -- set default values
    local r = r or 0
    local sx = sx or 1
    local sy = sy or 1

    -- position top-left and rotate in place
    local sprite = gfx.sprites[name]
    local quad = sprite.quads[sx][sy]
    local qx, qy, qw, qh = quad:getViewport()
    local ox, oy = qw * 0.5, qh * 0.5
    love.graphics.draw(sprite.img, quad, x + ox, y + oy, r, 1, 1, ox, oy)
end

return gfx
