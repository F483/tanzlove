local Gamestate = require("lib.hump.gamestate")
local Button = require("src.button")
local colors = require("src.colors")
local gfx = require("src.gfx")

local F483_URL = "https://twitter.com/fbarkhau"
local LUKE_URL = "https://twitter.com/Sadface_RL"

local Credits = {buttons={}}

function Credits:init()
    gfx.loadUniformSpriteSheet("credits", "gfx/credits.png")

    -- open fabe twitter
    table.insert(self.buttons, Button({0, 20, 160, 28}, {0, 0}, function () 
        love.system.openURL(F483_URL)
    end))
    
    -- open luke twitter
    table.insert(self.buttons, Button({0, 52, 160, 28}, {0, 0}, function ()
        love.system.openURL(LUKE_URL)
    end))

    -- back button
    table.insert(self.buttons, Button({62, 84, 36, 12}, {0, 0}, function ()
        Gamestate.pop()
    end))
end

function Credits:mousepressed(x, y, mouse_button, istouch)
    local handled = false
    for i, button in ipairs(self.buttons) do
        handled = handled or button:mousepressed(x, y, mouse_button, istouch)
    end
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
    for i, button in ipairs(self.buttons) do
        button:draw()
    end
end

return Credits
