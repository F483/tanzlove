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

function Board:_addSelectorButtons(rect, onInc, onDec, onPress, width)
    local width = width or 24 -- FIXME deduce from rect instead!
    local x, y, w, h = unpack(rect)
    table.insert(self.buttons, Button({x, y, 8, 8}, self.cam, onDec))
    table.insert(self.buttons, Button({x+8+width, y, 8, 8}, self.cam, onInc))
    if onPress then
        local show = Button({x + 8, y, width, 8}, 
                            self.cam, onPress, false, false)
        table.insert(self.buttons, show)
    end
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
        function () sys.volDec(deck) end
    )

    -- snd
    self:_addSelectorButtons(
        rects[deck].snd, 
        function () sys.sndInc(deck) end, 
        function () sys.sndDec(deck) end, 
        function () 
            sys.play(deck, track) 
        end
    )

    -- num
    self:_addSelectorButtons(
        rects[deck].num, 
        function () sys.numInc(deck) end, 
        function () sys.numDec(deck) end
    )

    -- rot
    self:_addSelectorButtons(
        rects[deck].rot, 
        function () sys.rotInc(deck) end, 
        function () sys.rotDec(deck) end
    )

    -- len
    self:_addSelectorButtons(
        rects[deck].len, 
        function () sys.lenInc(deck) end, 
        function () sys.lenDec(deck) end
    )

    -- mem
    self:_addSelectorButtons(
        rects[deck].mem, 
        function () sys.memInc(deck) end, 
        function () sys.memDec(deck) end
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

    gfx.loadUniformSpriteSheet("icons", "gfx/icons.png", 6, 4)
    gfx.loadUniformSpriteSheet("board", "gfx/board.png")
    gfx.loadUniformSpriteSheet("avatar", "gfx/avatar.png")

    -- bpm button
    self:_addSelectorButtons(rects.bpm, sys.bpmInc, sys.bpmDec, nil, 32)

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

function Board:_drawIconSelector(fill_color, text_color, text,
                                 rect, icon_x, icon_y)

    local x, y, w, h = util.camAdjustRect(rect, self.cam)
    love.graphics.setColor(unpack(fill_color))
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(unpack(text_color))
    love.graphics.print("<", x, y) -- left arrow
    gfx.drawSprite("icons", x + 8, y, icon_x, icon_y)
    love.graphics.print(text, x + 16, y) -- text
    love.graphics.print(">", x + 32, y) -- left arrow
end

function Board:_drawBpm()
    local rect = rects.bpm
    local text = sys.getBpm()
    local x, y, w, h = util.camAdjustRect(rect, self.cam)
    love.graphics.setColor(unpack(colors.eigengrau))
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(unpack(colors.white))
    love.graphics.print("<", x, y) -- left arrow
    if sys.onBeat() then
        gfx.drawSprite("icons", x + 8, y, 2, 4)
    else -- off beat
        gfx.drawSprite("icons", x + 8, y, 3, 4)
    end
    love.graphics.print(text, x + 16, y) -- text
    love.graphics.print(">", x + w - 8, y) -- left arrow
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
		if mx - x < 1.0 then -- snap left
			sys.player.setup.fade = 0.0
		elseif mx - x > w - 1.0 then -- snap right
			sys.player.setup.fade = 1.0
		else
			sys.player.setup.fade = (mx - x) / w
		end
    end
end

function Board:_drawDeck(d)

    local selected_track = sys.getSelectedTrack(d)
    local track_color = colors.track[selected_track].alpha
    local deck_color = colors[d].gamma
    if d == sys.getSelectedDeck() then
        deck_color = colors[d].alpha
    end

    -- draw volume level
    local volume = sys.getVol(d)
    local index = math.floor((volume / 16) * 6 ) + 1
    local label = string.format("%02d", volume)
    self:_drawIconSelector(track_color, colors.eigengrau, 
                           label, rects[d].vol, index, 1)
    
    -- draw sound name
    self:_drawIconSelector(track_color, colors.eigengrau, 
                           sys.sndName(d), rects[d].snd, 1, 2)
    
    -- draw number of beats
    local label = string.format("%02d", sys.getNum(d))
    self:_drawIconSelector(track_color, colors.eigengrau, 
                           label, rects[d].num, 2, 2)

    -- draw rotation number
    local label = string.format("%02d", sys.getRot(d))
    self:_drawIconSelector(track_color, colors.eigengrau, 
                           label, rects[d].rot, 3, 2)

    -- loop lenght
    local label = string.format("%02d", sys.getLen(d))
    self:_drawIconSelector(deck_color, colors.eigengrau, 
                           label, rects[d].len, 1, 3)
    
    -- memory slot
    local label = string.format("%02d", sys.getMem(d))
    self:_drawIconSelector(deck_color, colors.eigengrau, 
                           label, rects[d].mem, 2, 3)

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
    local deck = sys.getSelectedDeck()
    local track = sys.getSelectedTrack(deck)
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
    self:_drawBpm()

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
    love.graphics.setColor(unpack(colors.eigengrau))
    love.graphics.print("FADE", x + ((w - 32) / 2), y)
    love.graphics.setColor(util.colorInvert(r, g, b))
    love.graphics.line(x + w * rf, y - 1.0, x + w * rf, y + 9.0)

    -- track orbits
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
        local len = sys.getLen(deck)
        local rot = sys.getRot(deck, t)
        local rhythm = sys.getRhythm(deck, t)
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
            local beat_level = sys.getBeatLevel(deck, t, b)
            love.graphics.setColor(br, bg, bb, beat_level * 255)
            love.graphics.circle("fill", tx, ty, r * beat_level, 16)
        end
    end

    -- draw clock hand
    love.graphics.setColor(unpack(colors.gray))
    local progress = sys.getLoopProgress(deck)
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
