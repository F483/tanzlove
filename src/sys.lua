local util = require("src.util")
local euclid = require("src.euclid")

local SHOW_TIME = 1.0 -- seconds

local DEFAULT_PATTERN = {
    len = 16,
    tracks = {
        {vol = 15, snd = 1, num = 0, rot = 0},
        {vol = 15, snd = 1, num = 0, rot = 0},
        {vol = 15, snd = 1, num = 0, rot = 0},
        {vol = 15, snd = 1, num = 0, rot = 0},
    }
}

local SAMPLES = {
    "snd/BDL.wav", "snd/BDS.wav", "snd/CLP.wav", "snd/CLV.wav",
    "snd/CNG.wav", "snd/COW.wav", "snd/CYM.wav", "snd/HHC.wav",
    "snd/HHO.wav", "snd/HHP.wav", "snd/SD1.wav", "snd/SD2.wav",
    "snd/SHK.wav", "snd/TML.wav", "snd/TMM.wav", "snd/TMH.wav",
}

local sys = {

    limits = {
        vol = {min=0, max=15},
        snd = {min=1, max=16},
        num = {min=0, max=16},
        rot = {min=0, max=15},
        bpm = {min=1, max=255},
        len = {min=1, max=16},
        mem = {min=1, max=128},
        tracks = 4
    },

    memory = {},

    player = { 
        bpm = 128,
        fade = 1.0, -- 0.0 = left, 1.0 = right
        samples = {},

        history = {}, -- when the sample was last played for a given deck, track

        setup = {
            left = {
                clock = 0.0, -- FIXME save total progress instead?
                pattern = 1, -- memory index
                solo = nil,
                mute = {false, false, false, false, false, false, false, false},
            },
            right = {
                clock = 0.0, -- FIXME save total progress instead?
                pattern = 2, -- memory index
                solo = nil,
                mute = {false, false, false, false, false, false, false, false},
            }
        }
    },
    
    display = {
        deck = "right", -- or left
        selected = {
            left = 1,
            right = 2
        },
        show_ttls = {
            bpm = 0.0,
            left = {len=0.0, mem=0.0, vol=0.0, snd=0.0, num=0.0, rot=0.0},
            right = {len=0.0, mem=0.0, vol=0.0, snd=0.0, num=0.0, rot=0.0}
        },
    },
}

function sys.play(deck, track, vol)
    local deck = deck or sys.display.deck
    local track = track or sys.display.selected[deck]
    local data = sys.getTrackData(track, deck)
    local snd = sys.player.samples[deck][track][data.snd]
    vol = vol or data.vol
    snd:setVolume(vol / sys.limits.vol.max) 
    snd:stop()
    snd:play()
end

function sys.init()

    -- load memomry slots
    for m = sys.limits.mem.min, sys.limits.mem.max do
        -- TODO check and load if saved
        sys.memory[m] = util.deepCopy(DEFAULT_PATTERN)
    end

    -- every track has its own sample bank to allow parallel play
    for i, deck in ipairs({"left", "right"}) do 
        sys.player.samples[deck] = {}
        sys.player.history[deck] = {}
        for track = 1, sys.limits.tracks do
            sys.player.samples[deck][track] = {}
            for i, filename in ipairs(SAMPLES) do
                local snd = love.audio.newSource(filename, "static")
                table.insert(sys.player.samples[deck][track], snd)
                sys.player.history[deck][track] = -123456789.0
            end
        end
    end
end

function sys._getLoopLen(deck)
    local deck = deck or sys.display.deck
    local factor = sys.getLen(deck) / sys.limits.len.max
    return (60.0 / sys.player.bpm) * 4 * factor
end

function sys.getLoopProgress(deck)
    local deck = deck or sys.display.deck
    return sys._getTotalProgress(deck) % 1
end

function sys._getTotalProgress(deck)
    return sys.player.setup[deck].clock / sys._getLoopLen(deck)
end

function sys._setTotalProgress(progress, deck)
    sys.player.setup[deck].clock = progress * sys._getLoopLen(deck)
end

function sys.getRhythm(d, t)
    local len = sys.getLen(d)
    local num = math.min(sys.getNum(d, t), len)
    local rot = sys.getRot(d, t) % len
    return euclid.rhythm(len, num, rot)
