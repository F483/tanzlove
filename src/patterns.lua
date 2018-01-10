local util = require("src.util")

local DEFAULT = {
    len = 16,
    tracks = {
        {vol = 15, snd = 0, num = 0, rot = 0},
        {vol = 15, snd = 0, num = 0, rot = 0},
        {vol = 15, snd = 0, num = 0, rot = 0},
        {vol = 15, snd = 0, num = 0, rot = 0},
    }
}

local patterns = {
    default = DEFAULT,
    memory = {
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
        util.deepCopy(DEFAULT_PATTERN), util.deepCopy(DEFAULT_PATTERN),
    }
}

function patterns.init()
    -- TODO implement, load from json
end

function patterns.save()
    -- TODO implement, save to json
end

return patterns
