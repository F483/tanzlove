local util = require("src.util")

local SHOW_TIME = 1.0 -- seconds

local DEFAULT_PATTERN = {
    len = 16,
    tracks = {
        {vol = 15, snd = 0, num = 0, rot = 0},
        {vol = 15, snd = 0, num = 0, rot = 0},
        {vol = 15, snd = 0, num = 0, rot = 0},
        {vol = 15, snd = 0, num = 0, rot = 0},
    }
}

local SAMPLES = {
    "snd/BDL.wav", "snd/BDS.wav", "snd/CLP.wav", "snd/CLV.wav",
    "snd/CNG.wav", "snd/COW.wav", "snd/CYM.wav", "snd/HHC.wav",
    "snd/HHO.wav", "snd/HHP.wav", "snd/SD1.wav", "snd/SD2.wav",
    "snd/SHK.wav", "snd/TMH.wav", "snd/TML.wav", "snd/TMM.wav",
}

local sys = {

    -- TODO move to player

    limits = {
        vol = {min=0, max=15},
        snd = {min=0, max=15},
        num = {min=0, max=16},
        rot = {min=0, max=15},
        bpm = {min=1, max=255},
        len = {min=1, max=16},
        mem = {min=1, max=128}
    },

    memory = {},

    player = { 
        bpm = 128,
        fade = 1.0, -- 0.0 = left, 1.0 = right
        samples = {},
        history = {}, -- when the sample was last played for a given deck, track
        left = {
            clock = 0.0,
            pattern = 1, -- memory index
            solo = nil,
            mute = {false, false, false, false, false, false, false, false},
        },
        right = {
            clock = 0.0,
            pattern = 1, -- memory index
            solo = nil,
            mute = {false, false, false, false, false, false, false, false},
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
        for track = 1, 4 do
            sys.player.samples[deck][track] = {}
            sys.player.history[deck][track] = {}
            for i, filename in ipairs(SAMPLES) do
                local snd = love.audio.newSource(filename, "static")
                table.insert(sys.player.samples[deck][track], snd)
                table.insert(sys.player.history[deck][track], nil)
            end
        end
    end
end

function sys.getLoopLen(deck)
    local deck = deck or sys.display.deck
    local factor = sys.getLen(deck) / sys.limits.len.max
    return (60.0 / sys.player.bpm) * 4 * factor
end

function sys.getLoopProgress(deck)
    local deck = deck or sys.display.deck
    local looplen = sys.getLoopLen(deck)
    return (sys.player[deck].clock % looplen) / looplen
end

function sys._getTotalProgress(deck)
    return sys.player[deck].clock / sys.getLoopLen(deck)
end

function sys._setTotalProgress(progress, deck)
    sys.player[deck].clock = progress * sys.getLoopLen(deck)
end

function sys.update(dt)

    -- update deck clocks
    sys.player.left.clock = sys.player.right.clock + dt
    sys.player.right.clock = sys.player.right.clock + dt

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

    -- play samples 
    
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
    if sys.player[deck].solo == track then
        sys.player[deck].solo = nil
    else
        sys.player[deck].solo = track
    end
end

function sys.toggleMute(track, deck)
    local deck = deck or sys.display.deck
    local current_value = sys.player[deck].mute[track]
    sys.player[deck].mute[track] = not current_value
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
    local pattern_index = sys.player[deck].pattern
    return sys.memory[pattern_index].tracks[index]
end

function sys.getTrackVal(prop, deck, track)
    local deck = deck or sys.display.deck
    local track = sys.display.selected[deck]
    local pattern_index = sys.player[deck].pattern
    local pattern = sys.memory[pattern_index]
    return pattern.tracks[track][prop]
end

function sys.setTrackVal(prop, value, deck, track)
    local deck = deck or sys.display.deck
    local track = sys.display.selected[deck]
    local pattern_index = sys.player[deck].pattern
    local pattern = sys.memory[pattern_index]
    pattern.tracks[track][prop] = value
end

function sys.incTrackVal(prop, deck, track)
    local val = sys.getTrackVal(prop, deck, track)
    val = math.min(val + 1, sys.limits[prop].max)
    sys.setTrackVal(prop, val, deck, track)
    sys.display.show_ttls[deck][prop] = SHOW_TIME
end

function sys.decTrackVal(prop, deck, track)
    local val = sys.getTrackVal(prop, deck, track)
    val = math.max(val - 1, sys.limits[prop].min)
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
        return string.format("%03d", sys.getTrackVal("snd", deck))
    end
    return "SND"
end

function sys.play(deck, track)
    local deck = deck or sys.display.deck
    local track = track or sys.display.selected[deck]
    sys.player.samples[deck][track]:play()
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

---------
-- LEN --
---------

function sys.lenInc(deck) 
    local deck = deck or sys.display.deck
    local prev = sys._getTotalProgress(deck)
    local pattern_index = sys.player[deck].pattern
    local val = sys.memory[pattern_index].len
    val = math.min(val + 1, sys.limits.len.max)
    sys.memory[pattern_index].len = val
    sys.lenTouch(deck)
    sys._setTotalProgress(prev, deck)
end

function sys.lenDec(deck) 
    local deck = deck or sys.display.deck
    local prev = sys._getTotalProgress(deck)
    local pattern_index = sys.player[deck].pattern
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
        local pattern_index = sys.player[deck].pattern
        return string.format("%03d", sys.memory[pattern_index].len)
    end
    return "LEN"
end

function sys.getLen(deck)
    local deck = deck or sys.display.deck
    local pattern_index = sys.player[deck].pattern
    return sys.memory[pattern_index].len
end

---------
-- MEM --
---------

function sys.memInc(deck) 
    local deck = deck or sys.display.deck
    local prev = sys._getTotalProgress(deck)
    local val = sys.player[deck].pattern
    val = math.min(val + 1, sys.limits.mem.max)
    sys.player[deck].pattern = val
    sys.deckTouch(deck)
    sys._setTotalProgress(prev, deck)
end

function sys.memDec(deck) 
    local deck = deck or sys.display.deck
    local prev = sys._getTotalProgress(deck)
    local val = sys.player[deck].pattern
    val = math.max(val - 1, sys.limits.mem.min)
    sys.player[deck].pattern = val
    sys.deckTouch(deck)
    sys._setTotalProgress(prev, deck)
end

function sys.memTouch(deck) 
    local deck = deck or sys.display.deck
    sys.display.show_ttls[deck].mem = SHOW_TIME
end

function sys.memDisplay(deck) 
    local deck = deck or sys.display.deck
    if sys.display.show_ttls[deck].mem > 0.0 then
        local pattern_index = sys.player[deck].pattern
        return string.format("%03d", pattern_index)
    end
    return "MEM"
end

return sys
