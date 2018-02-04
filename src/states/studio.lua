local Gamestate = require("lib.hump.gamestate")
local colors = require("src.colors")
local gfx = require("src.gfx")
local Board = require("src.states.board")

local ENTER = 0.5 -- fade in time
local HOLD = 2.0 -- hold time
local LEAVE = 0.5 -- fade out time

local Studio = {}

function Studio:init()
    gfx.loadUniformSpriteSheet("studio", "gfx/studio.png")
    self.ttl = ENTER + LEAVE + HOLD
end

function Studio:update(delta_time)
    self.ttl = self.ttl - delta_time
    if self.ttl < 0 then
        Gamestate.switch(Board)
    end
end

function Studio:mousepressed(x, y, button, istouch)
    Gamestate.switch(Board) -- any key
end

function Studio:keypressed(key)
    Gamestate.switch(Board) -- any key
end

function Studio:draw()
    love.graphics.setColor(colors.white) 
    gfx.drawSprite("studio", 0, 0)

    -- fade in
    if self.ttl > (LEAVE + HOLD) then
        local progress = (self.ttl - HOLD - LEAVE) / ENTER
        gfx.colorScreen({22, 22, 29, progress * 255})
    end
    
    -- fade out
    if self.ttl < LEAVE then
        local progress = 1.0 - (self.ttl / LEAVE)
        gfx.colorScreen({22, 22, 29, progress * 255})
    end
end

return Studio
