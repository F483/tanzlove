local Class = require('lib.hump.class')
local gfx = require('src.gfx')
local util = require('src.util')

local COLOR_MOUSE_OVER = {255, 255, 255, 31}
local COLOR_MOUSE_DOWN = {255, 255, 255, 65}

local Button = Class{}

function Button:init(rect, cam, onPress, drawPress, drawOver)
    self.rect = rect
    self.cam = cam
    self.onPress = onPress
    self.drawPress = drawPress == nil or drawPress == true -- default to true
    self.drawOver = drawOver == nil or drawOver == true -- default to true
end

function Button:_overButton(x, y)
    return util.overRect(x, y, self.rect, self.cam)
end

function Button:mousepressed(x, y, button, istouch)
    local mx, my = unpack(gfx.fromWinPos({x, y}))
    if button == 1 and self:_overButton(mx, my) then
        self.onPress()
        return true
    end
    return false
end

function Button:draw()
    local mx, my = unpack(gfx.fromWinPos({love.mouse.getPosition()}))
    local mouse_over = self:_overButton(mx, my)
    local mouse_down = love.mouse.isDown(1)
    if mouse_over and mouse_down and self.drawPress then
        love.graphics.setColor(unpack(COLOR_MOUSE_DOWN))
        love.graphics.rectangle("fill", util.camAdjustRect(self.rect, self.cam))
    elseif mouse_over and not mouse_down and self.drawOver then
        love.graphics.setColor(unpack(COLOR_MOUSE_OVER))
        love.graphics.rectangle("fill", util.camAdjustRect(self.rect, self.cam))
    end
end

return Button
