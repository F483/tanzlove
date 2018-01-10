local gfx = require("src.gfx")
local state = require("src.state")
local ui = require("src.ui")

function love.mousepressed(x, y, button, istouch)
    ui.mousepressed(x, y, button, istouch)
end

function love.keypressed(key)
    ui.keypressed(key)
end

function love.load()
    gfx.init()
    ui.init()
    -- TODO load samples and loops
end

function love.draw()
    gfx.scale()
    ui.draw()
end

function love.update(delta_time)
    state.update(delta_time)
    ui.update(delta_time)
end