end

function sys.update(dt)

    -- update deck clocks
    sys.player.setup.left.clock = sys.player.setup.right.clock + dt
    sys.player.setup.right.clock = sys.player.setup.right.clock + dt

    -- update ttls
    local ttls = sys.display.show_ttls
    ttls.bpm = math.max(0.0, ttls.bpm - dt)
    ttls.left.len = math.max(0.0, ttls.left.len - dt)
    ttls.left.mem = math.max(0.0, ttls.left.mem - dt)
    ttls.left.vol = math.max(0.0, ttls.left.vol - dt)
    ttls.left.snd = math.max(0.0, ttls.left.snd - dt)
    ttls.left.num = math.max(0.0, ttls.left.num - dt)
    ttls.left.rot = math.max(0.0, ttls.left.rot - dt)
    ttls.right.len = math.max(0.0, ttls.right.len - dt)
    ttls.right.mem = math.max(0.0, ttls.right.mem - dt)
    ttls.right.vol = math.max(0.0, ttls.right.vol - dt)
    ttls.right.snd = math.max(0.0, ttls.right.snd - dt)
    ttls.right.num = math.max(0.0, ttls.right.num - dt)
    ttls.right.rot = math.max(0.0, ttls.right.rot - dt)

    -- play samples if needed
    for i, deck in ipairs({"left", "right"}) do 
        for track = 1, sys.limits.tracks do
            local data = sys.getTrackData(track, deck)
            local muted = sys.player.setup[deck].mute[track]
            local solo = sys.player.setup[deck].solo
            local other_solo = solo ~= nil and solo ~= track
            local audable = not muted and not other_solo
            local vol = data.vol * sys.player.fade
            if deck == "left" then
                vol = data.vol * (1.0 - sys.player.fade)
            end
            if audable and vol > 0.0 and data.num > 0 then
                local len = sys.getLen(deck)
                local last_played = sys.player.history[deck][track]
                local last_expected = sys._getLastExpected(deck, track)
                local total_progress = sys._getTotalProgress(deck)
                local skip = total_progress - last_expected > 1.0 / len
                if last_expected > last_played and not skip then
                    sys.play(deck, track, vol)
                    sys.player.history[deck][track] = total_progress
                end
            end
        end
    end
    
end

function sys._getLastExpected(deck, track)

    local len = sys.getLen(deck)
    local rhythm = sys.getRhythm(deck, track)
    local total_progress = sys._getTotalProgress(deck)
    local loop_progress = sys.getLoopProgress()
    local current_step_index = math.ceil(loop_progress * len)

    -- rotate until we find the last beat played
    local expected = - 2 / len -- always skipped
    for rot = 0, len - 1 do
        local index = ((current_step_index + 15 - rot) % len) + 1
        if rhythm[index] ~= 0 then
            local step_remainder = total_progress % (1.0 / len)
            return total_progress - rot / len - step_remainder
        end
    end
    return expected
end


---------
-- BPM --
---------

function sys.bpmInc()
    local prev_left = sys._getTotalProgress("left")
    local prev_right = sys._getTotalProgress("right")

    local val = sys.player.bpm
    sys.player.bpm = math.min(val + 1, sys.limits.bpm.max)
    sys.bpmTouch()

    sys._setTotalProgress(prev_left, "left")
    sys._setTotalProgress(prev_right, "right")
end

function sys.bpmDec()
    local prev_left = sys._getTotalProgress("left")
    local prev_right = sys._getTotalProgress("right")

    local val = sys.player.bpm
    sys.player.bpm = math.max(val - 1, sys.limits.bpm.min)
    sys.bpmTouch()

    sys._setTotalProgress(prev_left, "left")
    sys._setTotalProgress(prev_right, "right")
end

function sys.bpmTouch()
    sys.display.show_ttls.bpm = SHOW_TIME
end

function sys.bpmDisplay()
    if sys.display.show_ttls.bpm > 0.0 then
        return string.format("%03d", sys.player.bpm)
    end
    return "BPM"
end

----------
-- DECK --
----------

function sys.deckSelect(deck)
    sys.display.deck = deck 
    sys.deckTouch(deck)
end

function sys.getSelectedDeck()
    return sys.display.deck
