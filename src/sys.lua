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

local MEM_DIR = "mem"

local SAMPLES = {
    "snd/nlp/BDL.WAV",
    "snd/nlp/BDS.WAV",
    "snd/nlp/CLP.WAV",
    "snd/nlp/CLV.WAV",
    "snd/nlp/CNG.WAV",
    "snd/nlp/COW.WAV",
    "snd/nlp/CYM.WAV",
    "snd/nlp/HHC.WAV",
    "snd/nlp/HHO.WAV",
    "snd/nlp/HHP.WAV",
    "snd/nlp/SD1.WAV",
    "snd/nlp/SD2.WAV",
    "snd/nlp/SHK.WAV",
    "snd/nlp/TML.WAV",
    "snd/nlp/TMM.WAV",
    "snd/nlp/TMH.WAV",
}

local sys = {

    stopped = true,

    limits = {
        vol = {min=0, max=15},
        snd = {min=1, max=16},
        num = {min=0, max=16},
        rot = {min=0, max=15},
        bpm = {min=1, max=255},
        len = {min=1, max=16},
        mem = {min=1, max=64},
        tracks = 4
    },

    memory = {},

    player = {

        samples = {},

        history = {}, -- when the sample was last played for a given deck, track

        clock = {
            left = 0.0, -- FIXME save total progress instead?
            right = 0.0,
        },

        setup = {
            bpm = 128,
		    volume = 1.0,
            fade = 1.0, -- 0.0 = left, 1.0 = right

            left = {
                pattern = 1, -- memory index
                solo = nil,
                mute = {false, false, false, false, false, false, false, false},
            },
            right = {
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
            right = 1
        },
        show_ttls = {
            bpm = 0.0,
            left = {len=0.0, mem=0.0, vol=0.0, snd=0.0, num=0.0, rot=0.0},
            right = {len=0.0, mem=0.0, vol=0.0, snd=0.0, num=0.0, rot=0.0}
        },
    },
}

function sys.stop()
    sys.stopped = true

    -- TODO stop all current sounds
end

function sys.start()
    sys.stopped = false
end

function sys.play(deck, track, vol)
    assert(deck)
    local track = track or sys.display.selected[deck]
    local data = sys.getTrackData(track, deck)
    local snd = sys.player.samples[deck][track][data.snd]
    vol = vol or data.vol
    snd:setVolume(vol / sys.limits.vol.max)
    snd:stop()
    snd:play()
end

function sys.init()

	-- load mem
    for m = sys.limits.mem.min, sys.limits.mem.max do
        local filepath = MEM_DIR .. "/" .. m .. ".json"
        if love.filesystem.exists(filepath) then
            sys.memory[m] = util.loadJsonFile(filepath)
        else
            sys.memory[m] = util.deepCopy(DEFAULT_PATTERN)
        end
    end

	-- load player
    local filepath = "player.json"
    if love.filesystem.exists(filepath) then
        sys.player.setup = util.loadJsonFile(filepath)
    end

	-- load display
    local filepath = "display.json"
    if love.filesystem.exists(filepath) then
        sys.display = util.loadJsonFile(filepath)
    end

	-- load samples
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

    -- touch mem dir to enable saving
    local success = love.filesystem.createDirectory(MEM_DIR)
    assert(success, "Couldn't create mem save directory!")
end

function sys.quit()

	-- save player
    util.saveJsonFile("player.json", sys.player.setup)

	-- save display
    util.saveJsonFile("display.json", sys.display)

    -- mem saved after each change, so no need to save
end

function sys._getLoopLen(deck)
    assert(deck)
    local factor = sys.getLen(deck) / sys.limits.len.max
    return (60.0 / sys.player.setup.bpm) * 4 * factor
end

function sys.getLoopProgress(deck)
    assert(deck)
    return sys._getTotalProgress(deck) % 1
end

function sys._getTotalProgress(deck)
    return sys.player.clock[deck] / sys._getLoopLen(deck)
end

function sys._setTotalProgress(progress, deck)
    sys.player.clock[deck] = progress * sys._getLoopLen(deck)
end

function sys.getRhythm(d, t)
    local len = sys.getLen(d)
    local num = math.min(sys.getNum(d, t), len)
    local rot = sys.getRot(d, t) % len
    return euclid.rhythm(len, num, rot)
end

function sys.update(dt)

    -- do nothing if stopped
    if sys.stopped == true then
        return
    end

    -- update deck clocks
    sys.player.clock.left = sys.player.clock.right + dt
    sys.player.clock.right = sys.player.clock.right + dt

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
            local vol = data.vol * sys.player.setup.fade
            if deck == "left" then
                vol = data.vol * (1.0 - sys.player.setup.fade)
            end
            if audable and vol > 0.0 and data.num > 0 then
                local len = sys.getLen(deck)
                local last_played = sys.player.history[deck][track]
                local last_expected = sys._getPrevProgress(deck, track)
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

function sys.getBeatLevel(deck, track, beat)
    -- between 1.0 for just triggers or 0.0 for other beat played

    local rhythm = sys.getRhythm(deck, track)
    if rhythm[beat] == 0 then
        return 0.0
    end

    local len = sys.getLen(deck)
    local p_total = sys._getTotalProgress(deck)
    local p_beat = math.floor(p_total) + (beat - 1) / len
    local p_next_expected = sys._getNextProgress(deck, track, beat)
    if p_beat <= p_total and p_total <= p_next_expected then
        return 1.0 - (p_total - p_beat) / (p_next_expected - p_beat)
    end
    return 0.0
end

function sys._getNextProgress(deck, track, beat)

    local len = sys.getLen(deck)
    local total_progress = sys._getTotalProgress(deck)
    local loop_progress = sys.getLoopProgress(deck)
    local step_index = beat or math.ceil(loop_progress * len)
    local rhythm = sys.getRhythm(deck, track)

    -- rotate until we find the next beat to be played
    for rot = 1, len do
        local index = (((step_index - 1) + rot) % len) + 1
        if rhythm[index] ~= 0 then
            if index <= step_index then
                return math.floor(total_progress) + index / len + 1.0
            else
                return math.floor(total_progress) + index / len
            end
        end
    end
    return nil
end

function sys._getPrevProgress(deck, track, beat)

    local len = sys.getLen(deck)
    local rhythm = sys.getRhythm(deck, track)
    local total_progress = sys._getTotalProgress(deck)
    local loop_progress = sys.getLoopProgress(deck)
    local step_index = beat or math.ceil(loop_progress * len)

    -- rotate until we find the last beat played
    for rot = 0, len - 1 do
        local index = (((step_index - 1) + len - rot) % len) + 1
        if rhythm[index] ~= 0 then
            local step_remainder = total_progress % (1.0 / len)
            return total_progress - rot / len - step_remainder
        end
    end
    -- FIXME return nil instead and handle it
    return - 2 / len -- so old it always triggers playing the first beat
end


---------
-- BPM --
---------

function sys.bpmInc()
    local prev_left = sys._getTotalProgress("left")
    local prev_right = sys._getTotalProgress("right")

    local val = sys.player.setup.bpm
    sys.player.setup.bpm = math.min(val + 1, sys.limits.bpm.max)
    sys.bpmTouch()

    sys._setTotalProgress(prev_left, "left")
    sys._setTotalProgress(prev_right, "right")
end

function sys.bpmDec()
    local prev_left = sys._getTotalProgress("left")
    local prev_right = sys._getTotalProgress("right")

    local val = sys.player.setup.bpm
    sys.player.setup.bpm = math.max(val - 1, sys.limits.bpm.min)
    sys.bpmTouch()

    sys._setTotalProgress(prev_left, "left")
    sys._setTotalProgress(prev_right, "right")
end

function sys.bpmTouch()
    sys.display.show_ttls.bpm = SHOW_TIME
end

function sys.bpmDisplay()
    if sys.display.show_ttls.bpm > 0.0 then
        return string.format("%03d", sys.player.setup.bpm)
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
    assert(deck)
    sys.volTouch(deck)
    sys.sndTouch(deck)
    sys.numTouch(deck)
    sys.rotTouch(deck)
    sys.lenTouch(deck)
    sys.memTouch(deck)
end

function sys.deckSave(deck)
    local m = sys.player.setup[deck].pattern
    local filepath = MEM_DIR .. "/" .. m .. ".json"
    util.saveJsonFile(filepath, sys.memory[m])
end

-----------
-- TRACK --
-----------

function sys.getSelectedTrack(deck)
    assert(deck)
    return sys.display.selected[deck]
end

function sys.trackSelect(track, deck)
    assert(deck)
    sys.display.selected[deck] = track
    sys.trackTouch(deck)
end

function sys.toggleSolo(track, deck)
    assert(deck)
    if sys.player.setup[deck].solo == track then
        sys.player.setup[deck].solo = nil
    else
        sys.player.setup[deck].solo = track
    end
end

function sys.toggleMute(track, deck)
    assert(deck)
    local current_value = sys.player.setup[deck].mute[track]
    sys.player.setup[deck].mute[track] = not current_value
end

function sys.trackTouch(deck)
    assert(deck)
    sys.volTouch(deck)
    sys.sndTouch(deck)
    sys.numTouch(deck)
    sys.rotTouch(deck)
end

function sys.getTrackData(index, deck)
    assert(deck)
    local pattern_index = sys.player.setup[deck].pattern
    return sys.memory[pattern_index].tracks[index]
end

function sys.getTrackVal(prop, deck, track)
    assert(deck)
    local track = track or sys.display.selected[deck]
    local pattern_index = sys.player.setup[deck].pattern
    local pattern = sys.memory[pattern_index]
    return pattern.tracks[track][prop]
end

function sys.setTrackVal(prop, value, deck, track)
    assert(deck)
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
    sys.deckSave(deck)
end

function sys.volDec(deck, track)
    sys.decTrackVal("vol", deck, track)
    sys.deckSave(deck)
end

function sys.volTouch(deck)
    assert(deck)
    sys.display.show_ttls[deck].vol = SHOW_TIME
end

function sys.volDisplay(deck)
    assert(deck)
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
    sys.deckSave(deck)
end

function sys.sndDec(deck, track)
    sys.decTrackVal("snd", deck, track)
    sys.deckSave(deck)
end

function sys.sndTouch(deck)
    assert(deck)
    sys.display.show_ttls[deck].snd = SHOW_TIME
end

function sys.sndDisplay(deck)
    assert(deck)
    if sys.display.show_ttls[deck].snd > 0.0 then
        local val = sys.getTrackVal("snd", deck)
        local filename = SAMPLES[val]
        return filename:match("([^/]+).WAV$")
    end
    return "SND"
end

---------
-- NUM --
---------

function sys.numInc(deck, track)
    sys.incTrackVal("num", deck, track)
    sys.deckSave(deck)
end

function sys.numDec(deck, track)
    sys.decTrackVal("num", deck, track)
    sys.deckSave(deck)
end

function sys.numTouch(deck)
    assert(deck)
    sys.display.show_ttls[deck].num = SHOW_TIME
end

function sys.numDisplay(deck)
    assert(deck)
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
    sys.deckSave(deck)
end

function sys.rotDec(deck, track)
    sys.decTrackVal("rot", deck, track)
    sys.deckSave(deck)
end

function sys.rotTouch(deck)
    assert(deck)
    sys.display.show_ttls[deck].rot = SHOW_TIME
end

function sys.rotDisplay(deck)
    assert(deck)
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
    assert(deck)
    local prev = sys._getTotalProgress(deck)
    local pattern_index = sys.player.setup[deck].pattern
    local val = sys.memory[pattern_index].len
    local max = sys.limits.len.max
    if val == max then
        val = sys.limits.len.min -- wrap around
    else
        val = math.min(val + 1, max)
    end
    sys.memory[pattern_index].len = val
    sys.lenTouch(deck)
    sys._setTotalProgress(prev, deck)
    sys.deckSave(deck)
end

function sys.lenDec(deck)
    assert(deck)
    local prev = sys._getTotalProgress(deck)
    local pattern_index = sys.player.setup[deck].pattern
    local val = sys.memory[pattern_index].len
    local min = sys.limits.len.min
    if val == min then
        val = sys.limits.len.max -- wrap around
    else
        val = math.max(val - 1, min)
    end
    sys.memory[pattern_index].len = val
    sys.lenTouch(deck)
    sys._setTotalProgress(prev, deck)
    sys.deckSave(deck)
end

function sys.lenTouch(deck)
    assert(deck)
    sys.display.show_ttls[deck].len = SHOW_TIME
end

function sys.lenDisplay(deck)
    assert(deck)
    if sys.display.show_ttls[deck].len > 0.0 then
        local pattern_index = sys.player.setup[deck].pattern
        return string.format("%03d", sys.memory[pattern_index].len)
    end
    return "LEN"
end

function sys.getLen(deck)
    assert(deck)
    local pattern_index = sys.player.setup[deck].pattern
    return sys.memory[pattern_index].len
end

---------
-- MEM --
---------

function sys.memInc(deck)
    assert(deck)
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
    assert(deck)
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
    assert(deck)
    sys.display.show_ttls[deck].mem = SHOW_TIME
end

function sys.memDisplay(deck)
    assert(deck)
    if sys.display.show_ttls[deck].mem > 0.0 then
        local pattern_index = sys.player.setup[deck].pattern
        return string.format("%03d", pattern_index)
    end
    return "MEM"
end

return sys
