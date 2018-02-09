local util = require("src.util")
local euclid = require("src.euclid")

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
    "snd/nlp/BL.WAV", -- bass drum long
    "snd/nlp/BS.WAV", -- bass drum short
    "snd/nlp/CP.WAV", -- clap
    "snd/nlp/CV.WAV", -- clave
    "snd/nlp/CN.WAV", -- conga
    "snd/nlp/CB.WAV", -- cowbell
    "snd/nlp/CY.WAV", -- cymbal
    "snd/nlp/HC.WAV", -- high hat closed
    "snd/nlp/HO.WAV", -- high hat open
    "snd/nlp/HP.WAV", -- high hat pedal
    "snd/nlp/S1.WAV", -- snare one
    "snd/nlp/S2.WAV", -- snare two
    "snd/nlp/SK.WAV", -- shaker
    "snd/nlp/TL.WAV", -- tom low
    "snd/nlp/TM.WAV", -- tom mid
    "snd/nlp/TH.WAV", -- tom high
}

local sys = {

    stopped = true,

    limits = {
        vol = {min=0, max=15},
        snd = {min=1, max=16},
        num = {min=0, max=16},
        rot = {min=0, max=15},
        bpm = {min=1, max=255},
        len = {min=2, max=16},
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
    local save_dir = love.filesystem.getSaveDirectory()
    assert(success, "Couldn't create '" .. MEM_DIR .. "' dir at: " .. save_dir)
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
	-- FIXME merge into single clock that counts beats instead
    sys.player.clock.left = sys.player.clock.right + dt
    sys.player.clock.right = sys.player.clock.right + dt

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

    sys._setTotalProgress(prev_left, "left")
    sys._setTotalProgress(prev_right, "right")
end

function sys.bpmDec()
    local prev_left = sys._getTotalProgress("left")
    local prev_right = sys._getTotalProgress("right")

    local val = sys.player.setup.bpm
    sys.player.setup.bpm = math.max(val - 1, sys.limits.bpm.min)

    sys._setTotalProgress(prev_left, "left")
    sys._setTotalProgress(prev_right, "right")
end

function sys.getBpm()
    return string.format("%03d", sys.player.setup.bpm)
end

----------
-- DECK --
----------

function sys.deckSelect(deck)
    sys.display.deck = deck
end

function sys.getSelectedDeck()
    return sys.display.deck
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

function sys.getVol(deck, track)
    return sys.getTrackVal("vol", deck, track)
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

function sys.sndName(deck)
    assert(deck)
    local val = sys.getTrackVal("snd", deck)
    local filename = SAMPLES[val]
    return filename:match("([^/]+).WAV$")
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
    sys._setTotalProgress(prev, deck)
    sys.deckSave(deck)
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
end

function sys.getMem(deck)
    return sys.player.setup[deck].pattern
end

return sys
