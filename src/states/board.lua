local Gamestate = require("lib.hump.gamestate")
local Final = require("src.states.final")
local gfx = require("src.gfx")
local vector = require("lib.hump.vector-light")
local util = require("src.util")
local sys = require("src.sys")
local colors = require("src.colors")
local lines = require("src.lines")
local rects = require("src.rects")
local Button = require("src.button")

-- camera
local CAM_SPEED = 2 -- pixel per second
local CAM_LEFT = {0, 0}
local CAM_RIGHT = {76, 0}

local Board = {
    cam = util.deepCopy(CAM_LEFT),
    buttons = {}
}

function Board:_addSelectorButtons(rect, onInc, onDec, onPress)
    local x, y, w, h = unpack(rect)
    local dec = Button({x, y, 8, 8}, self.cam, onDec)
    local show = Button({x + 8, y, 24, 8}, self.cam, onPress, false, false)
    local inc = Button({x + 8 + 24, y, 8, 8}, self.cam, onInc)
    table.insert(self.buttons, inc)
    table.insert(self.buttons, dec)
    table.insert(self.buttons, show)
end

function Board:_initDeck(deck)

    -- track buttons
    for t = 1, sys.limits.tracks do

        -- select
        table.insert(self.buttons, Button(
            rects[deck].track[t].select, self.cam, 
            function () sys.trackSelect(t, deck) end
        ))

        -- mute
        table.insert(self.buttons, Button(
            rects[deck].track[t].mute, self.cam, 
            function () sys.toggleMute(t, deck) end
        ))

        -- solo
        table.insert(self.buttons, Button(
            rects[deck].track[t].solo, self.cam, 
            function () sys.toggleSolo(t, deck) end
        ))

    end

    -- vol
    self:_addSelectorButtons(
        rects[deck].vol, 
        function () sys.volInc(deck) end, 
        function () sys.volDec(deck) end, 
        function () sys.volTouch(deck) end
    )

    -- snd
    self:_addSelectorButtons(
        rects[deck].snd, 
        function () sys.sndInc(deck) end, 
        function () sys.sndDec(deck) end, 
        function () 
            sys.play(deck, track) 
            sys.sndTouch(deck)
        end
    )

    -- num
    self:_addSelectorButtons(
        rects[deck].num, 
        function () sys.numInc(deck) end, 
        function () sys.numDec(deck) end, 
        function () sys.numTouch(deck) end
    )

    -- rot
    self:_addSelectorButtons(
        rects[deck].rot, 
        function () sys.rotInc(deck) end, 
        function () sys.rotDec(deck) end, 
        function () sys.rotTouch(deck) end
    )

    -- len
    self:_addSelectorButtons(
        rects[deck].len, 
        function () sys.lenInc(deck) end, 
        function () sys.lenDec(deck) end, 
        function () sys.lenTouch(deck) end
    )

    -- mem
    self:_addSelectorButtons(
        rects[deck].mem, 
        function () sys.memInc(deck) end, 
        function () sys.memDec(deck) end, 
        function () sys.memTouch(deck) end
    )

    -- select deck
    table.insert(self.buttons, Button(
        rects[deck].select, self.cam, 
        function () sys.deckSelect(deck) end
    ))

end

function Board.enter(previous)
    sys.start()
end

function Board:init()

    gfx.loadUniformSpriteSheet("board", "gfx/board.png")
    gfx.loadUniformSpriteSheet("avatar", "gfx/avatar.png")

    -- bpm button
    self:_addSelectorButtons(
        rects.bpm, 
        sys.bpmInc, 
        sys.bpmDec, 
        sys.bpmTouch
    )

    -- leave button
    table.insert(self.buttons, Button(
        rects.leave, self.cam, function () self:_leave() end
    ))

    self:_initDeck("left")
    self:_initDeck("right")

end

function Board:mousepressed(x, y, mouse_button, istouch)
    for i, button in ipairs(self.buttons) do
        button:mousepressed(x, y, mouse_button, istouch)
    end
end

function Board:_leave()
    love.audio.setVolume(0.25)
    Gamestate.switch(Final)
end

function Board:keypressed(key)
    if key == "escape" then
        self:_leave()
    end
end

function Board:_drawField(fill_color, text_color, text, rect)
    local x, y, w, h = util.camAdjustRect(rect, self.cam)
    love.graphics.setColor(unpack(fill_color))
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(unpack(text_color))
    love.graphics.print(text, x, y)
