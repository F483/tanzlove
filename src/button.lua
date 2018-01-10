local Class = require('lib.hump.class')
local gfx = require('src.gfx')
local util = require('src.util')

local COLOR_MOUSE_OVER = {255, 255, 255, 64}
local COLOR_MOUSE_DOWN = {255, 255, 255, 128}

local Button = Class{}

function Button:init(rect, cam, onPress, onMouseOver)
    self.rect = rect
    self.cam = cam
    self.onPress = onPress
    self.onMouseOver = onMouseOver
end

function Button:_overButton(x, y)
    local bx, by, bw, bh = util.camAdjust(self.rect, self.cam)
    return x >= bx and x < bx + bw and y >= by and y < by + bh 
end

function Button:mousepressed(x, y, button, istouch)
    local mx, my = unpack(gfx.fromWinPos({x, y}))
    if button == 1 and self:_overButton(mx, my) then
        self.onPress()
        return true
    end
    return false
end

function Button:update(delta_time)
    local mx, my = unpack(gfx.fromWinPos({love.mouse.getPosition()}))
    local mouse_over = self:_overButton(mx, my)
    if mouse_over and self.onMouseOver ~= nil then
        self.onMouseOver()
    end
end

function Button:draw()
    local mx, my = unpack(gfx.fromWinPos({love.mouse.getPosition()}))
    local mouse_over = self:_overButton(mx, my)
    local mouse_down = love.mouse.isDown(1)
    if mouse_over and mouse_down then
        love.graphics.setColor(unpack(COLOR_MOUSE_DOWN))
        love.graphics.rectangle("fill", util.camAdjust(self.rect, self.cam))
    elseif mouse_over and not mouse_down then
        love.graphics.setColor(unpack(COLOR_MOUSE_OVER))
        love.graphics.rectangle("fill", util.camAdjust(self.rect, self.cam))
    end
end

return Button
