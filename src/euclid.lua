
-- 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
-- 10, 10, 10, 10, 10, 10, 0, 0, 0, 0
-- 100, 100, 100, 100, 10, 10
-- 10010, 10010, 100, 100
-- 10010100, 10010100
-- 1001010010010100


-- 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0
-- 10, 10, 10, 10, 10, 10, 1, 1, 1, 1
-- 101, 101, 101, 101, 10, 10
-- 10110, 10110, 101, 101
-- 10110101, 10110101
-- 1011010110110101

local euclid = {}

function euclid._equal(ta, tb)
	if #ta ~= #tb then
        return false
    end
    for index = 1, #ta do
        if ta[index] ~= tb[index] then
            return false
        end
    end
    return true
end

function euclid._merge(...)
    local arg={...}
    local result = {}
    for i, t in ipairs(arg) do
        for i, v in ipairs(t) do 
            table.insert(result, v)
        end
    end
    return result
end

function euclid._generate(len, num, rot)
    -- See: http://cgm.cs.mcgill.ca/~godfried/publications/banff.pdf

    -- initial layout
    local pattern = {}
    for i = 1, len do
        if i <= num then
            table.insert(pattern, {1})
        else
            table.insert(pattern, {0})
        end
    end

    -- order
    while true do
        -- euclid._print(pattern)

        -- merged as far as possible
        if #pattern <= 2 then
            rhythm = euclid._merge(unpack(pattern))
            break
        end

        -- find non repeat index
        local nri = nil
        for i = 2, #pattern do
            if not euclid._equal(pattern[i], pattern[i-1]) then
                nri = i
                break
            end
        end

        -- evenly distributed
        if nri == nil or nri == #pattern then
            rhythm = euclid._merge(unpack(pattern))
            break
        end

        -- zip from nri
        local lindex = 1
        local rindex = nri
        local next_pattern = {}
        for i = 1, math.max(#pattern - nri + 1, nri - 1) do
            local ta = {}
            if i < nri then
                ta = pattern[i]
            end
            local tb = {}
            if nri + i - 1 <= #pattern then
                tb = pattern[nri + i - 1]
            end
            assert(#ta + #tb > 0)
            next_pattern[i] = euclid._merge(ta, tb)
        end
        pattern = next_pattern
    end

    -- rotate 
    local result = {}
    for step = 1, len do
        result[step] = rhythm[((step + (len - 1) - rot) % len) + 1]
    end
    return result
end

function euclid._print(pattern)
    local s = ""
    for i, t in ipairs(pattern) do
        s = s .. "["
        for i, v in ipairs(t) do
            s = s .. v .. ","
        end
        s = s .. "], "
    end
    print(s)
end

function euclid.init()
    euclid.lookup = {}
    for len = 1, 16 do
        euclid.lookup[len] = {}
        for num = 0, len do
            euclid.lookup[len][num] = {}
            for rot = 0, len - 1 do
                euclid.lookup[len][num][rot] = euclid._generate(len, num, rot)
            end
        end
    end
end

function euclid.rhythm(len, num, rot)
    return euclid.lookup[len][num][rot]
end

print(euclid.init())
-- print(unpack(euclid._generate(15, 12, 0)))
-- print(unpack(euclid._merge(euclid._generate(16, 6, 0))))

return euclid