end

function Board:_drawSelector(fill_color, text_color, text, rect)
    local x, y, w, h = util.camAdjustRect(rect, self.cam)
    love.graphics.setColor(unpack(fill_color))
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(unpack(text_color))
    love.graphics.print("<", x, y) -- left arrow
    love.graphics.print(text, x + 8, y) -- text
    love.graphics.print(">", x + 32, y) -- left arrow
end

function Board:_drawTrackButtons(deck, t)

    -- select track
    local color = colors.track[t].beta
    if sys.getSelectedTrack(deck) == t then
        color = colors.track[t].alpha
    end
    self:_drawField(color, colors.eigengrau, t, rects[deck].track[t]["select"])

    -- mute track
    if sys.getSelectedTrack(deck) == t then
        color = colors.track[t].alpha
        if sys.player.setup[deck].mute[t] then
            color = colors.track[t].beta
        end
    else -- inactive
        color = colors.track[t].beta
        if sys.player.setup[deck].mute[t] then
            color = colors.track[t].gamma
        end
    end
    self:_drawField(color, colors.eigengrau, "M", rects[deck].track[t]["mute"])

    -- solo track
    if sys.getSelectedTrack(deck) == t then
        color = colors.track[t].alpha
        if sys.player.setup[deck].solo == t then
            color = colors.track[t].beta
        end
    else -- inactive
        color = colors.track[t].beta
        if sys.player.setup[deck].solo == t then
            color = colors.track[t].gamma
        end
    end
    self:_drawField(color, colors.eigengrau, "S", rects[deck].track[t]["solo"])
end

function Board:update(delta_time)

    -- move camera if needed
    local cx, cy = unpack(self.cam)
    if sys.getSelectedDeck() == "right" then
        local tx, ty = unpack(CAM_RIGHT)
        cx = math.min(tx, cx + CAM_SPEED)
    else -- "left"
        local tx, ty = unpack(CAM_LEFT)
        cx = math.max(tx, cx - CAM_SPEED)
    end
    self.cam[1] = cx
    self.cam[2] = cy

    -- update fader
    local mx, my = unpack(gfx.fromWinPos({love.mouse.getPosition()}))
    local over_fader = util.overRect(mx, my, rects.fader, self.cam)
    if over_fader and love.mouse.isDown(1) then
        local x, y, w, h = util.camAdjustRect(rects.fader, self.cam)
        sys.player.setup.fade = (mx - x) / w
    end
end

function Board:_drawDeck(d)

    local selected_track = sys.getSelectedTrack()
    local track_color = colors.track[selected_track].alpha
    local deck_color = colors[d].gamma
    if d == sys.getSelectedDeck() then
        deck_color = colors[d].alpha
    end

    local label = sys.volDisplay(d)
    self:_drawSelector(track_color, colors.eigengrau, label, rects[d].vol) 
    
    label = sys.sndDisplay(d)
    self:_drawSelector(track_color, colors.eigengrau, label, rects[d].snd) 
    
    label = sys.numDisplay(d)
    self:_drawSelector(track_color, colors.eigengrau, label, rects[d].num) 

    label = sys.rotDisplay(d)
    self:_drawSelector(track_color, colors.eigengrau, label, rects[d].rot) 
    
    label = sys.lenDisplay(d)
    self:_drawSelector(deck_color, colors.eigengrau, label, rects[d].len) 
    
    label = sys.memDisplay(d)
    self:_drawSelector(deck_color, colors.eigengrau, label, rects[d].mem) 

    -- draw select
    local label = "L"
    if d == "right" then
        label = "R"
    end
    self:_drawField(deck_color, colors.eigengrau, label, rects[d].select)
end

