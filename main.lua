local Gamestate = require("lib.hump.gamestate")
local sys = require("src.sys")
local gfx = require("src.gfx")
local euclid = require("src.euclid")
local Studio = require("src.states.studio")

function love.load()
    gfx.init()
    -- board.init()
    sys.init()
    euclid.init()
    Gamestate.registerEvents()
    Gamestate.switch(Studio)
end

function love.draw()
    gfx.scale()
    -- board.draw()
end

function love.update(delta_time)
    sys.update(delta_time)
    -- board.update(delta_time)
end
