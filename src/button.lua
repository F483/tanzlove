local Class = require('lib.hump.class')
local gfx = require('src.gfx')

local COLOR_MOUSE_OVER = {255, 255, 255, 64}
local COLOR_MOUSE_DOWN = {255, 255, 255, 128}

local Button = Class{}

function Button:init(rect, camera, onPress, onMouseOver)
    self.rect = rect
    self.camera = camera -- TODO use it
    self.onPress = onPress
    self.onMouseOver = onMouseOver -- TODO use it
end

function Button:overButton(x, y)
    local bx, by, bw, bh = unpack(self.rect)
    return x >= bx and x < bx + bw and y >= by and y < by + bh 
end

function Button:mousereleased(x, y, button)
    local mx, my = unpack(gfx.fromWinPos({x, y}))
    if button == 1 and self:overButton(mx, my) then
        self.onPress()
        return true
    end
    return false
end

function Button:draw()
    local mx, my = unpack(gfx.fromWinPos({love.mouse.getPosition()}))
    local mouse_over = self:overButton(mx, my)
    local mouse_down = love.mouse.isDown(1)
    if mouse_over and mouse_down then
        love.graphics.setColor(unpack(COLOR_MOUSE_DOWN))
        love.graphics.rectangle("fill", unpack(self.rect))
    elseif mouse_over and not mouse_down then
        love.graphics.setColor(unpack(COLOR_MOUSE_OVER))
        love.graphics.rectangle("fill", unpack(self.rect))
    end
end

return Button
