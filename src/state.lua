local player = require("src.player")

local state = {
    -- TODO add limits
    -- TODO add player state
    -- TODO move to state.board
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
}

function state.update(dt)
    state.show_ttls.bpm = math.max(0.0, state.show_ttls.bpm - dt)
    state.show_ttls.left.len = math.max(0.0, state.show_ttls.left.len - dt)
    state.show_ttls.left.mem = math.max(0.0, state.show_ttls.left.mem - dt)
    state.show_ttls.left.vol = math.max(0.0, state.show_ttls.left.vol - dt)
    state.show_ttls.left.snd = math.max(0.0, state.show_ttls.left.snd - dt)
    state.show_ttls.left.num = math.max(0.0, state.show_ttls.left.num - dt)
    state.show_ttls.left.rot = math.max(0.0, state.show_ttls.left.rot - dt)
    state.show_ttls.right.len = math.max(0.0, state.show_ttls.right.len - dt)
    state.show_ttls.right.mem = math.max(0.0, state.show_ttls.right.mem - dt)
    state.show_ttls.right.vol = math.max(0.0, state.show_ttls.right.vol - dt)
    state.show_ttls.right.snd = math.max(0.0, state.show_ttls.right.snd - dt)
    state.show_ttls.right.num = math.max(0.0, state.show_ttls.right.num - dt)
    state.show_ttls.right.rot = math.max(0.0, state.show_ttls.right.rot - dt)
end

function state.bpmInc()
    player.setup.bpm = math.min(player.setup.bpm + 1, player.limits.bpm.max)
end

function state.bpmDec()
    player.setup.bpm = math.max(player.setup.bpm - 1, player.limits.bpm.min)
end

function state.bpmShow()
    state.show_ttls.bpm = SHOW_TIME
end

function state.trackSelect(deck, track)
    state.selected[deck] = t
end

function state.toggleSolo(deck, track)
    if player.setup[deck].solo == track then
        player.setup[deck].solo = nil
    else
        player.setup[deck].solo = track
    end
end

function state.toggleMute(deck, track)
    local current_value = player.setup[deck].mute[track]
    player.setup[deck].mute[track] = not current_value
end

function state.volInc(deck) 
    print("volInc")
end

function state.volDec(deck) 
    print("volDec")
end

function state.volShow(deck) 
    state.show_ttls[deck].vol = SHOW_TIME
end

function state.sndInc(deck) 
    print("sndInc")
end

function state.sndDec(deck) 
    print("sndDec")
end

function state.sndShow(deck) 
    state.show_ttls[deck].snd = SHOW_TIME
end

function state.numInc(deck) 
    print("numInc")
end

function state.numDec(deck) 
    print("numDec")
end

function state.numShow(deck) 
    state.show_ttls[deck].num = SHOW_TIME
end

function state.rotInc(deck) 
    print("rotInc")
end

function state.rotDec(deck) 
    print("rotDec")
end

function state.rotShow(deck) 
    state.show_ttls[deck].rot = SHOW_TIME
end

function state.lenInc(deck) 
    print("lenInc")
end

function state.lenDec(deck) 
    print("lenDec")
end

function state.lenShow(deck) 
    state.show_ttls[deck].len = SHOW_TIME
end

function state.memInc(deck) 
    print("memInc")
end

function state.memDec(deck) 
    print("memDec")
end

function state.memShow(deck) 
    state.show_ttls[deck].mem = SHOW_TIME
end

return state
