local Gamestate = require("lib.hump.gamestate")
local Button = require("src.button")
local colors = require("src.colors")
local gfx = require("src.gfx")

local F483_URL = "https://twitter.com/fbarkhau"
local LUKE_URL = "https://twitter.com/Sadface_RL"

local Credits = {}

function Credits:init()
    gfx.loadUniformSpriteSheet("credits", "gfx/credits.png")
    self.button_fabe = Button({0, 20, 160, 28}, {0, 0}, function ()
        love.system.openURL(F483_URL)
    end)
    self.button_luke = Button({0, 52, 160, 28}, {0, 0}, function ()
        love.system.openURL(LUKE_URL)
    end)
    self.button_back = Button({62, 86, 36, 12}, {0, 0}, function ()
        Gamestate.pop()
    end)
end

function Credits:mousepressed(x, y, button, istouch)
    local handled = false
    handled = handled or self.button_fabe:mousepressed(x, y, button, istouch)
    handled = handled or self.button_luke:mousepressed(x, y, button, istouch)
    handled = handled or self.button_back:mousepressed(x, y, button, istouch)
    if not handled then
        Gamestate.pop()
    end
end

function Credits:keypressed(key)
    if key == "escape" then
        Gamestate.pop()
    end
end

function Credits:draw()
    love.graphics.setColor(colors.white) 
    gfx.drawSprite("credits", 0, 0)
    self.button_fabe:draw()
    self.button_luke:draw()
    self.button_back:draw()
end

return Credits