end

function sys.deckTouch(deck)
    local deck = deck or sys.display.deck
    sys.volTouch(deck)
    sys.sndTouch(deck)
    sys.numTouch(deck)
    sys.rotTouch(deck)
    sys.lenTouch(deck)
    sys.memTouch(deck)
end

-----------
-- TRACK --
-----------

function sys.getSelectedTrack(deck)
    local deck = deck or sys.display.deck
    return sys.display.selected[deck]
end

function sys.trackSelect(track, deck)
    local deck = deck or sys.display.deck
    sys.display.selected[deck] = track
    sys.trackTouch(deck)
end

function sys.toggleSolo(track, deck)
    local deck = deck or sys.display.deck
    if sys.player.setup[deck].solo == track then
        sys.player.setup[deck].solo = nil
    else
        sys.player.setup[deck].solo = track
    end
end

function sys.toggleMute(track, deck)
    local deck = deck or sys.display.deck
    local current_value = sys.player.setup[deck].mute[track]
    sys.player.setup[deck].mute[track] = not current_value
end

function sys.trackTouch(deck)
    local deck = deck or sys.display.deck
    sys.volTouch(deck)
    sys.sndTouch(deck)
    sys.numTouch(deck)
    sys.rotTouch(deck)
end

function sys.getTrackData(index, deck)
    local deck = deck or sys.display.deck
    local pattern_index = sys.player.setup[deck].pattern
    return sys.memory[pattern_index].tracks[index]
end

function sys.getTrackVal(prop, deck, track)
    local deck = deck or sys.display.deck
    local track = track or sys.display.selected[deck]
    local pattern_index = sys.player.setup[deck].pattern
    local pattern = sys.memory[pattern_index]
    return pattern.tracks[track][prop]
end

function sys.setTrackVal(prop, value, deck, track)
    local deck = deck or sys.display.deck
    local track = track or sys.display.selected[deck]
    local pattern_index = sys.player.setup[deck].pattern
    local pattern = sys.memory[pattern_index]
    pattern.tracks[track][prop] = value
end

function sys.incTrackVal(prop, deck, track)
    local val = sys.getTrackVal(prop, deck, track)
    local max = sys.limits[prop].max
    if val == max then
        val = sys.limits[prop].min -- wrap around
    else
        val = math.min(val + 1, max)
    end
    sys.setTrackVal(prop, val, deck, track)
    sys.display.show_ttls[deck][prop] = SHOW_TIME
end

function sys.decTrackVal(prop, deck, track)
    local val = sys.getTrackVal(prop, deck, track)
    local min = sys.limits[prop].min
    if val == min then
        val = sys.limits[prop].max -- wrap around
    else
        val = math.max(val - 1, min)
    end
    sys.setTrackVal(prop, val, deck, track)
    sys.display.show_ttls[deck][prop] = SHOW_TIME
end

---------
-- VOL --
---------

function sys.volInc(deck, track) 
    sys.incTrackVal("vol", deck, track)
end

function sys.volDec(deck, track) 
    sys.decTrackVal("vol", deck, track)
end

function sys.volTouch(deck) 
    local deck = deck or sys.display.deck
    sys.display.show_ttls[deck].vol = SHOW_TIME
end

function sys.volDisplay(deck)
    local deck = deck or sys.display.deck
    if sys.display.show_ttls[deck].vol > 0.0 then
        return string.format("%03d", sys.getTrackVal("vol", deck))
    end
    return "VOL"
end

---------
-- SND --
---------

function sys.sndInc(deck, track) 
    sys.incTrackVal("snd", deck, track)
end

function sys.sndDec(deck, track) 
    sys.decTrackVal("snd", deck, track)
end

function sys.sndTouch(deck) 
    local deck = deck or sys.display.deck
    sys.display.show_ttls[deck].snd = SHOW_TIME
end

function sys.sndDisplay(deck)
    local deck = deck or sys.display.deck
    if sys.display.show_ttls[deck].snd > 0.0 then
        local val = sys.getTrackVal("snd", deck)
        local filename = SAMPLES[val]
        return filename:match("([^/]+).wav$")
    end
    return "SND"
end

---------
-- NUM --
---------

