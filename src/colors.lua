local gfx = require("src.gfx")

return {
    eigengrau = {22, 22, 29},
    black = {0, 0, 0},
    white = {255, 255, 255},
    gray = {127, 127, 127},
    track = {
        {
            up_selected={gfx.hsv2rgb(255*(1/6), (2/3)*255, (4/4)*255)},
            down_selected={gfx.hsv2rgb(255*(1/6), (2/3)*255, (2/4)*255)},
            up_inactive={gfx.hsv2rgb(255*(1/6), (2/3)*255, (3/4)*255)},
            down_inactive={gfx.hsv2rgb(255*(1/6), (2/3)*255, (1/4)*255)},
        },
        {
            up_selected={gfx.hsv2rgb(255*(4/6), (2/3)*255, (4/4)*255)},
            down_selected={gfx.hsv2rgb(255*(4/6), (2/3)*255, (2/4)*255)},
            up_inactive={gfx.hsv2rgb(255*(4/6), (2/3)*255, (3/4)*255)},
            down_inactive={gfx.hsv2rgb(255*(4/6), (2/3)*255, (1/4)*255)},
        },
        {
            up_selected={gfx.hsv2rgb(255*(3/6), (2/3)*255, (4/4)*255)},
            down_selected={gfx.hsv2rgb(255*(3/6), (2/3)*255, (2/4)*255)},
            up_inactive={gfx.hsv2rgb(255*(3/6), (2/3)*255, (3/4)*255)},
            down_inactive={gfx.hsv2rgb(255*(3/6), (2/3)*255, (1/4)*255)},
        },
        {
            up_selected={gfx.hsv2rgb(255*(6/6), (2/3)*255, (4/4)*255)},
            down_selected={gfx.hsv2rgb(255*(6/6), (2/3)*255, (2/4)*255)},
            up_inactive={gfx.hsv2rgb(255*(6/6), (2/3)*255, (3/4)*255)},
            down_inactive={gfx.hsv2rgb(255*(6/6), (2/3)*255, (1/4)*255)},
        },
    },
    left = {
        up_selected={gfx.hsv2rgb(255*(2/6), (2/3)*255, (4/4)*255)},
        down_selected={gfx.hsv2rgb(255*(2/6), (2/3)*255, (2/4)*255)},
        up_inactive={gfx.hsv2rgb(255*(2/6), (2/3)*255, (3/4)*255)},
        down_inactive={gfx.hsv2rgb(255*(2/6), (2/3)*255, (1/4)*255)},
    },
    right = {
        up_selected={gfx.hsv2rgb(255*(5/6), (2/3)*255, (4/4)*255)},
        down_selected={gfx.hsv2rgb(255*(5/6), (2/3)*255, (2/4)*255)},
        up_inactive={gfx.hsv2rgb(255*(5/6), (2/3)*255, (3/4)*255)},
        down_inactive={gfx.hsv2rgb(255*(5/6), (2/3)*255, (1/4)*255)},

    }
}
