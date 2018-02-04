local gfx = require("src.gfx")

return {
    eigengrau = {22, 22, 29},
    black = {0, 0, 0},
    white = {255, 255, 255},
    gray = {127, 127, 127},
    track = {
        {
            alpha={gfx.hsv2rgb(255*(1/6), (1/2)*255, 255)},
            beta={gfx.hsv2rgb(255*(1/6), (1/2)*255, 127)},
            gamma={gfx.hsv2rgb(255*(1/6), (1/2)*255, 63)},
        },
        {
            alpha={gfx.hsv2rgb(255*(4/6), (2/3)*255, 255)},
            beta={gfx.hsv2rgb(255*(4/6), (2/3)*255, 127)},
            gamma={gfx.hsv2rgb(255*(4/6), (2/3)*255, 63)},
        },
        {
            alpha={gfx.hsv2rgb(255*(3/6), (1/2)*255, 255)},
            beta={gfx.hsv2rgb(255*(3/6), (1/2)*255, 127)},
            gamma={gfx.hsv2rgb(255*(3/6), (1/2)*255, 63)},
        },
        {
            alpha={gfx.hsv2rgb(255*(6/6), (2/3)*255, 255)},
            beta={gfx.hsv2rgb(255*(6/6), (2/3)*255, 127)},
            gamma={gfx.hsv2rgb(255*(6/6), (2/3)*255, 63)},
        },
    },
    left = {
        alpha={gfx.hsv2rgb(255*(2/6), (2/3)*255, 255)},
        beta={gfx.hsv2rgb(255*(2/6), (2/3)*255, 127)},
        gamma={gfx.hsv2rgb(255*(2/6), (2/3)*255, 63)},
    },
    right = {
        alpha={gfx.hsv2rgb(255*(5/6), (2/3)*255, 255)},
        beta={gfx.hsv2rgb(255*(5/6), (2/3)*255, 127)},
        gamma={gfx.hsv2rgb(255*(5/6), (2/3)*255, 63)},
    }
}
