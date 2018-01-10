
local player = {
    limits = {
        vol = {min=0, max=15},
        snd = {min=0, max=15},
        num = {min=0, max=16},
        rot = {min=0, max=15},
        bpm = {min=1, max=255},
        mem = {min=0, max=128}
    },
    setup = {
        bpm = 128,
        fade = 1.0, -- 0.0 = left, 1.0 = right
        left = {
            pattern = 1, -- memory index
            solo = nil,
            mute = {false, false, false, false, false, false, false, false},
        },
        right = {
            pattern = 1, -- memory index
            solo = nil,
            mute = {false, false, false, false, false, false, false, false},
        }
    }
}

function player.init()
    -- TODO implement, load previous configuration from json
end

function player.save()
    -- TODO implement, save current configuration to json
end

return player
