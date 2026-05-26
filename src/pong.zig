const fb = @import("framebuffer.zig");
const utils = @import("utils.zig");
const print = @import("print.zig");
const timer = @import("timer.zig");

var sx: u32 = 50;
var sy: u32 = 50;
var targ_up: u32 = 0;
var targ_down: u32 = 0;

const Ball = struct {
    old_posx: i32,
    old_posy: i32,
    posx: i32,
    posy: i32,
    velx: i32,
    vely: i32,
};

const Paddle = struct {
    px1: u32,
    px2: u32,
    x1: u32,
    x2: u32,
    y: u32, 
};

fn wait(t: u32) void {
    const target: u32 = timer.getTicks() + t;
    while (timer.getTicks() < target) {
        //wait
    }
    return;
}

pub fn detect_col(bx: i32, by: i32, pdy: u32, pdx1: u32, pdx2: u32) bool {
    if (@max(by, 0) == pdy) {
        const bx_u: u32 = @max(bx, 0);
        if (bx_u > pdx1 and bx_u < pdx2) {
            return true;
        }
        return false;
    }
    return false;
}

pub fn find_target(vx: i32, vy: i32) void {
    if (vx * vy > 0) {
        const c: i32 = @as(i32, @intCast(sy)) - @as(i32, @intCast(sx));
        targ_up = utils.clamp(10 - c, 0, 639);
        targ_down = utils.clamp(470 - c, 0, 639);
    } else {
        const c: i32 = @as(i32, @intCast(sy)) + @as(i32, @intCast(sx));
        targ_up = utils.clamp(c - 10, 0, 639);
        targ_down = utils.clamp(c - 470, 0, 639);
    }

    print.print("%d, %d\r\n", .{sx, sy});
}

pub fn start() noreturn {
    fb.init_fb();

    var ball: Ball = .{
        .old_posx = 50,
        .old_posy = 50,
        .posx = 50,
        .posy = 50,
        .velx = 2,
        .vely = 2,
    };
    
    var pad_1: Paddle = .{
        .px1 = 300,
        .px2 = 350,
        .x1 = 300,
        .x2 = 350,
        .y = 10
    };
    
    var pad_2: Paddle = .{
        .px1 = 300,
        .px2 = 350,
        .x1 = 300,
        .x2 = 350,
        .y = 470,
    };
    
    while (true) {
        find_target(ball.velx, ball.vely);
        pad_1.px1 = pad_1.x1;
        pad_1.px2 = pad_1.x2;

        pad_2.px1 = pad_2.x1;
        pad_2.px2 = pad_2.x2;

        ball.old_posx = ball.posx;
        ball.old_posy = ball.posy;
        
        ball.posx += ball.velx;
        ball.posy += ball.vely;
        
        fb.drawPixel(@max(ball.posx, 0), @max(ball.posy, 0));
        fb.drawBlankPix(@max(ball.old_posx, 0), @max(ball.old_posy, 0));
        
        if (ball.vely > 0) {
            if (targ_down > pad_2.x2 - 5) {
                pad_2.x1 += 2;
                pad_2.x2 += 2;
                fb.updateLineH(pad_2.px1, pad_2.px2, pad_2.x1, pad_2.x2, pad_2.y);
            } else if (targ_down < pad_2.x1 + 5) {
                pad_2.x1 -= 2;
                pad_2.x2 -= 2;
                fb.updateLineH(pad_2.px1, pad_2.px2, pad_2.x1, pad_2.x2, pad_2.y);
            }
        } else {
            if (targ_up > pad_1.x2 - 5) {
                pad_1.x1 += 2;
                pad_1.x2 += 2;
                fb.updateLineH(pad_1.px1, pad_1.px2, pad_1.x1, pad_1.x2, pad_1.y);
            } else if (targ_up < pad_1.x1 + 5) {
                pad_1.x1 -= 2;
                pad_1.x2 -= 2;
                fb.updateLineH(pad_1.px1, pad_1.px2, pad_1.x1, pad_1.x2, pad_1.y);               
            }
        }
        
        wait(100);
        //fb.clrScreen();
        
        if (ball.posx <= 0 or ball.posx >= 639) {
            ball.velx *= -1;
            sx = @as(u32, @intCast(ball.posx));
            sy = @as(u32, @intCast(ball.posy));
        }
        
        if (detect_col(ball.posx, ball.posy, pad_1.y, pad_1.x1, pad_1.x2) or detect_col(ball.posx, ball.posy, pad_2.y, pad_2.x1, pad_2.x2))  {
            ball.vely *= -1;
            sx = @as(u32, @intCast(ball.posx));
            sy = @as(u32, @intCast(ball.posy));
        }
    }
}