function Board:draw()

    -- background
    love.graphics.setColor(colors.white) 
    gfx.drawSprite("board", util.camAdjustPos({0, 0}, self.cam))

    -- draw avatar
    gfx.drawSprite("avatar", util.camAdjustPos({118 - 12, 50 - 12}, self.cam))

    -- draw background lines
    local track = sys.getSelectedTrack()
    local deck = sys.getSelectedDeck()
    for i, line in ipairs(lines[deck][track]) do
        local point_a, point_b = unpack(line)
        local ax, ay = util.camAdjustPos(point_a, self.cam)
        local bx, by = util.camAdjustPos(point_b, self.cam)
        love.graphics.setColor(unpack(colors.track[track].alpha))
        love.graphics.line(ax, ay, bx, by)
    end

    self:_drawField(colors.eigengrau, colors.white, "TANZ.LOVE", rects.logo)
    self:_drawField(colors.eigengrau, colors.white, "LEAVE#", rects.leave)

    -- bmp
    self:_drawSelector(colors.eigengrau, colors.white,
                       sys.bpmDisplay(), rects.bpm)

    -- track buttons
    for t = 1, sys.limits.tracks do
        self:_drawTrackButtons("left", t)
        self:_drawTrackButtons("right", t)
    end

    self:_drawDeck("left")
    self:_drawDeck("right")

    -- deck fader
    local lf = 1.0 - sys.player.setup.fade
    local rf = sys.player.setup.fade
    local lr, lg, lb = unpack(colors.left.alpha)
    local rr, rg, rb = unpack(colors.right.alpha)
    local r, g, b = lr*lf + rr*rf, lg*lf + rg*rf, lb*lf + rb*rf
    local x, y, w, h = util.camAdjustRect(rects.fader, self.cam)
    love.graphics.setColor(r, g, b) 
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(util.colorInvert(r, g, b))
    love.graphics.line(x + w * rf, y - 1.0, x + w * rf, y + 9.0)

    -- track orbits
    local d = sys.getSelectedDeck()
    local x, y, outer_r, orbit_delta = util.camAdjustRect(rects.atom, self.cam)
    for t = 1, sys.limits.tracks do
        local orbit_r = outer_r - ((t-1) * orbit_delta)
        local rot_rs = outer_r - ((t-1) * orbit_delta) - orbit_delta / 2
        local rot_rf = outer_r - ((t-1) * orbit_delta) + orbit_delta / 2

        -- draw background circle
        local track_color = colors.track[t].alpha
        local beat_color = colors.white
        if t == 1 or t == 3 then
            beat_color = colors.black
        end
        if sys.getSelectedTrack(deck) ~= t then
            track_color = colors.track[t].beta
        end
        love.graphics.setColor(unpack(track_color))
        love.graphics.circle("line", x, y, orbit_r, 64)

        -- draw orbit beat backgrounds
        local len = sys.getLen(d)
        local rot = sys.getRot(d, t)
        local rhythm = sys.getRhythm(d, t)
        for b = 1, len do

            love.graphics.setColor(unpack(track_color))
            local phi = math.pi * 2 * ((b - 1) / (len))

            -- draw track rotation hand
            if rot == b-1 then
                local sdx, sdy = vector.rotate(phi, 0.0, - rot_rs)
                local stx, sty = vector.add(x, y, sdx, sdy)
                local fdx, fdy = vector.rotate(phi, 0.0, - rot_rf)
                local ftx, fty = vector.add(x, y, fdx, fdy)
                love.graphics.line(stx, sty, ftx, fty)
            end

            -- draw beat
            local dx, dy = vector.rotate(phi, 0.0, - orbit_r)
            local tx, ty = vector.add(x, y, dx, dy)
            local r = 1.25
            if rhythm[b] ~= 0 then
                r = 2.25
            end
            love.graphics.circle("fill", tx, ty, r, 16)

            -- highlight beats recently
            local br, bg, bb = unpack(beat_color)
            local beat_level = sys.getBeatLevel(d, t, b)
            love.graphics.setColor(br, bg, bb, beat_level * 255)
            love.graphics.circle("fill", tx, ty, r * beat_level, 16)
        end
    end

    -- draw clock hand
    love.graphics.setColor(unpack(colors.gray))
    local progress = sys.getLoopProgress()
    local phi = math.pi * 2.0 * progress
    local dix, diy = vector.rotate(phi, 0.0, - (outer_r-(orbit_delta * 3)))
    local ix, iy = vector.add(x, y, dix, diy)
    local dox, doy = vector.rotate(phi, 0.0, - (outer_r))
    local ox, oy = vector.add(x, y, dox, doy)
    love.graphics.line(ix, iy, ox, oy)

    -- draw buttons
    for i, button in ipairs(self.buttons) do
        button:draw()
    end

    -- bars for odd aspect ratios
    love.graphics.setColor(unpack(colors.black))
    love.graphics.rectangle("fill", - gfx.width, 0, gfx.width, gfx.height)
    love.graphics.rectangle("fill", gfx.width, 0, gfx.width, gfx.height)
end

return Board
