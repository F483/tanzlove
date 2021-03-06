local Gamestate = require("lib.hump.gamestate")
local Button = require("src.button")
local colors = require("src.colors")
local gfx = require("src.gfx")
local Credits = require("src.states.credits")

-- Android app urls
-- https://play.google.com/store/apps/details?id=love.tanz
-- market://details?id=love.tanz

local RATEAPP_URL = {}
RATEAPP_URL["OS X"] = "http://f483.itch.io/tanzlove"
RATEAPP_URL["Windows"] = "http://f483.itch.io/tanzlove"
RATEAPP_URL["Linux"] = "http://f483.itch.io/tanzlove"
RATEAPP_URL["Android"] = "market://details?id=love.tanz"
RATEAPP_URL["iOS"] = "http://f483.itch.io/tanzlove" -- FIXME link to app store instead

local GITHUB_URL = "https://github.com/F483/tanzlove"
local TWITTER_URL = "https://twitter.com/home?status=http%3A//tanz.love"
local FACEBOOK_URL = "https://www.facebook.com/sharer/sharer.php?u=http%3A//tanz.love"

local Final = {buttons={}}

function Final:init()
    gfx.loadUniformSpriteSheet("exit", "gfx/final.png")

    -- rate app
    table.insert(self.buttons, Button({40, 4, 80, 12}, {0, 0}, function () 
        love.system.openURL(RATEAPP_URL[love.system.getOS()])
    end))

    -- facebook
    table.insert(self.buttons, Button({40, 20, 80, 12}, {0, 0}, function () 
        love.system.openURL(FACEBOOK_URL)
    end))

    -- twitter
    table.insert(self.buttons, Button({44, 36, 72, 12}, {0, 0}, function () 
        love.system.openURL(TWITTER_URL)
    end))

	-- github 
    table.insert(self.buttons, Button({48, 52, 64, 12}, {0, 0}, function () 
        love.system.openURL(GITHUB_URL)
    end))

    -- credits
    table.insert(self.buttons, Button({50, 68, 60, 12}, {0, 0}, function () 
        Gamestate.push(Credits)
    end))

    -- quit
    table.insert(self.buttons, Button({62, 84, 36, 12}, {0, 0}, function () 
        love.event.quit()
    end))
end

function Final:mousepressed(x, y, mouse_button, istouch)
    local handled = false
    for i, button in ipairs(self.buttons) do
        handled = handled or button:mousepressed(x, y, mouse_button, istouch)
    end
    if not handled then
        love.event.quit()
    end
end

function Final:keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function Final:draw()
    love.graphics.setColor(colors.white) 
    gfx.drawSprite("exit", 0, 0)
    for i, button in ipairs(self.buttons) do
        button:draw()
    end
end

return Final
