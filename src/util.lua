local vector = require("lib.hump.vector-light")
local json = require("lib.json")

local util = {}

function util.camAdjustPos(pos, cam)
    local px, py = unpack(pos)
    local cx, cy = unpack(cam)
    return px - cx, py - cy
end

function util.colorInvert(r, g, b)
    return 255 - r, 255 - g, 255 - b
end

function util.camAdjustRect(rect, cam)
    local rx, ry, rw, rh = unpack(rect)
    local cx, cy = unpack(cam)
    return rx - cx, ry - cy, rw, rh
end

function util.overRect(x, y, rect, cam)
    local bx, by, bw, bh = util.camAdjustRect(rect, cam)
    return x >= bx and x < bx + bw and y >= by and y < by + bh 
end

function util.loadJsonFile(filepath)
    local rawdata, size = love.filesystem.read(filepath)
    assert(size, "Couldn't read from file: " .. filepath)
    return json.decode(rawdata)
end

function util.saveJsonFile(filepath, data)
    local rawdata = json.encode(data)
    local success, message = love.filesystem.write(filepath, rawdata)
    assert(success, "Couldn't write to file: " .. (message or ""))
end

function util.deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[util.deepCopy(orig_key)] = util.deepCopy(orig_value)
        end
        setmetatable(copy, util.deepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function util.getAngle(sx, sy, tx, ty)
    return vector.angleTo(vector.sub(tx, ty, sx, sy))
end

function util.move(x, y, angle, dist)
    return vector.add(x, y, vector.rotate(angle, dist, 0))
end

return util
