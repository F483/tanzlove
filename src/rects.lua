return {
    logo = {84, 4, 68, 8},
    atom = {118, 50, 34, 6}, -- x, y, radius, delta
    leave = {4, 4, 48, 8},
    bpm = {184, 4, 48, 8},
    fader = {92, 88, 52, 8},
    left = {
        select = {80, 88, 8, 8},
        vol = {4, 4 + 12 * 2, 40, 8},
        snd = {4, 4 + 12 * 3, 40, 8},
        num = {4, 4 + 12 * 4, 40, 8},
        rot = {4, 4 + 12 * 5, 40, 8},
        len = {4 + 32, 4 + 12 * 6, 40, 8},
        mem = {4 + 32, 4 + 12 * 7, 40, 8},
        track = {
            {
                select = {68, 4 + 12 * 2, 8, 8},
                mute = {56, 4 + 12 * 2, 8, 8},
                solo = {48, 4 + 12 * 2, 8, 8},
            },
            {
                select = {68, 4 + 12 * 3, 8, 8},
                mute = {56, 4 + 12 * 3, 8, 8},
                solo = {48, 4 + 12 * 3, 8, 8},
            },
            {
                select = {68, 4 + 12 * 4, 8, 8},
                mute = {56, 4 + 12 * 4, 8, 8},
                solo = {48, 4 + 12 * 4, 8, 8},
            },
            {
                select = {68, 4 + 12 * 5, 8, 8},
                mute = {56, 4 + 12 * 5, 8, 8},
                solo = {48, 4 + 12 * 5, 8, 8},
            },
        }
    },
    right = {
        select = {148, 88, 8, 8},
        vol = {192, 4 + 12 * 2, 40, 8},
        snd = {192, 4 + 12 * 3, 40, 8},
        num = {192, 4 + 12 * 4, 40, 8},
        rot = {192, 4 + 12 * 5, 40, 8},
        len = {192 - 32, 4 + 12 * 6, 40, 8},
        mem = {192 - 32, 4 + 12 * 7, 40, 8},
        track = {
            {
                select = {160, 4 + 12 * 2, 8, 8},
                mute = {172, 4 + 12 * 2, 8, 8},
                solo = {180, 4 + 12 * 2, 8, 8},
            },
            {
                select = {160, 4 + 12 * 3, 8, 8},
                mute = {172, 4 + 12 * 3, 8, 8},
                solo = {180, 4 + 12 * 3, 8, 8},
            },
            {
                select = {160, 4 + 12 * 4, 8, 8},
                mute = {172, 4 + 12 * 4, 8, 8},
                solo = {180, 4 + 12 * 4, 8, 8},
            },
            {
                select = {160, 4 + 12 * 5, 8, 8},
                mute = {172, 4 + 12 * 5, 8, 8},
                solo = {180, 4 + 12 * 5, 8, 8},
            },
        }
    }
}