function sys.numInc(deck, track) 
    sys.incTrackVal("num", deck, track)
end

function sys.numDec(deck, track) 
    sys.decTrackVal("num", deck, track)
end

function sys.numTouch(deck) 
    local deck = deck or sys.display.deck
    sys.display.show_ttls[deck].num = SHOW_TIME
end

function sys.numDisplay(deck)
    local deck = deck or sys.display.deck
    if sys.display.show_ttls[deck].num > 0.0 then
        return string.format("%03d", sys.getTrackVal("num", deck))
    end
    return "NUM"
end

function sys.getNum(deck, track)
    return sys.getTrackVal("num", deck, track)
end

---------
-- ROT --
---------

function sys.rotInc(deck, track) 
    sys.incTrackVal("rot", deck, track)
end

function sys.rotDec(deck, track) 
    sys.decTrackVal("rot", deck, track)
end

function sys.rotTouch(deck) 
    local deck = deck or sys.display.deck
    sys.display.show_ttls[deck].rot = SHOW_TIME
end

function sys.rotDisplay(deck)
    local deck = deck or sys.display.deck
    if sys.display.show_ttls[deck].rot > 0.0 then
        return string.format("%03d", sys.getTrackVal("rot", deck))
    end
    return "ROT"
end

function sys.getRot(deck, track)
    return sys.getTrackVal("rot", deck, track)
end

---------
-- LEN --
---------

function sys.lenInc(deck) 
    local deck = deck or sys.display.deck
    local prev = sys._getTotalProgress(deck)
    local pattern_index = sys.player.setup[deck].pattern
    local val = sys.memory[pattern_index].len
    val = math.min(val + 1, sys.limits.len.max)
    sys.memory[pattern_index].len = val
    sys.lenTouch(deck)
    sys._setTotalProgress(prev, deck)
end

function sys.lenDec(deck) 
    local deck = deck or sys.display.deck
    local prev = sys._getTotalProgress(deck)
    local pattern_index = sys.player.setup[deck].pattern
    local val = sys.memory[pattern_index].len
    val = math.max(val - 1, sys.limits.len.min)
    sys.memory[pattern_index].len = val
    sys.lenTouch(deck)
    sys._setTotalProgress(prev, deck)
end

function sys.lenTouch(deck) 
    local deck = deck or sys.display.deck
    sys.display.show_ttls[deck].len = SHOW_TIME
end

function sys.lenDisplay(deck) 
    local deck = deck or sys.display.deck
    if sys.display.show_ttls[deck].len > 0.0 then
        local pattern_index = sys.player.setup[deck].pattern
        return string.format("%03d", sys.memory[pattern_index].len)
    end
    return "LEN"
end

function sys.getLen(deck)
    local deck = deck or sys.display.deck
    local pattern_index = sys.player.setup[deck].pattern
    return sys.memory[pattern_index].len
end

---------
-- MEM --
---------

function sys.memInc(deck) 
    local deck = deck or sys.display.deck
    local prev = sys._getTotalProgress(deck)
    local val = sys.player.setup[deck].pattern
    local max = sys.limits.mem.max
    if val == max then
        val = sys.limits.mem.min -- wrap around
    else
        val = math.min(val + 1, max)
    end
    sys.player.setup[deck].pattern = val
    sys._setTotalProgress(prev, deck)
    sys.deckTouch(deck)
end

function sys.memDec(deck) 
    local deck = deck or sys.display.deck
    local prev = sys._getTotalProgress(deck)
    local val = sys.player.setup[deck].pattern
    local min = sys.limits.mem.min
    if val == min then
        val = sys.limits.mem.max -- wrap around
    else
        val = math.max(val - 1, min)
    end
    sys.player.setup[deck].pattern = val
    sys._setTotalProgress(prev, deck)
    sys.deckTouch(deck)
end

function sys.memTouch(deck) 
    local deck = deck or sys.display.deck
    sys.display.show_ttls[deck].mem = SHOW_TIME
end

function sys.memDisplay(deck) 
    local deck = deck or sys.display.deck
    if sys.display.show_ttls[deck].mem > 0.0 then
        local pattern_index = sys.player.setup[deck].pattern
        return string.format("%03d", pattern_index)
    end
    return "MEM"
end

return sys
