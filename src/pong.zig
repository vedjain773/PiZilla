const fb = @import("framebuffer.zig");
const timer = @import("timer.zig");

const Ball = struct {
    posx: i32,
    posy: i32,
    velx: i32,
    vely: i32,
};

fn wait(t: u32) void {
    const target: u32 = timer.getTicks() + t;

    while (timer.getTicks() < target) {
        //wait
    }

    return;
}

pub fn start() noreturn {
    fb.init_fb();
    
    var ball: Ball = .{
        .posx = 1,
        .posy = 1,
        .velx = 2,
        .vely = 2,
    };

    while (true) {
        ball.posx += ball.velx;
        ball.posy += ball.vely;

        fb.drawPixel(@max(ball.posx, 0), @max(ball.posy, 0));
        wait(10);
        fb.clrScreen();

        if (ball.posx <= 0 or ball.posx >= 639) {
            ball.velx *= -1;
        }

        if (ball.posy <= 0 or ball.posy >= 479) {
            ball.vely *= -1;
        }
    }
}
