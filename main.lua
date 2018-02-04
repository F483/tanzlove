local Gamestate = require("lib.hump.gamestate")
local sys = require("src.sys")
local gfx = require("src.gfx")
local euclid = require("src.euclid")
local Studio = require("src.states.studio")

function love.load()
    gfx.init()
    sys.init()
    euclid.init()
    Gamestate.registerEvents()
    Gamestate.switch(Studio)
end

function love.draw()
    gfx.scale()
end

function love.update(delta_time)
    sys.update(delta_time)
end

function love.quit()
	sys.quit()
    return true
end
